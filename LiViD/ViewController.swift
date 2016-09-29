//  ViewController.swift
//  Livid
//
//  Created by Matthew Carlson on 4/30/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse
import MediaPlayer
import MobileCoreServices
import AVKit
import AVFoundation
import CoreLocation
import AddressBookUI
import MapKit
import AddressBook

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

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var viewMap: GMSMapView!
    var placesClient: GMSPlacesClient?
    
    var url : URL?
    var videoData : Data?
    var doUpload : Bool?
    var FriendsOrPublic : String?
    var dataPath : String?
    var gmsPlace : GMSPlace?
    var gpsCoordinates : CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    var x : Int?
    var z : Int?
    
    var street : String?
    var place : GMSPlace?
    var uploadedVideo : PFObject?
    
    @IBOutlet var searchBar: UISearchBar!
    
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apikey = "AIzaSyAWcaZdfxxi3ulpyRK__k-6gBU_9discX0"
    
    var markerLong : Double = 0.0
    var markerLat : Double = 0.0
    var file : PFFile?

    var marker : GMSMarker!
    var markers : [CLLocationCoordinate2D] = []
    var markersID : [String] = []
    let group: DispatchGroup = DispatchGroup();
    
    
    var mp4 : Data?
    var downloadedurl : String?
    
    var postsLat : Double?
    var postsLong : Double?
    var thumbnail : UIImage?
    var userofVideo : AnyObject?
    var hour : AnyObject?
    var minutes : AnyObject?
    var streetName : AnyObject?
    
    var tempLat : Double?
    var tempLong : Double?
    var tempCoordinates : CLLocationCoordinate2D?
    
    var location : CLLocation?
    var camera : GMSCameraPosition?
    
    var allIcons: [UIImage] = []
    
    @IBOutlet weak var Friends: UIButton!
    @IBOutlet weak var MyCity: UIButton!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
       // searchBar.delegate = self
        searchBar.showsSearchResultsButton = true
        searchBar.placeholder = "Your placeholder"
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
        print("ran!")
        self.view.sendSubview(toBack: viewMap)
        placesClient = GMSPlacesClient.shared()
        //getAddressForLatLng("37.331", longitude: "-122.031")
        var name : NSString
        name = "kooshesh"
        //let parameters : [NSObject : AnyObject]
        let parameters = ["TargetFriendID" : name]
        
        print(url)
        //print(videoData)
        print(doUpload)
        print(FriendsOrPublic)
        print(dataPath)
        if doUpload == true {
            Upload()
        }
        if FriendsOrPublic == nil {
            FriendsOrPublic = "Public"
            
            DownloadPublic()
        } else if FriendsOrPublic == "Public" {
            DownloadPublic()
        } else if FriendsOrPublic == "Friends" {
            DownloadFriends()
        } else {
            DownloadPublic()
            
        }
        
        setupLocation()
        
        //placesClient = GMSPlacesClient()
        var gmsPlace : GMSPlace?
        placesClient!.currentPlace { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            if let placeLikelihoods = placeLikelihoods {
                for likelihood in placeLikelihoods.likelihoods {
                    gmsPlace = likelihood.place
                    //print("Current Place name \(gmsPlace.name) at likelihood \(likelihood.likelihood)")
                    //print("Current Place address \(gmsPlace.formattedAddress)")
                    //print("Current Place attributions \(gmsPlace.attributions)")
                    //print("Current PlaceID \(gmsPlace.placeID)")
                    self.gpsCoordinates = (gmsPlace!.coordinate)
                    
                }
                //print(self.gpsCoordinates)
                
            }
        }
        
        viewMap.delegate = self
        if x != nil{
         self.x = 0
        } else {
            x = 0
        }
        group.notify(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high),
             execute: {
                print("dispatched")
                if self.z == 0{
                    
                
                self.viewMap.camera = GMSCameraPosition.camera(withTarget: self.markers[self.x!], zoom: 16.9)
                    print(self.markers.count)
                    if self.markers.count > 0 {
                        self.marker = GMSMarker(position: self.markers[0])
                        print(self.marker)
                        print(self.markers[0])
                        //self.downloadVideo(self.marker)
                    }
                    
                }else{
                    
                }
                
            });
        
        //viewMap.bringSubviewToFront(snapNext)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "playerSegue") {
            let svc = segue.destination as! PlayVideoViewController
            svc.MarkerLat = markerLat
            svc.MarkerLong = markerLong
            svc.MarkerNum = x!
            //svc.VideoData = videoData
            svc.Url = downloadedurl
            svc.MP4 = mp4
            svc.streetname = streetName
            svc.minutes = minutes
            svc.hour = hour
            svc.userofVideo = userofVideo
            
            print(url)
            
        }
    }

    var whatcity : String?
    func inNewport() -> Bool{
        return whatcity == "Newport Beach"
    }
}

