//
//  bubble.swift
//  
//
//  Created by Mac Admin on 9/26/16.
//
//

import UIKit

class bubble: UIView {

    var pictureImageView: UIImageView = UIImageView()
    
    @IBOutlet weak var thumbnailImage: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        addBubble()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setThumbnailImage(image: UIImage) {
        pictureImageView.image = image
        pictureImageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2));
    }
    
    func addBubble() {
        let bubbleImage = UIImage(named: "bubble")
        let bubbleImageView = UIImageView(frame: self.frame)
        bubbleImageView.image = bubbleImage
        bubbleImageView.contentMode = .scaleAspectFit
        addSubview(bubbleImageView)
        
        fitMethod()
        
        bubbleImageView.addSubview(self.pictureImageView)
    }
    
    func cropImage(img: UIImage) -> UIImage {
        let newImage = imageByCroppingImage(image: img, size: CGSize(width: 30, height: 30))
        return newImage
    }
    
    func fillMethod() {
        let origin = CGPoint(x: 0 , y: 5)
        let size = CGSize(width: 40, height: 60)
        let rect = CGRect(origin: origin, size: size)
        
        self.pictureImageView = UIImageView(frame: rect)
        self.pictureImageView.center = self.center
        self.pictureImageView.frame.origin.y -= 10
        self.pictureImageView.contentMode = .scaleAspectFit
    }
    
    func fitMethod() {
        let origin = CGPoint(x: 0 , y: 5)
        let size = CGSize(width: 40, height: 33)
        let rect = CGRect(origin: origin, size: size)
        
        self.pictureImageView = UIImageView(frame: rect)
        self.pictureImageView.center = self.center
        self.pictureImageView.frame.origin.y -= 10
        self.pictureImageView.contentMode = .scaleAspectFill
        self.pictureImageView.clipsToBounds = true
    }
    
}
