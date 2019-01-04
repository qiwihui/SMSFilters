//
//  QAViewController.swift
//  SMSFilters
//
//  Created by Qiwihui on 12/29/18.
//  Copyright © 2018 qiwihui. All rights reserved.
//

import UIKit

class QAViewController: UIViewController {
    
    @IBOutlet var qaTextView: UITextView!
    var message = "..........."

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        qaTextView.text = message
        qaTextView.isEditable = false
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
