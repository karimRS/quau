//
//  Offer.swift
//  PubliApp
//
//  Created by Karim on 30/09/15.
//  Copyright © 2015 Karim. All rights reserved.
//

import UIKit

class Offer: NSObject {
    
    var id: String
    var localId: String
    var title: String
    var area: String
    var descText: String
    var price: String
    var date: NSDate
    var endDate: NSDate
    var oldPrice: String
    var image: UIImage?
    var number: NSNumber
    var state: type
    var location: PFGeoPoint
    var address: String
    var localName: String
    var object: PFObject

    enum type {
        case Bought, Free, Out
    }
    
    init(with title: String, area: String, price: String, descText: String, oldPrice: String, date: NSDate, number: NSNumber, id: String, location: PFGeoPoint, address: String, endDate: NSDate, localName: String, object: PFObject, localId: String) {
        self.title = title
        self.area = area
        self.image = nil
        self.price = price
        self.descText = descText
        self.oldPrice = oldPrice
        self.date = date
        self.number = number
        self.id = id
        self.state = .Free
        self.location = location
        self.address = address
        self.endDate = endDate
        self.localName = localName
        self.object = object
        self.localId = localId
        
        super.init()
    }


}
