//
//  MessageFilterExtension.swift
//  SMSFiltersMessageExtension
//
//  Created by Qiwihui on 1/4/19.
//  Copyright © 2019 qiwihui. All rights reserved.
//

import os.log
import IdentityLookup

final class MessageFilterExtension: ILMessageFilterExtension {
    var white_keywords:[String] = ["N:E:T:"]
    var black_keywords:[String] = ["中国移动"]
    var white_senders:[String] = ["001", "002", "003"]
    var black_senders:[String] = ["004", "005", "006"]
    
    //    let stack = CoreDataStack()
    
    func loadItems() {
        //        let context = stack.persistentContainer.viewContext
        //        let itemDAO = ItemDAO(managedObjectContext: context)
        //        let allItems = itemDAO.fetchItmes()
        //        self.words = allItems.flatMap({ item in
        //            return item.value != nil ? item : nil
        //        })
        
        // aqui ler o json do servidor e salvar local
        
        print("=> loadItems")
    }
}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        // First, check whether to filter using offline data (if possible).
        let offlineAction = self.offlineAction(for: queryRequest)
        
        switch offlineAction {
        case .allow, .filter:
            // Based on offline data, we know this message should either be Allowed or Filtered. Send response immediately.
            print("OfflineAction")
            let response = ILMessageFilterQueryResponse()
            response.action = offlineAction
            completion(response)
            
        case .none:
            // Based on offline data, we do not know whether this message should be Allowed or Filtered. Defer to network.
            // Note: Deferring requests to network requires the extension target's Info.plist to contain a key with a URL to use. See documentation for details.
            context.deferQueryRequestToNetwork() { (networkResponse, error) in
                let response = ILMessageFilterQueryResponse()
                response.action = .none
                
                if let networkResponse = networkResponse {
                    // If we received a network response, parse it to determine an action to return in our response.
                    response.action = self.action(for: networkResponse)
                } else {
                    NSLog("Error deferring query request to network: \(String(describing: error))")
                }
                
                completion(response)
            }
        }
    }
    
    private func offlineAction(for queryRequest: ILMessageFilterQueryRequest) -> ILMessageFilterAction {
        // Replace with logic to perform offline check whether to filter first (if possible).
        self.loadItems()
        
        guard let messageSender = queryRequest.sender?.lowercased() else { return .none }
        guard let messageBody = queryRequest.messageBody?.lowercased() else { return .none }
        
        print("Sender: \(messageSender), body: \(messageBody)")
        
        // 号码黑白名单过滤
        for sender in white_senders {
            if messageSender.contains(sender.lowercased()) {
                return .none
            }
        }
        for sender in black_senders {
            if messageSender.contains(sender.lowercased()) {
                return .filter
            }
        }
        
        // 关键词黑白名单过滤
        for word in white_keywords {
            if messageBody.contains(word.lowercased()) {
                return .none
            }
        }
        for word in black_keywords {
            if messageBody.contains(word.lowercased()) {
                return .filter
            }
        }
        
        // 模型过滤
        let classfier = Classifier()
        let result = classfier.predict(queryRequest.messageBody!)
        return result ? .filter : .none
    }
    
    private func action(for networkResponse: ILNetworkResponse) -> ILMessageFilterAction {
        // Replace with logic to parse the HTTP response and data payload of `networkResponse` to return an action.
        return .none
    }
    
}
