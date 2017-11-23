//
//  UserLocation.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/22/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager {
    
    let locationManager = CLLocationManager()
    var locations = [Location]()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                
                print("placemarks",placemarks!)
                let pm = placemarks?[0]
                self.fetchLocation(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func fetchLocation(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            
            print("your location is:-",containsPlacemark)
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            let state = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let location = Location(localityString: locality, countryString: country, stateString: state)
            locations.append(location)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
}
