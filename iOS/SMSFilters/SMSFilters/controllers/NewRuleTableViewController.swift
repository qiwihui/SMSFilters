//
//  NewRuleTableViewController.swift
//  SMSFilters
//
//  Created by Qiwihui on 1/7/19.
//  Copyright © 2019 qiwihui. All rights reserved.
//

import UIKit
import CoreData

class NewRuleTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var rules: [RuleMO] = []
    var ruleType: Int16 = 1
    var navTitle: String = "关键词白名单"
    
    var fetchedResultController: NSFetchedResultsController<RuleMO>!
    
//    private let persistentContainer = NSPersistentContainer(name: "SMSFilters")
//    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<RuleMO> = {
//        // Create Fetch Request
//        let fetchRequest: NSFetchRequest<RuleMO> = RuleMO.fetchRequest()
//
//        // Configure Fetch Request
//        fetchRequest.predicate = NSPredicate(format: "type == %i", ruleType)
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        // Create Fetched Results Controller
//        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//
//        // Configure Fetched Results Controller
//        fetchedResultController.delegate = self
//
//        return fetchedResultController
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = navTitle
        
        // 根据类型获取数据
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let fetchRequest: NSFetchRequest<RuleMO> = RuleMO.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = NSPredicate(format: "type == %i", ruleType)
            let context = appDelegate.persistentContainer.viewContext
            fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

            fetchedResultController.delegate = self

            do {
                try fetchedResultController.performFetch()
                if let fetchedObjects = fetchedResultController.fetchedObjects {
                    rules = fetchedObjects
                }
            } catch {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
//         persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
//             if let error = error {
//                 print("Unable to Load Persistent Store")
//                 print("\(error), \(error.localizedDescription)")
//
//             } else {
//                 do {
//                     try self.fetchedResultsController.performFetch()
//                 } catch {
//                     let fetchError = error as NSError
//                     print("Unable to Perform Fetch Request")
//                     print("\(fetchError), \(fetchError.localizedDescription)")
//                 }
//             }
//         }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rules.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "RuleCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = rules[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: 左滑删除
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "删除") {
            (action, sourceView, completionHandler) in
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let ruleToDelete = self.fetchedResultController.object(at: indexPath)
                context.delete(ruleToDelete)
                appDelegate.saveContext()
            }
            completionHandler(true)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeConfiguration
    }
    
    // MARK: 数据变化
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        if let fetchedObjects = controller.fetchedObjects {
            rules = fetchedObjects as! [RuleMO]
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: 完成
    @IBAction func saveButtonTapped(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: 添加
    @IBAction func addButtonTapped(sender: AnyObject) {
        showInputDialog()
    }
    
    func showInputDialog() {
        let alertController = UIAlertController(title: "请输入关键字", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "好", style: .default) { (_) in
            // getting the input values from user
            if let name = alertController.textFields?[0].text {
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    let newRule = RuleMO(context: appDelegate.persistentContainer.viewContext)
                    newRule.name = name
                    newRule.type = self.ruleType
                    appDelegate.saveContext()
                }
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in }
        
        // 输入框
        alertController.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
