//
//  MySegmentor.m
//  SMSFilters
//
//  Created by Qiwihui on 1/3/19.
//  Copyright © 2019 qiwihui. All rights reserved.
//

#import "MySegmentor.h"
#import "Segmentor.hpp"
#include <algorithm>
#include <string>
#include <vector>

//extern cppjieba::MixSegment * globalSegmentor;
//
//void JiebaInit(const std::string& dictPath, const std::string& hmmPath, const std::string& userDictPath);
//
//void JiebaCut(const std::string& sentence, std::vector<std::string>& words);


void ObjcJiebaInit(NSString * dictPath, NSString * hmmPath, NSString * userDictPath) {
    std::string cDictPath = std::string([dictPath UTF8String]);
    std::string cHmmPath = std::string([hmmPath UTF8String]);
    std::string cUserDictPath = std::string([userDictPath UTF8String]);
    JiebaInit(cDictPath, cHmmPath, cUserDictPath);
}

// Convert vector to NSArray
//NSArray *myArray = [NSArray arrayWithObjects:&vector[0] count:vector.size()];
void ObjcJiebaCut(NSString * sentence, NSMutableArray * words) {
    std::string cSentence = std::string([sentence UTF8String]);
    
    std::vector<std::string> wordsList;
    for (int i = 0; i < [words count];i++)
    {
        wordsList.push_back(wordsList[i]);
    }
    JiebaCut(cSentence, wordsList);
    
    [words removeAllObjects];
    std::for_each(wordsList.begin(), wordsList.end(),
                  [&words](std::string str) {
                      id nsstr = [NSString stringWithUTF8String:str.c_str()];
                      [words addObject:nsstr];
                  });
}

