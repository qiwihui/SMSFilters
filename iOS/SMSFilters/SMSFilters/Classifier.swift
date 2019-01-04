//
//  Classifier.swift
//  MessageExtension
//
//  Created by Qiwihui on 7/15/18.
//  Copyright © 2018 qiwihui. All rights reserved.
//

import Foundation
import CoreML

class Classifier {
    let model = SpamMessageClassifier()
    
    var idf = [Double]()
    var vocabulary = [String:Int]()
    var norm = true

    init() {
        let wordsPath = Bundle.main.url(forResource:"words_array", withExtension:"json")
        do {
            let wordsData = try Data(contentsOf: wordsPath!)
            if let wordsDict = try JSONSerialization.jsonObject(with: wordsData, options: []) as? [String:Int] {
                self.vocabulary = wordsDict
            }
        } catch {
            fatalError("oops could not load words_array")
        }
        
        let idfPath = Bundle.main.url(forResource: "words_idf", withExtension: "json")
        do {
            let idfData = try Data(contentsOf: idfPath!)
            if let idfJson = try JSONSerialization.jsonObject(with: idfData, options: []) as? [String:[Double]] {
                self.idf = idfJson["idf"]!
            }
        } catch {
            fatalError("oops could not load words_idf file")
        }
        
        let dictPath = Bundle.main.resourceURL!.appendingPathComponent("iosjieba/iosjieba.bundle/dict/jieba.dict.small.utf8").absoluteString
        let hmmPath = Bundle.main.resourceURL!.appendingPathComponent("iosjieba/iosjieba.bundle/dict/hmm_model.utf8").absoluteString
        let userDictPath = Bundle.main.resourceURL!.appendingPathComponent("iosjieba/iosjieba.bundle/dict/user.dict.utf8").absoluteString
        
        ObjcJiebaInit(dictPath, hmmPath, userDictPath);
    }
    
    func predict(_ message:String) -> Bool {
        print("预测...")
        let vector = tfidf(sentence: message)
        let mlarray = multiarray(vector: vector)
        do {
            let result = try self.model.prediction(message: mlarray)
            print("Predict result: \(result)")
            return result.spam_or_not == 1
        } catch {
            print("Error: \(error)")
        }
        return false
    }
    
    func tokenize(_ message:String) -> [String] {
        print("tokenize...")
//        let tokenizer = CFStringTokenizerCreate(nil,
//                                                message as CFString,
//                                                CFRangeMake(0, message.count),
//                                                kCFStringTokenizerUnitWordBoundary, nil)
//
//        CFStringTokenizerAdvanceToNextToken(tokenizer)
//        var range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
//        var words = [String]()
//        while range.length > 0 {
//            let startIndex = message.index(message.startIndex, offsetBy: range.location as Int)
//            let endIndex = message.index(message.startIndex, offsetBy: range.location as Int + range.length as Int)
//            let token = String(message[startIndex..<endIndex])
//            words.append(token)
//            // print(token)
//            CFStringTokenizerAdvanceToNextToken(tokenizer);
//            range = CFStringTokenizerGetCurrentTokenRange(tokenizer);
//        }
        var words = [String]()
        ObjcJiebaCut(message, words)
        
        return words as [String]
    }

    func countVector(sentence:String) -> [Int:Int]? {
        print("cv...")
        var vec = [Int:Int]()
        for word in self.tokenize(sentence) {
            if let pos = self.vocabulary[word] {
                if let i = vec[pos] {
                    vec[pos] = i+1
                } else {
                    vec[pos] = 1
                }
            }
        }
        return vec
    }
    
    func idf(word:String) -> Double {
        if let pos = self.vocabulary[word] {
            return self.idf[pos]
        } else {
            return Double(0.0)
        }
    }
    
    
    func tfidf(sentence:String) -> [Int:Double] {
        print("tfidf...")
        let cv = countVector(sentence: sentence)
        var vec = [Int:Double]()
        
        cv?.forEach({ (key, value) in
            let i = self.idf[key]
            let t = Double(value) / Double(cv!.count)
            vec[key] = t * i
        })
        //vec now is TFIDF, but is not normalized
        if self.norm { //L2 Norm
            var sum = vec.compactMap{ $1 }.reduce(0) { $0 + $1*$1 }
            sum = sqrt(sum)
            
            var n = [Int:Double]()
            
            vec.forEach({ (key, value) in
                n[key] = value / sum
            })
            
            return n
        }
        return vec
    }
    
    func multiarray(vector:[Int:Double]) -> MLMultiArray {
        let array = try! MLMultiArray(shape: [NSNumber(integerLiteral: self.vocabulary.count)], dataType: .double)
        for (key, value) in vector {
            array[key] = NSNumber(floatLiteral: value)
        }
        return array
    }
}
