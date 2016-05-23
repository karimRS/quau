//
//  TicketViewController.swift
//  PubliApp
//
//  Created by Karim on 17/10/15.
//  Copyright © 2015 Karim. All rights reserved.
//

import UIKit
import CoreData

class TicketViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblDay: UILabel!
    @IBOutlet var lblHour: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var imgFix: UIImageView!
    @IBOutlet var imgMove: UIImageView!
    @IBOutlet var imgTrash: UIImageView!
    @IBOutlet var lblInfo: UILabel!
    
    var ticket: Ticket?
    var managedContext: NSManagedObjectContext!
    var initPos: CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Cupón"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ver", style: UIBarButtonItemStyle.Done, target: self, action: "viewOffer")

        let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        lblTitle.text = ticket?.name
        lblTitle.adjustsFontSizeToFitWidth = true
        lblAddress.text = ticket?.address
        if ticket!.price! == "0" {
            lblPrice.hidden = true
        }else {
            lblPrice.hidden = false
        }
        lblPrice.text = "Precio: " + ticket!.price! + "€"
        lblInfo.adjustsFontSizeToFitWidth = true
        lblPrice.adjustsFontSizeToFitWidth = true
        lblPrice.adjustsFontSizeToFitWidth = true
        lblHour.adjustsFontSizeToFitWidth = true
        lblDay.adjustsFontSizeToFitWidth = true
        lblAddress.adjustsFontSizeToFitWidth = true
        
        lblInfo.text = "Muestra el cupón al camarero, y arrástralo hasta el recuadro para canjearlo."
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = "dd"
        let strDay = dateFormatter.stringFromDate(ticket!.date!)
        
        dateFormatter.dateFormat = "MMMM"
        var strMonth = dateFormatter.stringFromDate(ticket!.date!)
        strMonth.replaceRange(strMonth.startIndex...strMonth.startIndex, with: String(strMonth[strMonth.startIndex]).capitalizedString)
        
        dateFormatter.dateFormat = "eeee"
        var strDayName = dateFormatter.stringFromDate(ticket!.date!)
        strDayName.replaceRange(strDayName.startIndex...strDayName.startIndex, with: String(strDayName[strDayName.startIndex]).capitalizedString)

        
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        let strHour = dateFormatter.stringFromDate(ticket!.date!)
        let strEndHour = dateFormatter.stringFromDate(ticket!.endDate!)
        
        lblDay.text = strDayName + " " + strDay + " de " + strMonth
        lblHour.text = "De " + strHour + " a " + strEndHour
        
        imgMove.userInteractionEnabled = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("gestureRecognizerMethod:"))
        panGestureRecognizer.delegate = self
        
        initPos = self.imgMove.center
        
        if ticket?.used == true {
            
            self.navigationItem.rightBarButtonItem?.enabled = false
            imgMove.hidden = true
        }else {
            self.navigationItem.rightBarButtonItem?.enabled = true
            imgMove.hidden = false
            imgMove.addGestureRecognizer(panGestureRecognizer)

            
        }

        
    }

    func gestureRecognizerMethod(recognizer: AnyObject){
        
        if (recognizer.state == .Began || recognizer.state == .Changed )
        {
            //show path
            self.imgMove.center = recognizer.locationInView(self.view)
            
        }
        if recognizer.state == .Ended {
            
            //hide path
            
            if imgTrash.frame.contains(recognizer.locationInView(self.view)) {
                
                validation()
                
            }else {
                self.imgMove.center.y = self.imgFix.center.y
                self.imgMove.center.x = initPos.x - 4
                
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func validation() {
        
        if ticket?.used == false {
            
         
        
        switch onTime((ticket?.date)!, endDate: (ticket?.endDate)!) {
            
        case 0:
            
            if #available(iOS 8.0, *) {
            
            let alertController = UIAlertController(title: "Quau", message: "Aún es pronto para usar el cupón", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            }else {
                
                let alert = UIAlertView(title: "Quau", message: "Aún es pronto para usar el cupón", delegate: self, cancelButtonTitle: "OK")
                
                alert.show()
                

            }
            self.imgMove.center.y = self.imgFix.center.y
            self.imgMove.center.x = initPos.x - 4

        case 1:
            
            ticket?.setValue(true, forKey: "used")
            
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            self.imgMove.hidden = true

            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! { // loop through notifications...
                if (notification.userInfo!["UUID"] as! String == ticket!.id!) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                    UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                    break
                }
            }
            
            let track = ["localName": ticket!.name!]
            
            // Send the dimensions to Parse along with the 'search' event
            PFAnalytics.trackEvent("VALIDATION", dimensions: track)
            
            self.navigationController?.popToRootViewControllerAnimated(true)

            
        case 2:
            
            if #available(iOS 8.0, *) {

            let alertController = UIAlertController(title: "Quau", message: "Este cupón ha caducado", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            }else{
                
                let alert = UIAlertView(title: "Quau", message: "Este cupón ha caducado", delegate: self, cancelButtonTitle: "OK")
                
                alert.show()
                
            }
            self.imgMove.hidden = true
            
            self.navigationController?.popToRootViewControllerAnimated(true)

        default:
            if #available(iOS 8.0, *) {

            
            let alertController = UIAlertController(title: "Quau", message: "Error", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
                }
            }
            self.imgMove.center.y = self.imgFix.center.y
            self.imgMove.center.x = initPos.x - 4
            
        }
        }
        
    }
    
    func viewOffer() {
        self.performSegueWithIdentifier("viewOffer_segue", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "viewOffer_segue" {
            
            let svc = segue.destinationViewController as? GetDetailViewController
            
            svc!.objectId = (ticket!.id! as? NSString)!.substringToIndex(ticket!.id!.characters.count - 16)
            
        }
        
    }
    
    
}
