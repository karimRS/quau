//
//  Utils.swift
//  PubliApp
//
//  Created by Karim on 17/10/15.
//  Copyright © 2015 Karim. All rights reserved.
//

import Foundation
import CoreData
import SystemConfiguration



//MARK: COINS
func updateCoins() {
    
    let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = appDelegate.managedObjectContext
    
    var coin :[Coin] = []
    coin = []
    
    let fetchRequest = NSFetchRequest(entityName: "Coin")
    
    do {
        coin = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Coin]
    } catch let error as NSError {
        
        // failure
        print("Fetch coins failed: \(error.localizedDescription)")
    }
    
    if coin != [] {
        
        let n = daysBetweenDate(coin[0].updateAt!, toDateTime: getToday())
        if (n > 5) || (n < -5) {
        
            let query = PFQuery(className: "Coins")
            query.getFirstObjectInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil {
                    
                    
                    if let n = objects!["number"] as? NSNumber {
                        
                      
                        coin[0].setValue(n, forKey: "number")
                        coin[0].setValue(getToday(), forKey: "updateAt")
                        
                        print("Successful retrieved Coins from Parse")
                        do {
                            try managedObjectContext.save()
                            print("Coins renovated")
                            
                        } catch {
                            print("Unresolved error updating coins")
                            abort()
                        }
                        
                    }
                    
                } else {
                    print("Error load from Parse")
                }
            })
            
    }
    
    }else {
        
        print("First time")
        
        fillCoins()
    }
    
    print("Coins updated")
    
}

    
func checkCoins() -> Bool {
    
    let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = appDelegate.managedObjectContext
    
    var coin :[Coin] = []
    
    let fetchRequest = NSFetchRequest(entityName: "Coin")
    
    do {
        coin = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Coin]
    } catch let error as NSError {
        // failure
        print("Fetch coins failed: \(error.localizedDescription)")
    }
    
    if coin != [] {
        
        if coin[0].number?.intValue > 0{
            print("Enough coins")
            return true
        }
    }
    
    print("Not enough coins")
    return false
    
}


func subCoin() {
    
    let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = appDelegate.managedObjectContext
    
    var coin :[Coin] = []
    
    let fetchRequest = NSFetchRequest(entityName: "Coin")
    
    do {
        coin = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Coin]
    } catch let error as NSError {
        
        // failure
        print("Fetch coins failed: \(error.localizedDescription)")
    }
    
    if coin != [] {
        
        let n = (coin[0].number?.integerValue)! - 1
        
        coin[0].setValue(NSNumber(integer: n), forKey: "number")
        
        do {
            try managedObjectContext.save()
            print("Coins sub")
            
        } catch {
            print("Unresolved error sub coins")
            abort()
        }

    }else {
        print("Error getting coins")
        
    }
    
    }


func getCoins() -> Int {
    print("Getting coins...")

    let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = appDelegate.managedObjectContext
    
    var coin :[Coin] = []
    
    let fetchRequest = NSFetchRequest(entityName: "Coin")
    
    do {
        coin = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Coin]
    } catch let error as NSError {
        
        // failure
        print("Fetch coins failed: \(error.localizedDescription)")
    }
    
    if coin != [] {
        
        return (coin[0].number?.integerValue)!
    }else {
        print("Error getting coins")
        return 0

        
    }
}


func fillCoins() {
        
        let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
    
        let coin = NSEntityDescription.insertNewObjectForEntityForName("Coin", inManagedObjectContext: managedObjectContext) as? Coin
    
    let query = PFQuery(className: "Coins")
    query.getFirstObjectInBackgroundWithBlock({ (objects, error) -> Void in
        if error == nil {
            
            
            if let n = objects!["number"] as? NSNumber {
                
                coin?.number = n
                coin?.updateAt = getToday()
                print("Successful retrieved Coins from Parse")

                do {
                    try managedObjectContext.save()
                    
                } catch {
                    abort()
                }

            }
            
            
            
        } else {
            
            
            print("Error load from Parse")
        }
    })
    
}

//MARK: DATES

func daysBetweenDate(fromDateTime: NSDate, toDateTime: NSDate) -> Int {
    
    var fromDate: NSDate?
    var toDate: NSDate?
    
    let calendar = NSCalendar.currentCalendar()
    
    calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: fromDateTime)
    calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: toDateTime)
    
    let diff = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: .MatchFirst)
    
    return diff.day
    
}