//MARK: Maps and CLLocation
extension ViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var lat = manager.location!.coordinate.latitude as Double
        var long = manager.location!.coordinate.longitude as Double
        location = CLLocation(latitude: lat, longitude: long)
        
        // let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        gpsCoordinates = CLLocationCoordinate2DMake(lat.roundToPlaces(places: 6), long.roundToPlaces(places: 6))
        camera = GMSCameraPosition.camera(withTarget: gpsCoordinates!, zoom: 16.9)
        //let camera = GMSCamera
        print(camera)
        //viewMap = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        //self.view.insertSubview(viewMap, atIndex: 0)
        //viewMap.accessibilityElementAtIndex(0)
        //view.insertSubview(snapNext, aboveSubview: viewMap)
        viewMap.camera = camera!
        viewMap.isMyLocationEnabled = true
        viewMap.settings.myLocationButton = false
        
        /*let marker = GMSMarker()
         marker.position = self.gpsCoordinates!
         marker.title = "Newport Beach"
         marker.snippet = "California"
         marker.map = viewMap*/
        locationManager.stopUpdatingLocation()
        print(viewMap.delegate)
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                print(city)
                self.whatcity = city as String
                
            }
        })
    }

    func setupLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func areCoordinatesEqual(coordA: CLLocationCoordinate2D, coordB: CLLocationCoordinate2D) -> Bool {
        let latEquality = coordA.latitude == coordB.latitude
        let longEquality = coordA.longitude == coordB.longitude
        
        return latEquality && longEquality
    }
    
    func getIndexForMarker(marker: CLLocationCoordinate2D) -> Int {
        for index in 0...markers.count {
            if(areCoordinatesEqual(coordA: marker, coordB: markers[index])) {
                return index
            }
        }
        
        return 0
    }
    
    @objc(mapView:didTapMarker:) func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if z == 0 {
            print("\(marker) tapped")
            
            let lat = marker.position.latitude as Double
            let long = marker.position.longitude as Double
            
            
            let tempMarker = getMarkerForLongAndLat(long: long, lat: lat, markers: markers)
            let index = getIndexForMarker(marker: tempMarker)
            
            downloadVideo(self.markersID[index]) {
                PFFile in
                print(self.file)
                
                print("ran")
                if self.file != nil {
                    self.performSegue(withIdentifier: "playerSegue", sender: nil)
                    print("a")
                    self.file!.getDataInBackground(block: { (data, error) in
                        if error == nil
                        {
                            self.mp4 = data
                            print(data)
                            print(self.mp4)
                            print("a")
                        }
                    })
                    
                } else {
                    print("not dispatched")
                }
            }
        }
        
        /*
            let qualifierA = markers[x!].latitude.roundToPlaces(places: 6) == lat.roundToPlaces(places: 6)
            let qualifierB = markers[x!].longitude.roundToPlaces(places: 6) == long.roundToPlaces(places: 6)
            if (qualifierA && qualifierB)
            {
                downloadVideo(self.markersID[index]) {
                    PFFile in
                    print(self.file)
                    
                    print("ran")
                    if self.file != nil {
                        self.performSegue(withIdentifier: "playerSegue", sender: nil)
                        print("a")
                        self.file!.getDataInBackground(block: { (data, error) in
                            if error == nil
                            {
                                self.mp4 = data
                                print(data)
                                print(self.mp4)
                                print("a")
                            }
                        })
                        
                    } else {
                        print("not dispatched")
                    }
                }
            }
            
        } else {
            print("not equal")
        }
        */
        //markerLat = lat.roundToPlaces(6)
        //markerLong = long.roundToPlaces(6)
        //self.marker = GMSMarker(position: markers[2])
        
        
        return true
    }

}

