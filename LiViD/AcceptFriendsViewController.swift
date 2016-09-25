//
//  AcceptFriendsViewController.swift
//  LiViD
//
//  Created by Matt Carlson on 9/20/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit
import Parse

class AcceptFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct MyData {
        var userLabel:String
    }
    @IBOutlet weak var table: UITableView!
    
    var tableData: [MyData] = []

    var y : Int?
    var z : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableData = [
            MyData(userLabel: "Grew")
            
        ]
        z = 0
        y = 0
        getFriends()
        /*
        var user : NSString
        user = "R84xWXzbPN"
        let paramsAccept = ["TargetFriend" : user]
        PFCloud.callFunction(inBackground: "AcceptFriendRequest", withParameters: paramsAccept) { results, error in
            if error != nil {
                print(error)
            } else {
                print(results)
                if results as! Int == 1 {
                    //Append Friends class
                    print("Friend Successfully added")
                }
            }
        }*/
        
        self.group.notify(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high),
                          execute: {
                            
                                print("dispatched")
                                //print(self.ID.count)
                                while self.y! < self.ID.count
                                {
                                    print("\(self.y)'s value is: \(self.ID[self.y!])")
                                    self.ID2Username("\(self.ID[self.y!])")
                                    
                                    self.y = self.y! + 1
                                    
                                }
                            
        })
        

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var ID : [AnyObject] = []
    
    func getFriends() {
        self.group.enter()
        
        var query = PFQuery(className:"FriendsIncoming")
        query.whereKey("TargetFriend", equalTo: PFUser.current()!.objectId!)
        query.whereKey("OwnerID", notEqualTo: PFUser.current()!)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if let objects = objects {
                print("we ran/")
                for object in objects {
                    
                    self.z = 0
                    self.ID.append(object.object(forKey: "OwnerID")! as AnyObject)
                    print(self.ID.count)
                    
                    
                    
                    
                }
                self.group.leave()

            }
            
            
        }
        
    }

    let group: DispatchGroup = DispatchGroup();
    var usernames : [AnyObject] = []
    
    func ID2Username(_ userID : String) {
        
        print("ran")
        //dispatch_group_enter(self.group)
        //var query = PFQuery(className:"User")
        var query = PFUser.query()
        
        print(userID)
        query!.getObjectInBackground(withId: userID) {
            (user: PFObject?, error: Error?) -> Void in
            print(user!.object(forKey: "username")! as! String)

            self.tableData.append(MyData(userLabel:("\(user!.object(forKey: "username")!)" as AnyObject) as! String))
        }
        print("this code ran")
        
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a new cell with the reuse identifier of our prototype cell
        // as our custom table cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "myProtoCell") as! TableCellTableViewCell
        cell.newUser.text = tableData[indexPath.row].userLabel
        
        
        return cell
    }
}
