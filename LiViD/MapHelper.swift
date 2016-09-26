//
//  MapHelper.swift
//  LiViD
//
//  Created by Mac Admin on 9/26/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit

protocol MapHelperDelegate {
    func mapHelperDidFinishLoading(mapHelper: MapHelper)
}

class MapHelper: NSObject {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var currentLocation: CLLocation = CLLocation()
    var locManager = CLLocationManager()
    var currentCity: String = ""
    var placeMarks : [CLPlacemark] = []
    var placeMark = CLPlacemark()
    
    var delegate: MapHelperDelegate?
    
    static let sharedMapHelper = MapHelper()
    
    private override init() {
        super.init()
        loadLongAndLat()
        getCurrentCity()
    }
    
    private func loadLongAndLat() {
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            currentLocation = locManager.location!
            latitude = (locManager.location?.coordinate.latitude)!
            longitude = (locManager.location?.coordinate.longitude)!
            
        }
    }
    
    private func getCurrentCity() {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placeMarks, error) in
            guard (placeMarks?[0]) != nil else {
                return
            }
            
            let placeMark = placeMarks?[0]
            
            // Location name
//            if let locationName = placeMark?.addressDictionary!["Name"] as? NSString {
//                print(locationName)
//            }
            
            // City
            if let city = placeMark?.addressDictionary!["City"] as? NSString {
                self.currentCity = city as String
            }
            
            self.delegate?.mapHelperDidFinishLoading(mapHelper: self)
        }
        
        
    }
}
