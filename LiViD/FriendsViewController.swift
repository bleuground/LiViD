//
//  FriendsViewController.swift
//  LiViD
//
//  Created by Matthew Carlson on 7/7/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit
import Parse
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class FriendsViewController: UIViewController, UITextFieldDelegate{
    
    

    
 
    @IBOutlet weak var NewRequest: UITextField!
    @IBOutlet weak var FriendsAdded: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        //getFriends()
        
        self.NewRequest.delegate = self
        
        

        

        
        //get user value from calling a query for all users
        
        
        

        // Do any additional setup after loading the view.
    }
    

/*
        query?.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: Error?) -> Void in
            if let objects = objects {
            for object in objects {

            print("name:")
            print(object.objectForKey("username"))
            self.username = object.objectForKey("username")! as! String
                
            self.z = 1
                

            }
            }
            dispatch_group_leave(self.group)

        }
        */

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == NewRequest {
            textField.resignFirstResponder()
            print(NewRequest, terminator: "")
            var name : NSString
            name = NewRequest.text! as NSString
            print(name, terminator: "")
            //let parameters : [NSObject : AnyObject]
            let params = ["username" : name]
            
            PFCloud.callFunction(inBackground: "AddFriendRequest", withParameters: params) { results, error in
                if error != nil {
                    //Your error handling here
                } else {
                    print(results)
                }
            }
            
            return false
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
