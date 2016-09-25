//
//  PlayBackViewController.swift
//  LiViD
//
//  Created by Matthew Carlson on 8/3/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer


class PlayBackViewController: UIViewController {
    var VideoData : Data?
    var DataPath : String?

    @IBOutlet weak var PlayerView: UIView!
    var player: AVPlayer!
    var avpController:AVPlayerViewController? = nil
    
    fileprivate var firstAppear = true

    
    override func viewDidAppear(_ animated: Bool) {
        
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
        
            
            
        
        // Do any additional setup after loading the view.
    }
    var MP4 : Data?
    var MarkerLong : CLLocationDegrees?
    var MarkerLat : CLLocationDegrees?
    var Url : URL?
    var videoPlayer : MPMoviePlayerController!
    var MarkerNum : Int?
    
    var userofVideo : AnyObject?
    var hour : AnyObject?
    var minutes : AnyObject?
    var streetname : AnyObject?

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
        self.videoPlayer.contentURL = Url
        self.videoPlayer.controlStyle = MPMovieControlStyle.none
        self.videoPlayer.repeatMode = MPMovieRepeatMode.one
        
        self.view.insertSubview(self.videoPlayer.view, at: 0)
        //self.view.addSubview(self.videoPlayer.view)
        //self.view.sendSubviewToBack(self.videoPlayer.view)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayVideoViewController.videoPlayBackDidFinish(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: self.videoPlayer)
        self.videoPlayer.view.frame.size = CGSize(width: 640, height: 1136)
        self.videoPlayer.view.center = self.view.center
        self.videoPlayer.play()
        print(self.videoPlayer.currentPlaybackTime.description)
        let gesture = UITapGestureRecognizer(target: self, action: "someAction:")
        self.videoPlayer.view.addGestureRecognizer(gesture)
        
    }
    
    @IBAction func Next(_ sender: AnyObject) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
        self.videoPlayer.stop()
        self.videoPlayer.view.removeFromSuperview()
        self.videoPlayer = nil

    performSegue(withIdentifier: "uploadSegue", sender: self)
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
        performSegue(withIdentifier: "uploadSegue", sender: self)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "uploadSegue") {
            let svc = segue.destination as! PostViewController;
            print("Variables saved")
            svc.VideoData = VideoData
            svc.Url = Url
            svc.DataPath = DataPath
            print(Url)
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
