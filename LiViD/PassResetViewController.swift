//
//  PassResetViewController.swift
//  LiViD
//
//  Created by Matthew Carlson on 9/26/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit
import Parse

class PassResetViewController: UIViewController {

    @IBOutlet weak var usersEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if usersEmail != nil {
            PFUser.requestPasswordResetForEmail(inBackground: usersEmail.text!)

        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
