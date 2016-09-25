//
//  SignUpViewController.swift
//  LiViD
//
//  Created by Matthew Carlson on 6/28/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit
import Parse
import AVKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var usrEntered : String?
    var pwdEntered : String?
    var emlEntered : String?
    
    @IBAction func SIgnUpButton(_ sender: AnyObject) {
        usrEntered = usernameTextField.text
        pwdEntered = passwordTextField.text
        emlEntered = emailTextField.text
        
        if usrEntered != "" && pwdEntered != "" && emlEntered != "" {
            userSignUp()

        } else {
            self.messageLabel.text = "All Fields Required"
        }
    }
    
    func userSignUp() {
        let user = PFUser()
        user.username = usrEntered
        user.password = pwdEntered
        user.email = emlEntered
        
        user.signUpInBackground {
            (succeeded: Bool?, error: Error?) -> Void in
            if error == nil {
                // Hooray! Let them use the app now.
                self.messageLabel.text = "User Signed Up";
                self.performSegue(withIdentifier: "loginUser", sender: nil)

            } else {
                self.messageLabel.text = "Username/Email already taken"

                // Show the errorString somewhere and let the user try again.
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.usernameTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