//MARK: Actions
extension ViewController {
    @IBAction func MyCity(_ sender: AnyObject) {
        DownloadPublic()
    }

    
    @IBAction func Friends(_ sender: AnyObject) {
        DownloadFriends()
    }
    
    @IBAction func snapNext(_ sender: AnyObject) {
        if self.z != 1{
            x = x! + 1
            var count = markers.count
            print("This is the markers count: \(markers.count)")
            print(x)
            if x < markers.count {
                
                self.viewMap.camera = GMSCameraPosition.camera(withTarget: self.markers[x!], zoom: 16.9)
            } else {
                self.viewMap.camera = self.camera!
                x = 0
            }
            //viewMap.camera = marker.userData[0]
        }else{
            self.viewMap.camera = self.camera!
            
        }
        var count = 0
        if markers.count > 3 {
            while count < 3 {
                
                
                self.marker = GMSMarker(position: markers[x!])
                print(self.marker)
                print(markers[x!])
                //downloadVideo(marker)
                count = count + 1
                
                
            }
        }else if markers.count == 3 {
            
            
            
            self.marker = GMSMarker(position: markers[2])
            print(self.marker)
            print(markers[2])
            //downloadVideo(marker)
            self.marker = GMSMarker(position: markers[1])
            print(self.marker)
            print(markers[1])
            //downloadVideo(marker)
            self.marker = GMSMarker(position: markers[0])
            print(self.marker)
            print(markers[0])
            //downloadVideo(marker)
            
            
        }else if markers.count == 2{
            self.marker = GMSMarker(position: markers[1])
            print(self.marker)
            print(markers[1])
            //downloadVideo(marker)
            self.marker = GMSMarker(position: markers[0])
            print(self.marker)
            print(markers[0])
            //downloadVideo(marker)
            
            
        }else if markers.count == 1 {
            self.marker = GMSMarker(position: markers[0])
            print(self.marker)
            print(markers[0])
            //downloadVideo(marker)
        }else {
            
        }
        
        
    }
    

    @IBAction func tryPost(_ sender: AnyObject) {
        if inNewport() == true {
            performSegue(withIdentifier: "Post", sender: nil)
            
        } else {
            //   Alert.Warning(self,message: "Sorry, you cannot post from your current location at this time.")
            performSegue(withIdentifier: "Post", sender: nil)
            
        }
    }
    
    

}

