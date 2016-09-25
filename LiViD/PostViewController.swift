//
//  PostViewController.swift
//  LiViD
//
//  Created by Matthew Carlson on 6/16/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    var Url : URL?
    var VideoData : Data?
    var friendsOrPublic : String?
    var DoUpload = true
    var DataPath : String?
    
    @IBOutlet weak var MyCitybttn: UIButton!
    @IBOutlet weak var Friendsbttn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(VideoData)
        self.f = false
        self.m = false
        print("transitioned", terminator: "")
        
        print(Url, terminator: "")
        // Do any additional setup after loading the view.
    }
    var f : Bool?
    var m : Bool?
    @IBAction func Friends(_ sender: AnyObject) {
        
        if f == false{
        
        friendsOrPublic = "Friends"
            
        Friendsbttn.setImage(UIImage(named: "friends2"), for: UIControlState())
        MyCitybttn.setImage(UIImage(named: "my_city2"), for: UIControlState())
        f == true
        } else if f == true {
        Friendsbttn.setImage(UIImage(named: "friends1"), for: UIControlState())
        MyCitybttn.setImage(UIImage(named: "my_city1"), for: UIControlState())
        f == false
        }else {
            Friendsbttn.setImage(UIImage(named: "friends1"), for: UIControlState())
            MyCitybttn.setImage(UIImage(named: "my_city2"), for: UIControlState())
            m == false
            f == false
        }
        print(f, terminator: "")
    }
    @IBAction func MyCity(_ sender: AnyObject) {
        if m == false {
        
        friendsOrPublic = "Public"
        MyCitybttn.setImage(UIImage(named: "my_city1"), for: UIControlState())
        Friendsbttn.setImage(UIImage(named: "friends1"), for: UIControlState())

        m == true
        } else if m == true {
        MyCitybttn.setImage(UIImage(named: "my_city2"), for: UIControlState())
        Friendsbttn.setImage(UIImage(named: "friends2"), for: UIControlState())

        m == false
        }else {
            Friendsbttn.setImage(UIImage(named: "friends1"), for: UIControlState())
            MyCitybttn.setImage(UIImage(named: "my_city2"), for: UIControlState())
            m == false
            f == false
        }
        print(m, terminator: "")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "submit") {
            
            let svc = segue.destination as! ViewController
            print("Variables saved", terminator: "")
            svc.videoData = VideoData
            svc.url = Url
            svc.doUpload = DoUpload
            svc.FriendsOrPublic = friendsOrPublic
            svc.dataPath = DataPath
        }
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
