//
//  LogInViewController.swift
//  LiViD
//
//  Created by Matthew Carlson on 6/28/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit
import Parse
import Foundation

class LogInViewController: UIViewController, UITextFieldDelegate {
    let service = "swiftLogin"
    let userAccount = "swiftLoginUser"
    let key = "RandomKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        let currentUser = PFUser.current()
        
        
        if currentUser != nil {
            //self.storyboard?.instantiateViewControllerWithIdentifier("ProfileSettingsViewController")
            self.performSegue(withIdentifier: "logInUser", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func logInActionButton(_ sender: AnyObject) {
        if usernameTextField.text != "" && passwordTextField.text != "" {
            PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error == nil
                {
                    print(user?.email)
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "logInUser", sender: nil)
                    })
                }
                else
                {
                    self.messageLabel.text = "Invalid username/password"
                    print("user doesnt exist")
                }
            }
            //not empty, do something
        } else {
            //empty, notify user
            self.messageLabel.text = "All Fields Required"
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
