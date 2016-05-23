//
//  GetDetailViewController.swift
//  PubliApp
//
//  Created by Karim on 26/10/15.
//  Copyright © 2015 Karim. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class GetDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var txtDesc: UITextView!
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblDay: UILabel!
    @IBOutlet var lblHour: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    var locationManager: CLLocationManager?
    var objectId: String?
    let regionRadius: CLLocationDistance = 850
    var managedContext: NSManagedObjectContext!
    var maincolor: UIColor = UIColor(red:0.97, green:0.35, blue:0.18, alpha:1.0)
    
    var fontName: String = "SFUIDisplay-Medium"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        // let swipe = UISwipeGestureRecognizer(target: self, action: "dismiss:")
        //swipe.direction = .Down
        // lblTitle.userInteractionEnabled = true
        //   lblTitle.addGestureRecognizer(swipe)
        
        lblTitle.font = UIFont(name: fontName, size: 22)
        lblTitle.adjustsFontSizeToFitWidth = true
        lblTitle.numberOfLines = 2
                
        txtDesc.font = UIFont(name: fontName, size: 15)
        txtDesc.layoutIfNeeded()

        txtDesc.sizeToFit()
        txtDesc.layoutIfNeeded()
        
        
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        if #available(iOS 8.0, *) {
            self.locationManager?.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    
    func textViewHeightForText(text :String, width:CGFloat) -> CGFloat
    {
        let txt = UITextView()
        txt.text = text
        let size = txt.sizeThatFits(CGSizeMake(width, 674.0))
        return size.height
    }
    
    override func viewWillAppear(animated: Bool) {
        getOffer(self.objectId!)
    }
    
    override func viewDidAppear(animated: Bool) {
        
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
                
            } else {
                
                let alert = UIAlertView(title: "Quau", message: "Permisos de localización denegados, ve a Ajustes", delegate: self, cancelButtonTitle: "OK")
                
                alert.show()
                
            }

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
    
    func loadElements(offer: Offer, object: PFObject) {
        
        let price = NSMutableAttributedString(string: offer.price + "€")
        
        price.addAttribute(NSForegroundColorAttributeName, value: maincolor, range: NSMakeRange(0, price.length))
        
        let title = NSMutableAttributedString(string: offer.title)
        
        let space = NSMutableAttributedString(string: " - ")
        space.appendAttributedString(price)
        if offer.price != "0" {
            title.appendAttributedString(space)
        }
        
        lblTitle.attributedText = title
        txtDesc.text = offer.descText
        
        object["image"]!.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                
                if UIImage(data:imageData!) != nil {
                    let img = UIImage(data:imageData!)
                    self.mainImage.image = img
                }
                
            }
        })
        
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

        
        let initialLocation = CLLocation(latitude: (offer.location.latitude), longitude: (offer.location.longitude))
        
        let place = Place(title: (offer.localName),
            locationName: (offer.address),
            coordinate: CLLocationCoordinate2D(latitude: (offer.location.latitude), longitude: (offer.location.longitude)))
        
        mapView.delegate = self
        mapView.addAnnotation(place)
        centerMapOnLocation(initialLocation)
        mapView.selectAnnotation(place, animated: true)
        mapView.showsUserLocation = true

        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 1.0, regionRadius * 1.0)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.regionThatFits(coordinateRegion)
        
    }
    
    
       func getOffer(ID: String) {
        
        var offer: Offer?
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        print("Loading offer...")
        
        let query = PFQuery(className: "Place")
        query.getObjectInBackgroundWithId(ID, block: { (objects, error) -> Void in
            if error == nil {
                
                let obj = objects
                
                if let title = obj!["title"] as? String, let area = obj!["area"] as? String, let price = obj!["price"] as? String, let descText = obj!["largeText"] as? String , let oldPrice = obj!["oldPrice"] as? String, let date = obj!["date"] as? NSDate, let  number = obj!["number"] as? NSNumber, let id = obj!.objectId, let location = obj!["position"] as? PFGeoPoint, let address = obj!["address"] as? String, let endDate = obj!["endDate"] as? NSDate, let localName = obj!["localName"] as? String {
                    
                    let newOffer = Offer(with: title, area: area, price: price, descText: descText, oldPrice: oldPrice, date: date, number: number, id: id, location: location, address: address, endDate: endDate, localName: localName, object: obj!, localId: "")
                    
                    offer = newOffer
                    
                    self.loadElements(offer!,object: obj!)
                    
                    
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
    
    
}
