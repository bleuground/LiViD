//
//  PlayVideoViewController.swift
//  LiViD
//
//  Created by Matthew Carlson on 6/22/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class PlayVideoViewController: UIViewController {
    @IBOutlet weak var PlayerView: UIView!
    
    @IBOutlet weak var streetofVideo: UILabel!
    @IBOutlet weak var timeofVideo: UILabel!
    @IBOutlet weak var userofPlayer: UILabel!
    var MP4 : Data?
    var MarkerLong : CLLocationDegrees?
    var MarkerLat : CLLocationDegrees?
    var Url : String?
    var videoPlayer : MPMoviePlayerController!
    var MarkerNum : Int?
    
    var userofVideo : AnyObject?
    var hour : AnyObject?
    var minutes : AnyObject?
    var streetname : AnyObject?
    
    fileprivate var firstAppear = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            do {
                try playVideo()
                firstAppear = false
            } catch AppError.invalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
            
        }
        var AP = "AM"
        var newHour = hour as! Int
        if newHour > 12 {
            newHour = newHour - 12
            AP = "PM"
        }else if newHour == 0 {
            newHour = 12
            AP = "AM"
        }
        let convertedTime = "\(newHour):\(minutes as! Int)\(AP)"
        userofPlayer.text = userofVideo as? String
        timeofVideo.text = convertedTime
        streetofVideo.text = streetname as! String
        
    }
    
    fileprivate func playVideo() throws {
        /*guard let path = NSBundle.mainBundle().pathForResource("video", ofType:"m4v") else {
         throw AppError.InvalidResource("video", "m4v")
         }*/
//        let player = AVPlayer(URL: NSURL(string: Url!)!)
//        let playerController = AVPlayerViewController()
//        playerController.player = player
//        self.presentViewController(playerController, animated: true) {
//            player.play()
//        }
        
        self.videoPlayer = MPMoviePlayerController()
        self.videoPlayer.repeatMode = MPMovieRepeatMode.none
        self.videoPlayer.contentURL = URL(string: Url!)
        self.videoPlayer.controlStyle = MPMovieControlStyle.none
        self.view.insertSubview(self.videoPlayer.view, at: 0)
        //self.view.addSubview(self.videoPlayer.view)
        //self.view.sendSubviewToBack(self.videoPlayer.view)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayVideoViewController.videoPlayBackDidFinish(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: self.videoPlayer)
        self.videoPlayer.view.frame.size = CGSize(width: 640, height: 1136)
        self.videoPlayer.view.center = self.view.center
        self.videoPlayer.play()
        print(self.videoPlayer.currentPlaybackTime.description)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PlayVideoViewController.someAction(_:)))
        self.videoPlayer.view.addGestureRecognizer(gesture)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func videoPlayBackDidFinish(_ notification:Notification)
    {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
        self.videoPlayer.stop()
        self.videoPlayer.view.removeFromSuperview()
        self.videoPlayer = nil
        performSegue(withIdentifier: "backtoHome", sender: self)
        
    }
    func someAction(_ sender:UITapGestureRecognizer){
        // do other task
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        self.videoPlayer.stop()
        print("stopped early")
        self.videoPlayer.view.removeFromSuperview()
        self.videoPlayer = nil
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "backtoHome") {
            let svc = segue.destination as! ViewController
            svc.x = MarkerNum
            
        }
    }

    
}

enum AppError : Error {
    case invalidResource(String, String)
}