//MARK: Network Operations
extension ViewController {
    func DownloadPublic() {
        viewMap.clear()
        //MyCity.image = UIImage(named: "")
        Friends.setImage(UIImage(named: "friendsbttn1"), for: UIControlState())
        MyCity.setImage(UIImage(named: "my_citybttn2"), for: UIControlState())
        let query = PFQuery(className:"UploadedVideoCurrent")
        
        self.group.enter();
        
        //        query.whereKey("GPS", equalTo: "ChIJTbSOh8Pf3IARt311y2Wqspc")
        query.whereKey("typeofPost", equalTo: "Public")
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                var y : Int = 0
                
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) coordinates.")
                // Do something with the found objects
                if objects!.count != 0 {
                    self.z = 0
                    if let objects = objects {
                        for object in objects {
                            
                            print(object.object(forKey: "GPS"))
                            let objectId = object.objectId! as String
                            var postsLat = (object.object(forKey: "GPS")! as AnyObject).latitude as Double
                            var postsLong = (object.object(forKey: "GPS")! as AnyObject).longitude as Double
                            let lat = postsLat.roundToPlaces(places: 6)
                            let long = postsLong.roundToPlaces(places: 6)
                            let position: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude:long)
                            
                            let markerTemp = GMSMarker(position: position)
//
//                            let image = UIImage(named: "bubble.png")
//                            let backIcon = UIImage(data: UIImagePNGRepresentation(image!)!, scale:
//                                5)
//                            
//                            markerTemp.icon = backIcon
//                        
                            let thumb = object.object(forKey: "Thumbnail") as! PFFile

                            thumb.getDataInBackground(block: { (imageData, error) in
                                if(imageData != nil) {
                                    let image = UIImage(data: imageData!)
                                 //   let resizedImage = resizeImage(image: image!, targetSize: CGSize(width: 30, height: 30))

                                 //   markerTemp.icon = resizedImage
                        
                                    
                                    let bubbleView = bubble(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 70, height: 70)))
                                    bubbleView.setThumbnailImage(image: image!)
                                    let final = UIImage.renderUIViewToImage(viewToBeRendered: bubbleView)
                                    
                                    markerTemp.icon = final
                                    markerTemp.map = self.viewMap
                                }
                            })
//
                            
                            
                            //self.thumbnail == object.objectForKey("GPS")! as! PFFile
                            /*if 1 == 1 {
                             self.thumbnail?.getDataInBackgroundWithBlock({
                             (imageData: NSData!, error: NSError!) -> Void in
                             if (error == nil) {
                             self.thumbnail = UIImage(data:imageData)
                             }
                             })
                             }*/
                            
                            if let userPicture = object.value(forKey: "GPS") as? PFFile {
                                userPicture.getDataInBackground {
                                    (imageData: Data?, error: Error?) -> Void in
                                    
                                    if error == nil {
                                        self.thumbnail = UIImage(data:imageData!)
                                        //self.ImageArray.append(image)
                                    }else{
                                        print("Error: \(error)")
                                    }
                                }
                            }
                            
                            //self marker.icon = [self image:marker.icon scaledToSize:CGSizeMake(3.0f, 3.0f)];
                            
                            self.markers.append(position)
                            self.markersID.append(objectId)
                            
                            markerTemp.map = self.viewMap
                            
