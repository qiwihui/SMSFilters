//
//  ViewController.swift
//  SMSFilters
//
//  Created by Qiwihui on 7/15/18.
//  Copyright © 2018 qiwihui. All rights reserved.
//

import Alamofire
import CoreData
import UIKit
import SafariServices

class MainViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var keywordWhiteCell: UITableViewCell!
    @IBOutlet var keywordBlackCell: UITableViewCell!
    @IBOutlet var senderWhiteCell: UITableViewCell!
    @IBOutlet var senderBlackCell: UITableViewCell!
    
    var ruleType: Int16 = 1
    var navTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("加载规则条数")
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            // select count(*), type from Rule group by type;
            let keypathExp = NSExpression(forKeyPath: "type")
            let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
            
            let countDesc = NSExpressionDescription()
            countDesc.expression = expression
            countDesc.name = "count"
            countDesc.expressionResultType = .integer64AttributeType
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rule")
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.propertiesToGroupBy = ["type"]
            fetchRequest.propertiesToFetch = ["type", countDesc]
            fetchRequest.resultType = .dictionaryResultType
            
            do {
                let results = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
                let itemList = results as! [[String: Int]]
                var itemChanged: [Int: Bool] = [:]
                let keyCell: [Int: UITableViewCell] = [1: keywordWhiteCell, 2:keywordBlackCell, 3:senderWhiteCell, 4:senderBlackCell]
               
                for item in itemList {
                    let typeValue = item["type"]!
                    let countValue = item["count"]!
                    setRuleNumberBadge(cell: keyCell[typeValue]!, number: countValue)
                    itemChanged[typeValue] = true
                }
                for key in [1,2,3,4] {
                    let keyExists = itemChanged[key] != nil
                    if !keyExists {
                        unsetRuleNumberBadge(cell: keyCell[key]!)
                    }
                }
            } catch let error as NSError {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: 设置规则条数
    func setRuleNumberBadge(cell: UITableViewCell, number: Int) {
        let size: CGFloat = 26
        let digits = CGFloat( "\(number)".count ) // digits in the label
        let width = max(size, 0.7 * size * digits) // perfect circle is smallest allowed
        let badge = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: size))
        badge.text = "\(number)"
        badge.layer.cornerRadius = size / 2
        badge.layer.masksToBounds = true
        badge.textAlignment = .center
        badge.textColor = UIColor.white
        badge.backgroundColor = UIColor.gray
        cell.accessoryView = badge
    }
    
    func unsetRuleNumberBadge(cell: UITableViewCell) {
        cell.accessoryView = nil
    }
    
    func convertToJSONArray(moArray: [NSManagedObject]) -> Any {
        var jsonArray: [[String: Any]] = []
        for item in moArray {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
            }
            jsonArray.append(dict)
        }
        return jsonArray
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            print("功能")
            if indexPath.row == 0 {
                print("开启功能")
                let optionMenu = UIAlertController(title: "开启过滤功能", message: "打开【设置->信息->未知与过滤信息】，在【短信过滤】一栏中选中【SMSFilters】", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
                optionMenu.addAction(okAction)
                present(optionMenu, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                print("准确性测试")
                let message:String = UIPasteboard.general.string ?? ""
                print("\(message)")
                if message == "" {
                    let alert = UIAlertController(title: nil, message: "请拷贝短信内容到剪贴板", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .cancel))
                    self.present(alert, animated: true)
                } else {
                    // 判断短信类型
                    let classfier = Classifier()
                    let result = classfier.predict(message)
                    print("Result: \(result)")
                    let messageType = result ? 1 : 0
                    var messageTypeDisplay:String = ""
                    var messageAction:String = ""
                    
                    if messageType == 1 {
                        messageTypeDisplay = "垃圾短信"
                        messageAction = "过滤"
                    } else {
                        messageTypeDisplay = "正常短信"
                        messageAction = "不过滤"
                    }
                    
                    let alertController = UIAlertController(title: "这是\(messageTypeDisplay) \(messageAction)", message: "\(message)", preferredStyle: .alert)
                    // 提交短信
                    let submitAsNormalAction = UIAlertAction(title: "提交为正常短信", style: .default, handler: {
                        action in
                        self.submitSms(message: message, messageType: messageType)
                    })
                    let submitAsSpamAction = UIAlertAction(title: "提交为垃圾短信", style: .default, handler: {
                        action in
                        self.submitSms(message: message, messageType: messageType)
                    })
                    let okAction = UIAlertAction(title: "好的", style: .default)
                    alertController.addAction(submitAsNormalAction)
                    alertController.addAction(submitAsSpamAction)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        case 1:
            print("自定义规则")
            switch indexPath.row {
            case 0:
                ruleType = 1
                navTitle = "关键词白名单"
            case 1:
                ruleType = 2
                navTitle = "关键词黑名单"
            case 2:
                ruleType = 3
                navTitle = "号码白名单"
            case 3:
                ruleType = 4
                navTitle = "号码黑名单"
            default:
                ruleType = 1
                navTitle = "关键词白名单"
            }
            self.performSegue(withIdentifier: "editRules", sender: self)
        case 2:
            print("关于")
            if indexPath.row == 0 {
                print("使用和常见问题")
                self.performSegue(withIdentifier: "showQuestionsAndAnswers", sender: indexPath);
            } else if indexPath.row == 1{
                print("隐私政策")
                let optionMenu = UIAlertController(title: "隐私政策", message: "1、默认情况下【SMSFilters】不会收集您的任何信息。\n2、如果您自愿提交样本，那么仅仅会收集脱敏后的短信文本以及一个您标注是否是垃圾短信的数字。\n3、提交的样本仅被用于训练和增强模型，不做其他用途。", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
                optionMenu.addAction(okAction)
                present(optionMenu, animated: true, completion: nil)
            } else if indexPath.row == 2 {
                print("向朋友推荐")
                let defaultText = "短信过滤，可能是第二好的垃圾短信智能过滤"
                let activityController: UIActivityViewController
                activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
                if let popoverController = activityController.popoverPresentationController {
                    if let cell = tableView.cellForRow(at: indexPath) {
                        popoverController.sourceView = cell
                        popoverController.sourceRect = cell.bounds
                    }
                }
                self.present(activityController, animated: true, completion: nil)
            } else if indexPath.row == 3 {
                print("给软件评分")
                let link = "https://github.com/qiwihui"
                if let url = URL(string: link) {
                    UIApplication.shared.open(url)
                }
            } else if indexPath.row == 4 {
                print("关于作者")
                let link = "https://github.com/qiwihui"
                if let url = URL(string: link) {
                    UIApplication.shared.open(url)
                }
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: 提交信息
    func submitSms(message: String, messageType: Int) {
        let header: HTTPHeaders = ["Content-Type":"application/json"]
        let parameters: Parameters = ["message":message,"type":messageType]
        Alamofire.request("http://api.qiwihui.com/v1/sms", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON(options: .mutableContainers) { (response) in
            print("=>")
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    if let result = response.result.value {
                        let JSON = result as! NSDictionary
                        let received = JSON["received"] as! Int
                        if received == 1 {
                            self.showToast(message: "提交成功")
                        }
                    }
                default:
                    print("error with response status: \(status)")
                }
            }else{
                print("??")
            }
        }
    }
    
    // MARK: 短信息
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQuestionsAndAnswers" {
            print("showQuestionsAndAnswers")
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let destinationController = segue.destination as! DetailTableViewController
//                destinationController.message = "ok"
//            }
        } else if segue.identifier == "editRules" {
            print("修改规则")
            let navController = segue.destination as! UINavigationController
            let ruleController = navController.viewControllers.first as! NewRuleTableViewController
            ruleController.ruleType = ruleType
            ruleController.navTitle = navTitle
        }
    }

}

// MARK: Previewing
extension MainViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "QAViewController") as? QAViewController else {
            return nil
        }
        
        // restaurantDetailViewController.message = "cool"
        detailViewController.preferredContentSize = CGSize(width: 0.0, height: 460.0)
        previewingContext.sourceRect = cell.frame
        return detailViewController
    }
    
}

