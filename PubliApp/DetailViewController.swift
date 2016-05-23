//
//  DetailViewController.swift
//  PubliApp
//
//  Created by Karim on 26/09/15.
//  Copyright © 2015 Karim. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class DetailViewController: UIViewController, CLLocationManagerDelegate, UIAlertViewDelegate {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var txtDesc: UITextView!
    @IBOutlet var btnBuy: UIButton!
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblDay: UILabel!
    @IBOutlet var lblHour: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    var locationManager: CLLocationManager?
    var offer: Offer?
    var offerObj: PFObject?
    let regionRadius: CLLocationDistance = 850
    var managedContext: NSManagedObjectContext!
    var imgLoad = UIImage(named: "square")
    var maincolor: UIColor = UIColor(red:0.97, green:0.35, blue:0.18, alpha:1.0)

    var strTitle: NSMutableAttributedString!
    var fontName: String = "SFUIDisplay-Medium"
    let loadingView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
       // let swipe = UISwipeGestureRecognizer(target: self, action: "dismiss:")
        //swipe.direction = .Down
       // lblTitle.userInteractionEnabled = true
     //   lblTitle.addGestureRecognizer(swipe)
        loadingView.frame = self.view.bounds
        let actind = UIActivityIndicatorView()
        actind.startAnimating()
        actind.color = UIColor.whiteColor()
        actind.center = self.view.center
        loadingView.addSubview(actind)
        loadingView.backgroundColor = UIColor(colorLiteralRed: 0.30, green: 0.30, blue: 0.30, alpha: 0.5)
        
        if offer?.image == nil {
            self.loadElements(self.offer!, image: imgLoad!)
            getImage()
        }else {
            
            loadElements(offer!, image: offer!.image!)
        }
        
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        if #available(iOS 8.0, *) {
            self.locationManager?.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        
        let initialLocation = CLLocation(latitude: (offer?.location.latitude)!, longitude: (offer?.location.longitude)!)
        
        let place = Place(title: (offer?.localName)!,
            locationName: (offer?.address)!,
            coordinate: CLLocationCoordinate2D(latitude: (offer?.location.latitude)!, longitude: (offer?.location.longitude)!))
        
        mapView.delegate = self
        mapView.addAnnotation(place)
        centerMapOnLocation(initialLocation)
        mapView.selectAnnotation(place, animated: true)
        mapView.showsUserLocation = true

    }

    
    override func viewDidAppear(animated: Bool) {
        
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "fromBackground", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        if checkPermission() == 2 {
            
            if #available(iOS 8.0, *) {

            let alertController = UIAlertController(title: "Permisos de localización denegados", message: "", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "Más tarde", style: .Cancel) { (action) in
                
            }
            
            let settingsAction = UIAlertAction(title: "Ir a Ajustes", style: .Default) { (action) in
                
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                
            }
            alertController.addAction(settingsAction)
            alertController.addAction(OKAction)


            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            }else{
                
                let alert = UIAlertView(title: "Quau", message: "Permisos de localización denegados, ve a Ajustes", delegate: self, cancelButtonTitle: "OK")
                
                alert.show()
            }

        }
        
        
        
    }
   /*
    func fromBackground() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        getOffer()
        
        if offer?.image != nil {
        loadElements(offer!, image: offer!.image!)
        }
        

    }
    */
    
    func getImage() {
        

        offer?.object["image"]!.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                
                if UIImage(data:imageData!) != nil {
                    let img = UIImage(data:imageData!)
                    self.offer!.image = img
                    self.loadElements(self.offer!, image: img!)
                }
                
            }
        })

        
    }
    
    func loadElements(offer :Offer, image: UIImage) {
        
        lblTitle.font = UIFont(name: fontName, size: 22)
        lblTitle.adjustsFontSizeToFitWidth = true
        lblTitle.numberOfLines = 2
        
        btnBuy.titleLabel?.font = UIFont(name: "SFUIDisplay-Medium", size: 25)
        
        txtDesc.font = UIFont(name: fontName, size: 15)
        txtDesc.layoutIfNeeded()
        
        let price = NSMutableAttributedString(string: offer.price + "€")
        
        price.addAttribute(NSForegroundColorAttributeName, value: maincolor, range: NSMakeRange(0, price.length))
        
        strTitle = NSMutableAttributedString(string: offer.title)
        
        let space = NSMutableAttributedString(string: " - ")
        space.appendAttributedString(price)
        if offer.price != "0" {
            strTitle.appendAttributedString(space)
        }
        
        
        lblTitle.attributedText = strTitle
        txtDesc.text = offer.descText
        
        txtDesc.sizeToFit()
        txtDesc.layoutIfNeeded()
        
        mainImage.image = image
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = "dd"
        let strDay = dateFormatter.stringFromDate(offer.date)
        
        dateFormatter.dateFormat = "MMMM"
        var strMonth = dateFormatter.stringFromDate(offer.date)
        strMonth.replaceRange(strMonth.startIndex...strMonth.startIndex, with: String(strMonth[strMonth.startIndex]).capitalizedString)
        
        dateFormatter.dateFormat = "eeee"
        var strDayName = dateFormatter.stringFromDate(offer.date)
        strDayName.replaceRange(strDayName.startIndex...strDayName.startIndex, with: String(strDayName[strDayName.startIndex]).capitalizedString)

        dateFormatter.dateFormat = "HH:mm"
        let strHour = dateFormatter.stringFromDate(offer.date)
        let strEndHour = dateFormatter.stringFromDate(offer.endDate)
        
        lblDay.text = strDayName + " " + strDay + " de " + strMonth
        lblHour.text = "De " + strHour + " a " + strEndHour
        lblAddress.text = offer.localName + " en " + offer.address
        
        if offer.state != .Bought {
        
        if offer.number.integerValue < 1 {
            offer.state = .Out
        }else{
            offer.state = .Free
        }
            
        }

        
        switch offer.state {
            
        case .Free :
            btnBuy.setTitle("¡Quiero este cupón!", forState: .Normal)
            btnBuy.setTitleColor(maincolor, forState: .Normal)
            btnBuy.enabled = true
            
        case .Bought :
            btnBuy.setTitle("Comprado", forState: .Normal)
            btnBuy.enabled = false
            
        case .Out :
            btnBuy.setTitle("Agotados", forState: .Normal)
            btnBuy.enabled = false
            
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    
    @IBAction func backBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
  
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 1.0, regionRadius * 1.0)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.regionThatFits(coordinateRegion)

    }
    
    //MARK: BUY Ticket
    @IBAction func pressBtn(sender: AnyObject) {
        
        if offer?.state == .Free {
            
            updateCoins()
            
            if checkCoins() == false {
                if #available(iOS 8.0, *) {

                let alertController = UIAlertController(title: "Quau", message: "No puedes comprar más cupones esta semana", preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
                }else{
                    let alert = UIAlertView(title: "Quau", message: "No puedes comprar más cupones esta semana", delegate: self, cancelButtonTitle: "OK")
                    
                    alert.show()
                }
                
            }else {
                
                if getToday().compare((offer?.endDate)!) == NSComparisonResult.OrderedDescending {
                    
                    if #available(iOS 8.0, *) {

                    let alertController = UIAlertController(title: "Quau", message: "La oferta ha acabado", preferredStyle: .Alert)
                    
                    let OKAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
                        self.performSegueWithIdentifier("buy_segue", sender: self)

                    }
                 
                    alertController.addAction(OKAction)
                    
                    
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                    }else{
                        
                        let alert = UIAlertView(title: "Quau", message: "La oferta ha acabado", delegate: self, cancelButtonTitle: "OK")
                        
                        alert.show()
                        
                        self.performSegueWithIdentifier("buy_segue", sender: self)

                    }

                    
                    
                }else{
                
                    if #available(iOS 8.0, *) {

                        
                        if isConnectedToNetwork() == false {
                            
                            let alertController = UIAlertController(title: "Quau", message: "No hay una conexión a internet 🤕, desliza hacia abajo para intentarlo de nuevo", preferredStyle: .Alert)
                            
                            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                                
                            }
                            alertController.addAction(OKAction)
                            
                            self.presentViewController(alertController, animated: true) {
                                // ...
                            }
                            
                            
                        }else {
                    
                let alertController = UIAlertController(title: "Quau", message: "¿Quieres este cupón?", preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: "Sí", style: .Default) { (action) in
                    
                    self.view.addSubview(self.loadingView)
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    self.checkNumber()
                }
                let NoAction = UIAlertAction(title: "No", style: .Cancel) { (action) in
                    
                }
                alertController.addAction(NoAction)
                alertController.addAction(OKAction)

                
                self.presentViewController(alertController, animated: true) {
                    // ...
                        }
                        
                        }
                        
                        
                        
                    }else {
                        
                        let alert = UIAlertView(title: "Quau", message: "¿Quieres este cupón?", delegate: self, cancelButtonTitle: "Sí")
                        alert.addButtonWithTitle("No")
                        
                        alert.show()
                    }
                    
                
            }
            }
            }
        }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if alertView.buttonTitleAtIndex(buttonIndex) == "Sí" {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.checkNumber()
        }
        
    }
   /*
    func getOffer() {
        let image = offer?.image
        
        let query = PFQuery(className: "Place")
        
        query.getObjectInBackgroundWithId(offer!.id, block: { (objects, error) -> Void in
            if error == nil {
                
                if  let title = objects!["title"] as? String, let area = objects!["area"] as? String, let price = objects!["price"] as? String, let descText = objects!["largeText"] as? String , let oldPrice = objects!["oldPrice"] as? String, let date = objects!["date"] as? NSDate, let  number = objects!["number"] as? NSNumber, let location = objects!["position"] as? PFGeoPoint, let address = objects!["address"] as? String, let endDate = objects!["endDate"] as? NSDate, let localName = objects!["localName"] as? String {
                    
             
                    self.offer = Offer(with: title, area: area, price: price, descText: descText, oldPrice: oldPrice, date: date, number: number, id: objects!.objectId!, location: location, address: address, endDate: endDate, localName: localName, object: objects! )
                    self.offer!.image = image
                    
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                print("Successfully retrieved from Parse")
                
            } else {
                
                if error == -1009 {

                    if #available(iOS 8.0, *) {

                    let alertController = UIAlertController(title: "Quau", message: "No hay conectividad", preferredStyle: .Alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        
                    }
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                    }
                    
                    print("NO conectividad")
                    
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                //  self.stopAnimating()
                
                print("Error load from Parse")
            }
        })
    }
    
    */
    
    func checkNumber(){
            
        let query = PFQuery(className: "Place")
        
        query.getObjectInBackgroundWithId(offer!.id, block: { (objects, error) -> Void in
            if error == nil {
                
                if  let  number = objects!["number"] as? NSNumber {
                    
                    if number.integerValue > 0 {
                        
                        self.performBuy()
                        
                    } else {
                        
                        if #available(iOS 8.0, *) {

                        let alertController = UIAlertController(title: "Quau", message: "Los cupones se han agotado", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            self.performSegueWithIdentifier("buy_segue", sender: self)
                        }
                 
                        alertController.addAction(OKAction)
                        
                        
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                        }else {
                            
                            let alert = UIAlertView(title: "Quau", message: "Los cupones se han agotado", delegate: self, cancelButtonTitle: "OK")
                            
                            alert.show()
                            self.performSegueWithIdentifier("buy_segue", sender: self)

                        }

                    }
                    
                    
                }
                
                
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                                print("Successfully retrieved from Parse")
                
            } else {
                
                if error == -1009 {

                    if #available(iOS 8.0, *) {

                    let alertController = UIAlertController(title: "Quau", message: "No hay conectividad", preferredStyle: .Alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        
                    }
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true) {
                        // ...
                        }
                    }
                    
                    print("NO conectividad")
                    
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                //  self.stopAnimating()
                
                print("Error load from Parse")
            }
        })
        
            }
    
    func performBuy(){
        
        let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let ticket = NSEntityDescription.insertNewObjectForEntityForName("Ticket", inManagedObjectContext:managedObjectContext) as? Ticket
        ticket!.name = offer?.title
        ticket!.id = offer?.localId
        ticket?.used = false
        ticket?.date = offer?.date
        ticket?.endDate = offer?.endDate
        ticket?.address = offer!.localName + " en " + offer!.address
        ticket?.price = offer?.price
        
        do {
            try managedObjectContext.save()
            
        } catch {
            print("Unresolved error")
            abort()
        }
        
        
        let n = (offer?.number.integerValue)! - Int(1)
        
        offerObj!.setValue(n, forKeyPath: "number")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        offerObj!.saveInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil {
                
                print("Successfully updated Parse")
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
            } else {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                print("Error udating Parse")
            }
        }
        
        print("Buy a ticket!")
        subCoin()
        
        let datf = NSDateFormatter()
        datf.dateStyle = .LongStyle
        
        
        let track = ["localName": offer!.localName]
        
        // Send the dimensions to Parse along with the 'search' event
        PFAnalytics.trackEvent("BUY", dimensions: track)
        
        //MARK: NOTIFICATIONS
        if NSDate().compare(offer!.date.dateByAddingTimeInterval(-60*60)) == .OrderedAscending {
            
            let startNotification = UILocalNotification()
            startNotification.alertBody = "¡Ya puedes usar tu cupón \"\(offer!.title)\" en \(offer!.localName)!" // text that will be displayed in the notification
            startNotification.alertAction = "ver" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            startNotification.fireDate = offer!.date.dateByAddingTimeInterval(-60*60) // todo item due date (when notification will be fired)
            startNotification.soundName = UILocalNotificationDefaultSoundName // play default sound
            startNotification.userInfo = ["UUID": offer!.localId + "start", ] // assign a unique identifier to the notification so that we can retrieve it later
            if #available(iOS 8.0, *) {
                startNotification.category = "TODO_CATEGORY"
            } else {
                // Fallback on earlier versions
            }
            startNotification.applicationIconBadgeNumber = 1
            UIApplication.sharedApplication().scheduleLocalNotification(startNotification)
            
        }
        
        
        let endNotification = UILocalNotification()
        endNotification.alertBody = "Tu cupón \"\(offer!.title)\" en \(offer!.localName) está a punto de caducar" // text that will be displayed in the notification
        endNotification.alertAction = "ver" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        // una hora antes
        endNotification.fireDate = offer!.endDate.dateByAddingTimeInterval(-60*60 - 45*60) // todo item due date (when notification will be fired)
        endNotification.soundName = UILocalNotificationDefaultSoundName // play default sound
        endNotification.userInfo = ["UUID": offer!.localId, ] // assign a unique identifier to the notification so that we can retrieve it later
        if #available(iOS 8.0, *) {
            endNotification.category = "TODO_CATEGORY"
        } else {
            // Fallback on earlier versions
        }
        endNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(endNotification)
        
        
        self.performSegueWithIdentifier("buy_segue", sender: self)
        

    }
    
       }