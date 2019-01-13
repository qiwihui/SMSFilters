//
//  MessageFilterExtension.swift
//  SMSFiltersMessageExtension
//
//  Created by Qiwihui on 1/4/19.
//  Copyright © 2019 qiwihui. All rights reserved.
//

import os.log
import IdentityLookup
import CoreData

final class MessageFilterExtension: ILMessageFilterExtension {
    
    var keywordWhiteList:[String] = []
    var keywordBlackList:[String] = []
    var senderWhiteList:[String] = []
    var senderBlackList:[String] = []
    
    var fetchedResultController: NSFetchedResultsController<RuleMO>!
    
    func loadRules() {
        let container = NSPersistentContainer(name: "SMSFilters")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // 获取数据
        let fetchRequest: NSFetchRequest<RuleMO> = RuleMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let context = container.viewContext
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultController.performFetch()
            if let fetchedObjects = fetchedResultController.fetchedObjects {
                for (_, element) in fetchedObjects.enumerated() {
                    if element.type == 1 {
                        keywordWhiteList.append(element.name!)
                    } else if element.type == 2 {
                        keywordBlackList.append(element.name!)
                    } else if element.type == 3 {
                        senderWhiteList.append(element.name!)
                    } else if element.type == 4 {
                        senderBlackList.append(element.name!)
                    }
                }
                print("blackSenders: \(senderBlackList)")
            }
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        // First, check whether to filter using offline data (if possible).
        let offlineAction = self.offlineAction(for: queryRequest)
        
        switch offlineAction {
        case .allow, .filter:
            // Based on offline data, we know this message should either be Allowed or Filtered. Send response immediately.
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
        guard let messageSender = queryRequest.sender?.lowercased() else { return .none }
        guard let messageBody = queryRequest.messageBody?.lowercased() else { return .none }
        print("Sender: \(messageSender), body: \(messageBody)")
        
        self.loadRules()
        
        // 号码黑白名单过滤
        for sender in senderWhiteList {
            if messageSender.contains(sender.lowercased()) {
                return .none
            }
        }
        for sender in senderBlackList {
            if messageSender.contains(sender.lowercased()) {
                return .filter
            }
        }
        
        // 关键词黑白名单过滤
        for word in keywordWhiteList {
            if messageBody.contains(word.lowercased()) {
                return .none
            }
        }
        for word in keywordBlackList {
            if messageBody.contains(word.lowercased()) {
                return .filter
            }
        }
        
        // 模型过滤
//        let classfier = Classifier()
//        let result = classfier.predict(queryRequest.messageBody!)
//        return result ? .filter : .none
        return .none
    }
    
    private func action(for networkResponse: ILNetworkResponse) -> ILMessageFilterAction {
        // Replace with logic to parse the HTTP response and data payload of `networkResponse` to return an action.
        return .none
    }
    
}
