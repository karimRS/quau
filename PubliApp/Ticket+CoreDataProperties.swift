//
//  Ticket+CoreDataProperties.swift
//  PubliApp
//
//  Created by Karim on 17/10/15.
//  Copyright © 2015 Karim. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Ticket {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var address: String?
    @NSManaged var price: String?
    @NSManaged var used: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var endDate: NSDate?

}