                            y += 1
                            print(y)
                        }
                    }
                } else {
                    self.z = 1
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!._userInfo)")
            }
            self.group.leave();
            
        }
    }

    
    func fileSaved() {
        print("File has been saved")
        friendsOrPublic()
    }
    
    func friendsOrPublic() {
        if FriendsOrPublic == "Friends" {
            DownloadPublic()
        }else if FriendsOrPublic == "MyCity" {
            DownloadFriends()
        }else {
            DownloadPublic()
        }
    }
    
    func downloadVideo(_ markerID : String, completion: @escaping (PFFile) -> Void)
    {
        self.group.enter();
        
        print("printing")
        print(markerLat)
        print(markerLong)
        print(postsLat)
        print(postsLong)
        print("A")
        let query = PFQuery(className:"UploadedVideoCurrent")
        print("b")
        print(markerID)
        
        //query.whereKey("GPS", equalTo: PFGeoPoint(latitude: markerLat, longitude: markerLong))
        query.whereKey("objectId", equalTo: "\(markerID)")
        query.findObjectsInBackground { (objects, error) in
            print("c")
            if(error == nil)
            {
                print("d")
                
                for object in objects!
                {
                    
                    
                    print("made it")
                    
                    self.file = (object.object(forKey: "VideoFile") as! PFFile)
                    //self.thumbnail = (object.objectForKey("Thumbnail") as! PFFile)
                    self.userofVideo = object.object(forKey: "User") as AnyObject?
                    self.hour = object.object(forKey: "Hour") as AnyObject?
                    self.minutes = object.object(forKey: "minutes") as AnyObject?
                    self.streetName = object.object(forKey: "Location") as AnyObject?
                    print(self.file!.url)
                    print(self.file!)
                    self.downloadedurl = self.file!.url
                    
                    
                    self.tempLat = (object.object(forKey: "GPS")! as AnyObject).latitude as Double
                    self.tempLong = (object.object(forKey: "GPS")! as AnyObject).longitude as Double
                    
                    self.tempCoordinates = CLLocationCoordinate2D(latitude: self.tempLat! as CLLocationDegrees, longitude: self.tempLong! as CLLocationDegrees)
                    //print(tempLong)
                    //print(tempLat)
                    
                    //print(self.postsLong)
                    //print(self.postsLat)
                    //var coordinates = [postsLat, postsLong, x]
                }
                
            }
            else
            {
                print("didn't make it")
                print(error)
            }
            print(self.file)
            
            completion(self.file!)
            
        }
        
        self.group.leave();
        
    }
    
    func DownloadFriends() {
        viewMap.clear()
        Friends.setImage(UIImage(named: "friendsbttn2"), for: UIControlState())
        MyCity.setImage(UIImage(named: "my_citybttn1"), for: UIControlState())
        let query = PFQuery(className:"UploadedVideoCurrent")
        
        //        query.whereKey("GPS", equalTo: "ChIJTbSOh8Pf3IARt311y2Wqspc")
        query.whereKey("typeofPost", equalTo: "Friends")
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) coordinates.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        print(object.object(forKey: "GPS"))
                        var postsLat = (object.object(forKey: "GPS")! as AnyObject).latitude as Double
                        var postsLong = (object.object(forKey: "GPS")! as AnyObject).longitude as Double
                        let lat = postsLat.roundToPlaces(places: 6)
                        let long = postsLong.roundToPlaces(places: 6)
                        let position: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude:long)
                        
                        let markerTemp = GMSMarker(position: position)

                        
                        let thumb = object.object(forKey: "Thumbnail") as! PFFile
                        
                        thumb.getDataInBackground(block: { (imageData, error) in
                            if(imageData != nil) {
                                let image = UIImage(data: imageData!)
                                //   let resizedImage = resizeImage(image: image!, targetSize: CGSize(width: 30, height: 30))
                                
                                //   markerTemp.icon = resizedImage
                                
                                
                                let bubbleView = bubble(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 70, height: 70)))
                                bubbleView.setThumbnailImage(image: image!)
                                let final = UIImage.renderUIViewToImage(viewToBeRendered: bubbleView)
                                
                                markerTemp.icon = final
                                markerTemp.map = self.viewMap
                            }
                        })
