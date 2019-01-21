//
//  QATableViewController.swift
//  SMSFilters
//
//  Created by Qiwihui on 1/21/19.
//  Copyright © 2019 qiwihui. All rights reserved.
//

import UIKit

class QA {
    var question: String
    var answer: String
    
    init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
    
    convenience init() {
        self.init(question: "", answer: "")
    }
}

class QATableViewController: UITableViewController {
    
    var qas: [QA] = [
        QA(question: "iOS 的短信过滤规则是怎样的？", answer: """
当满足以下任意一个条件时，iOS 就不会将收到的短信交给本软件判断：
1. 发件人在您的通讯录中。
2. 您曾经给该号码发送过至少3条短信。
3. 不能过滤 iMessage 信息。
"""),
        QA(question: "为何垃圾短信屏蔽后短信依然会提示数字？", answer: """
这是系统的设计，无法修改。
"""),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "常见问题"
        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return qas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "qaCell", for: indexPath)
        
        cell.textLabel?.text = qas[indexPath.row].question
        cell.detailTextLabel?.text = qas[indexPath.row].answer
        cell.detailTextLabel?.numberOfLines = 0

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: 关闭
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

}
