//
//  Place.swift
//  PubliApp
//
//  Created by Karim on 17/10/15.
//  Copyright © 2015 Karim. All rights reserved.
//

import Foundation
import MapKit
import AddressBook
import Contacts

class Place: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    func mapItem() -> MKMapItem {
        
        if #available(iOS 9.0, *) {
            let addressDictionary = [String(CNPostalAddressStreetKey): subtitle!]
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = title
            return mapItem

            
        } else {
            let addressDictionary = [String(kABPersonAddressStreetKey): subtitle!]
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = title
            return mapItem

        }
        
    }
}