//                        self.marker = GMSMarker(position: position)
//                        self.marker.icon = UIImage(named: "bubble.png")
//                        self.marker.map = self.viewMap
//                        
                        
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!._userInfo)")
            }
        }
    }

    func Upload() {
        
        let name = url!.lastPathComponent
        //let image = self.thumbnailForVideoAtURL(NSURL(string:name)!)
        let image = thumbnailForVideoAtURL(url!)
        
        //marker.icon = image
        
        
        placesClient!.currentPlace { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            /*let file = PFFile(name:"\(self.url)", data:self.videoData!)
             print(self.dataPath)
             print(path)*/
            print(name)
            
            let url = UserDefaults.standard.url(forKey: "videoURL")
            let videoData = try? Data(contentsOf: url!)
            
            var fileThumbnail : PFFile = PFFile(data: Data())!
            
            if let image =  image {
                let thumbnailData : Data = UIImageJPEGRepresentation(image, 1)!
                fileThumbnail = PFFile(name: "Thumbnail", data: thumbnailData)!
                fileThumbnail.saveInBackground()
            }
//            let thumbnailData : Data = UIImageJPEGRepresentation(image!, 1)!
            
            
            
//            print("UPLOADING VIDEO, FILE SIZE: " + mbSizeWithData(data: videoData!))
//            
//            let compressedVideoData = try? videoData!.compress(algorithm: CompressionAlgorithm.zlib)
//            
//            if let compressedData = compressedVideoData {
//                print("SECOND COMPRESSION: " + mbSizeWithData(data: compressedData!))
//                
//    
//            }
            let file = PFFile(name: name, data: videoData!)
//            let fileThumbnail = PFFile(name: "Thumbnail", data: thumbnailData)
//            fileThumbnail?.saveInBackground()
            var uploadedVideo : PFObject?
            if let placeLikelihoods = placeLikelihoods {
                for likelihood in placeLikelihoods.likelihoods {
                    self.place = likelihood.place
                    print("Current Place name \(self.place!.name) at likelihood \(likelihood.likelihood)")
                    print("Current Place address \(self.place!.formattedAddress)")
                    print("Current Place attributions \(self.place!.attributions)")
                    print("Current PlaceID \(self.place!.placeID)")
                    
                    print(self.url)
                }
                
                
                uploadedVideo = PFObject(className:"UploadedVideoCurrent")
                var lat = self.locationManager.location!.coordinate.latitude as Double
                var lon = self.locationManager.location!.coordinate.longitude as Double
                
                let latPost = lat.roundToPlaces(places: 6)
                let longPost = lon.roundToPlaces(places: 6)
                
                let date = Date()
                let calendar = Calendar.current
                let components = (calendar as NSCalendar).components([ .hour, .minute, .second], from: date)
                let hour = components.hour
                let minutes = components.minute
                var addressComponents: [String : String]?
                
                let geoCoder = CLGeocoder()
                let location = CLLocation(latitude: latPost, longitude: longPost)
                
                geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placemarks?[0]

                    
                    // Street address
                    if let streetaddress = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                        print(streetaddress)
                        self.street = streetaddress as String
                        uploadedVideo!["GPS"] = PFGeoPoint(latitude: latPost, longitude:longPost)
                        uploadedVideo!["VideoFile"] = file
                        uploadedVideo!["typeofPost"] = self.FriendsOrPublic
                        uploadedVideo!["Thumbnail"] = fileThumbnail
                        uploadedVideo!["User"] = PFUser.current()?.username
                        uploadedVideo!["Location"] = self.street
                        uploadedVideo!["Hour"] = hour
                        uploadedVideo!["minutes"] = minutes
                        print("gotthisfar")
                        uploadedVideo!.saveInBackground()
                        file!.saveInBackground { (success: Bool, error: Error?) -> Void in self.fileSaved()
                            
                        }
                    }
                    
                    // City
                    if let city = placeMark.addressDictionary!["City"] as? NSString {
                        print(city)
                        self.whatcity = city as String
                        
                    }
                })
            }
        }
    }
    
    
    //MARK: SEARCH

    func findLocationForPlacemark(placeMark: CLPlacemark) {

        
        let long: CLLocationDegrees = (placeMark.location?.coordinate.longitude)!
        let lat : CLLocationDegrees = (placeMark.location?.coordinate.latitude)!

        let camera = GMSCameraPosition.camera(withLatitude: lat,
                                              longitude: long, zoom: 12)
        viewMap.camera = camera

    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(text!) { (placemarks, error) in
            if((error) != nil) {
                print(error)
                self.present(Alert.invalidLocationAlert(), animated: true, completion: nil)
            } else if ((placemarks?.count)! > 0) {
                let placemark = placemarks?.last
                self.findLocationForPlacemark(placeMark: placemark!)
            }
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(text!) { (placemarks, error) in
            if((error) != nil || placemarks?.count == 0) {
                print(error)
                self.present(Alert.invalidLocationAlert(), animated: true, completion: nil)

            } else if ((placemarks?.count)! > 0) {
                let placemark = placemarks?.last
                self.findLocationForPlacemark(placeMark: placemark!)
            }
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}

