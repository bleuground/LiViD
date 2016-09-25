//
//  FriendsListViewController.swift
//  LiViD
//
//  Created by Matt Carlson on 9/20/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit
import Parse

class FriendsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    struct MyData {
        var userLabel:String
    }
    
    var tableData: [MyData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("this code ran")
        tableData = [
            MyData(userLabel: "Grew")
            
        ]
        PFCloud.callFunction(inBackground: "RetrieveFriends", withParameters: ["":""])
        {
            results, error in
            if error != nil{
                
            } else {
                print(results)
                
            }
        }
        print("this ran too")
 
        // Do any additional setup after loading the view.
    }
    
    
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a new cell with the reuse identifier of our prototype cell
        // as our custom table cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "myProtoCell") as! TableCellTableViewCell
        cell.friendsOutlet.text = tableData[indexPath.row].userLabel

        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
