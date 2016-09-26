//
//  CommonUtils.swift
//  LiViD
//
//  Created by Mac Admin on 9/26/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import Foundation
import AVFoundation

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

func thumbnailForVideoAtURL(_ url: URL) -> UIImage? {
    
    let asset = AVAsset(url: url)
    let assetImageGenerator = AVAssetImageGenerator(asset: asset)
    
    var time = asset.duration
    time.value = min(time.value, 2)
    
    do {
        let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
        let thumbImage = UIImage(cgImage: imageRef)
        return thumbImage
    } catch {
        print("error")
        return nil
    }
}

class Alert: NSObject {
    
    class func Warning(_ delegate: UIViewController, message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
    
    
}

