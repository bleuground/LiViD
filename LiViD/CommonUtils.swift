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

extension UIImage{
    
    class func renderUIViewToImage(viewToBeRendered:UIView?) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions((viewToBeRendered?.bounds.size)!, false, 0.0)
        viewToBeRendered!.drawHierarchy(in: viewToBeRendered!.bounds, afterScreenUpdates: true)
        viewToBeRendered!.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
}

func mbSizeWithData(data: Data) -> String {
    let length = Double(data.count)/1024.0/1024.0
    return String(length) 
}

func imageByCroppingImage(image : UIImage, size : CGSize) -> UIImage{
    var refWidth : CGFloat = CGFloat(image.cgImage!.width)
    var refHeight : CGFloat = CGFloat(image.cgImage!.height)
    
    var x = (refWidth - size.width) / 2
    var y = (refHeight - size.height) / 2
    
    let cropRect = CGRect(x: x,y:  y, width: size.height,height: size.width)
    let imageRef = image.cgImage!.cropping(to: cropRect)
    
    let cropped : UIImage = UIImage(cgImage: imageRef!, scale: 0, orientation: image.imageOrientation)
    
    
    return cropped
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

class Alert: NSObject {
    
    class func Warning(_ delegate: UIViewController, message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
    
    
}