func isMonday() -> Bool {

    let day = NSCalendar.currentCalendar().components(.Weekday, fromDate: getToday()).weekday

    if day == 2 {
        return true
    } else{
    return false
    }
    

}

func onTime(startTime: NSDate, endDate: NSDate) -> Int {
    
    if getToday().compare(startTime) == NSComparisonResult.OrderedAscending {
        
        // Too early
        return 0
    }
    
    if getToday().compare(endDate) == NSComparisonResult.OrderedDescending {
        
        // Too late
        return 2
    }
    
    if getToday().compare(startTime) == NSComparisonResult.OrderedDescending && getToday().compare(endDate) == NSComparisonResult.OrderedAscending {
        // On time
        return 1
    }
    
    return 1
}

func getToday() -> NSDate {
    
    let sourceDate = NSDate()
    let sourceTimeZone = NSTimeZone(abbreviation: "GMT")
    let destinationTimeZone = NSTimeZone.systemTimeZone()
    let sourceGMTOffset = sourceTimeZone?.secondsFromGMTForDate(sourceDate)
    let destinationGMTOffset = destinationTimeZone.secondsFromGMTForDate(sourceDate)
    let interval = NSTimeInterval(destinationGMTOffset - sourceGMTOffset!)
    let destinationDate = NSDate(timeInterval: interval, sinceDate: sourceDate)
    
    return destinationDate
    
}

func transfDate(date: NSDate) -> NSDate {
    
    let sourceDate = date
    let sourceTimeZone = NSTimeZone(abbreviation: "GMT")
    let destinationTimeZone = NSTimeZone.systemTimeZone()
    let sourceGMTOffset = sourceTimeZone?.secondsFromGMTForDate(sourceDate)
    let destinationGMTOffset = destinationTimeZone.secondsFromGMTForDate(sourceDate)
    let interval = NSTimeInterval(destinationGMTOffset - sourceGMTOffset!)
    let destinationDate = NSDate(timeInterval: interval, sinceDate: sourceDate)
    
    return destinationDate
    
}


//MARK: Localization
func checkPermission() -> Int {
    
    if(CLLocationManager.locationServicesEnabled()){
        
        switch CLLocationManager.authorizationStatus() {
            
        case .AuthorizedWhenInUse:
            return 1
        case.Denied:
            return 2
        default:
            return 0
            
        }
        
    }
    return 0
}


func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
        SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
}


/*
func setBadgeNumbers() {
    let notifications = UIApplication.sharedApplication().scheduledLocalNotifications! // all scheduled notifications
    
    // var list = ticketsArray.filter({$0.used! == false && (NSDate().compare($0.endDate!.dateByAddingTimeInterval(-2*60*60)) == .OrderedDescending)})
    
    let array = auxFetchTickets()
    
    for notification in notifications {
        let overdueItems = array.filter({ (todoItem) -> Bool in // array of to-do items...
            return (todoItem.endDate!.dateByAddingTimeInterval(-2*60*60).compare(notification.fireDate!) != .OrderedDescending) // ...where item deadline is before or on notification fire date
        })
        UIApplication.sharedApplication().cancelLocalNotification(notification) // cancel old notification
        notification.applicationIconBadgeNumber = overdueItems.count // set new badge number
        UIApplication.sharedApplication().scheduleLocalNotification(notification) // reschedule notification
    }
    if notifications == [] {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
}

func auxFetchTickets() -> [Ticket] {
    
    let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    var res: [Ticket]!
    let fetchRequest = NSFetchRequest(entityName: "Ticket")
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    do {
        res = try managedContext.executeFetchRequest(fetchRequest) as? [Ticket]
    } catch let error as NSError {
        // failure
        res = []
        print("Fetch failed: \(error.localizedDescription)")
    }
    
    for tic in res.reverse() {
        
        if (onTime(tic.date!, endDate: tic.endDate!) == 2) {
            
            tic.used = true
            tic.setValue(true, forKey: "used")
            
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
        }
        
        if tic.used == true {
            
            res.removeAtIndex(res.indexOf(tic)!)
            res.append(tic)
            
        }
        
    }
    return res
    
}

*/

