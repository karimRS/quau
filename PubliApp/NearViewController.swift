//
//  NearViewController.swift
//  PubliApp
//
//  Created by Karim on 20/10/15.
//  Copyright © 2015 Karim. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class NearViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate {
    
    @IBOutlet var table: UITableView!
    
    var customView: UIView!
    var loadingView: UIView!
    var loadingImg: UIImageView!
    var customImage: UIImageView!
    var timer: NSTimer!
    
    var objArray: [PFObject]!
    var offerArray: [Offer] = []
    var selectedOffer: Offer?
    var selectedOfferObj: PFObject?
    var boughtIds: [String]?
    var lbl = UILabel(frame: CGRectMake(0, 0, 380, 21))
    
    var locationManager: CLLocationManager?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var radiusKm: Double = 0.75
    
    var refreshControl:UIRefreshControl!
    var mainColor: UIColor = UIColor(red:0.97, green:0.35, blue:0.18, alpha:1.0)
    var alphaColor: UIColor = UIColor(red:0.97, green:0.35, blue:0.18, alpha:0.8)
    var grayalpha = UIColor(red:0.84, green:0.84, blue:0.84, alpha:0.8)
    var imgLoad = UIImage(named: "square")

    var fontName: String = "SFUIDisplay-Medium"
    
    var transition = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        tabBarController!.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.clearColor()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.table.addSubview(refreshControl)
        
        lbl.font = UIFont(name: fontName, size: 18)
        lbl.numberOfLines = 4
        lbl.lineBreakMode = .ByTruncatingTail
        lbl.adjustsFontSizeToFitWidth = true
        lbl.text = "Lo sentimos, no hay ofertas cerca de ti 😔 desliza hacia abajo para volver a buscar"
        lbl.textColor = mainColor
        lbl.textAlignment = .Center
        lbl.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        lbl.center = view.center
        
        loadCustomRefreshContents()
        startAnimating()
        loadingView.center = view.center
        self.view.addSubview(loadingView)

        if isConnectedToNetwork() == false {
            
            stopAnimating()
            let alertController = UIAlertController(title: "Quau", message: "No hay una conexión a internet 🤕, desliza hacia abajo para intentarlo de nuevo", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            
        }else {

        fetchBoughtIds()
        getPosition()
        }
    }
    override func viewDidAppear(animated: Bool) {
        
        if isConnectedToNetwork() == false {
            
            let alertController = UIAlertController(title: "Quau", message: "No hay una conexión a internet 🤕, desliza hacia abajo para intentarlo de nuevo", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            
            
        }

        
        transition = true
        tabBarController!.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fromBackground", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        if checkPermission() == 2 {
            
            if #available(iOS 8.0, *) {

            let alertController = UIAlertController(title: "Permisos de localización denegados", message: "", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "Más tarde", style: .Cancel) { (action) in
                
            }
            
            let settingsAction = UIAlertAction(title: "Ir a Ajustes", style: .Default) { (action) in
                
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                
            }
            alertController.addAction(OKAction)
            
            alertController.addAction(settingsAction)
            
            
            self.presentViewController(alertController, animated: true) {
                // ...
                }
            }else {
                
                let alert = UIAlertView(title: "Quau", message: "Permisos de localización denegados, ve a Ajustes", delegate: self, cancelButtonTitle: "OK")
                
                alert.show()
            }

        }
        
    }

    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        
        if viewController == self && offerArray != [] {
            if transition == false {
                table.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
            }
        }
        transition = false
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        transition = false
    }

    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    
    //MARK: LOCATION
    func getPosition() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        self.locationManager = CLLocationManager()
        if #available(iOS 8.0, *) {
            self.locationManager!.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        
        switch checkPermission() {
            
        case 1:
            
            print("Getting user position...")
            self.locationManager!.delegate = self
            self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager!.startUpdatingLocation()

        case 2:
            stopAnimating()
            
            if #available(iOS 8.0, *) {

            let alertController = UIAlertController(title: "Permisos de localización denegados", message: "", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "Más tarde", style: .Cancel) { (action) in
                
            }
            
            let settingsAction = UIAlertAction(title: "Ir a Ajustes", style: .Default) { (action) in
                
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                
            }
            alertController.addAction(OKAction)
            
            alertController.addAction(settingsAction)
            
            
            self.presentViewController(alertController, animated: true) {
                // ...
                }
            }else {
                let alert = UIAlertView(title: "Quau", message: "Permisos de localización denegados, ve a Ajustes", delegate: self, cancelButtonTitle: "OK")
                
                alert.show()
            }
            
        default:
            stopAnimating()
            
        }

    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let coord = self.locationManager!.location!.coordinate
        self.latitude = coord.latitude
        self.longitude = coord.longitude
        
        self.locationManager!.stopUpdatingLocation()
        locationManager = nil
        
        self.loadAll()
        
    }
    
    
    //MARK: LOADING
    func startAnimating() {
        loadingView.hidden = false
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = 1.0
        rotateAnimation.repeatCount = 1000.0
        loadingImg.layer.addAnimation(rotateAnimation, forKey: "transform.rotation")
        
    }
    
    func stopAnimating() {
        loadingView.hidden = true
        loadingImg.layer.removeAllAnimations()
        loadingImg.transform = CGAffineTransformMakeRotation(CGFloat(0.0))
        
    }
    
    // MARK: LOAD
    func loadAll() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        print("Loading offers...")

        let myGeoPoint = PFGeoPoint(latitude: latitude!, longitude: longitude!)
        let query = PFQuery(className: "Place")
        query.whereKey("endDate", greaterThanOrEqualTo: getToday())
        query.addAscendingOrder("date")
        query.whereKey("position", nearGeoPoint: myGeoPoint, withinKilometers: radiusKm)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                
                self.stopAnimating()
                let offerArray2 = self.offerArray
                let idArray = self.offerArray.map({$0.id})
                self.offerArray = []
                self.objArray = objects as? [PFObject]
                
                let formt = NSDateFormatter()
                formt.timeZone = NSTimeZone(name: "GMT")
                formt.dateFormat = "dd:MM:yyyy:HH:mm"
                
                for obj in objects! {
                    
                    if let title = obj["title"] as? String, let area = obj["area"] as? String, let price = obj["price"] as? String, let descText = obj["largeText"] as? String , let oldPrice = obj["oldPrice"] as? String, let date = obj["date"] as? NSDate, let  number = obj["number"] as? NSNumber, let id = obj.objectId, let location = obj["position"] as? PFGeoPoint, let address = obj["address"] as? String, let endDate = obj["endDate"] as? NSDate, let localName = obj["localName"] as? String {
                        
                        
                        
                        let newOffer = Offer(with: title, area: area, price: price, descText: descText, oldPrice: oldPrice, date: date, number: number, id: id!, location: location, address: address, endDate: endDate, localName: localName, object: obj as! PFObject, localId:id! + formt.stringFromDate(date))
                        
                        
                        if idArray.contains(newOffer.localId) {
                            
                            let i = idArray.indexOf(newOffer.localId)
                            newOffer.image = offerArray2[i!].image
                        }
                        
                        self.offerArray.append(newOffer)
                        
                    }
                    
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.customImage.layer.removeAllAnimations()
                self.customImage.transform = CGAffineTransformMakeRotation(CGFloat(0.0))
                self.refreshControl.endRefreshing()
                self.table.reloadData()
                
                if (self.offerArray == []) {
                    self.view.addSubview(self.lbl)
                }else{
                    self.lbl.removeFromSuperview()
                }
                print("Successfully retrieved from Parse")
                
            } else {
                
                if error == -1009 {
                    self.stopAnimating()
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
                self.stopAnimating()
                
                print("Error load from Parse")
            }
        }
}
    
    func fetchBoughtIds() {
        
        boughtIds = []
        
        // Load bought IDs
        let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Ticket")
        var ticArray: [Ticket]?
        ticArray = []
        
        do {
            ticArray = try managedContext.executeFetchRequest(fetchRequest) as? [Ticket]
        } catch let error as NSError {
            // failure
            
            print("Fetch offers failed: \(error.localizedDescription)")
        }
        
        boughtIds = ticArray!.map({ $0.id! })
    }
    
    func fromBackground() {
        
        
        if checkPermission() == 1 {
            
            if isConnectedToNetwork() == false {
                
                let alertController = UIAlertController(title: "Quau", message: "No hay una conexión a internet 🤕, desliza hacia abajo para intentarlo de nuevo", preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
                
                
            }else{
        getPosition()
            }
            
        } else {
            if #available(iOS 8.0, *) {

            let alertController = UIAlertController(title: "Permisos de localización denegados", message: "", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "Más tarde", style: .Cancel) { (action) in
                
            }
            
            let settingsAction = UIAlertAction(title: "Ir a Ajustes", style: .Default) { (action) in
                
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                
            }
            alertController.addAction(OKAction)
            
            alertController.addAction(settingsAction)
            
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            }else{
                
                let alert = UIAlertView(title: "Quau", message: "Permisos de localización denegados, ve a Ajustes", delegate: self, cancelButtonTitle: "OK")
                
                alert.show()
            }
            

            
        }
    }


    // MARK: REFRESH
    
    func loadCustomRefreshContents() {
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents[0] as! UIView
        customView.frame = refreshControl.bounds
        customImage = customView.subviews[0] as! UIImageView
        
        refreshControl.addSubview(customView)
        
        let loadingContents = NSBundle.mainBundle().loadNibNamed("LoadingContents", owner: self, options: nil)
        loadingView = loadingContents[0] as! UIView
        loadingImg = loadingView.subviews[0] as! UIImageView
        
    }
    
    func refresh(sender: AnyObject) {
        refreshControl.beginRefreshing()
        animateRefresh()
        timerUp()
    }
    
    func animateRefresh() {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = 0.4
        rotateAnimation.repeatCount = 30.0
        self.customImage.layer.addAnimation(rotateAnimation, forKey: "transform.rotation")
        
    }
    
    
    func timerUp() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.55, target: self, selector: "endOfWork", userInfo: nil, repeats: true)
    }
    
    
    func endOfWork() {
        
        if isConnectedToNetwork() == false {
            
            self.customImage.layer.removeAllAnimations()
            self.customImage.transform = CGAffineTransformMakeRotation(CGFloat(0.0))
            self.refreshControl.endRefreshing()
            timer.invalidate()
            timer = nil
            
            let alertController = UIAlertController(title: "Quau", message: "No hay una conexión a internet 🤕, desliza hacia abajo para intentarlo de nuevo", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            
            
        }else {
        
        getPosition()
        timer.invalidate()
        timer = nil
        }
    }
    
    // MARK: TABLEVIEW
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  view.bounds.size.width + 12
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offerArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.table.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? KustomTableViewCell
        
        let offer = offerArray[indexPath.row]
        
        if offer.image != nil {
            
            cell?.img.image = offer.image
        }else {
            
            
            cell?.img.image = imgLoad
            
            let obj = offerArray[indexPath.row].object
            let imgData = obj["image"]
            
            /*
            // Load from url
            //  let url = "https://s3.amazonaws.com/" + (imgData.url! as? NSString)!.substringFromIndex(7)
            
            let url = imgData.url
            
            print(url)
            if let urlString:String? = url {
            
            if let url:NSURL? = NSURL(string: urlString!) {
            let request:NSURLRequest = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 5.0)
            
            NSOperationQueue.mainQueue().cancelAllOperations()
            
            //     NSURLConnection.sendAsynchronousRequest(<#T##request: NSURLRequest##NSURLRequest#>, queue: <#T##NSOperationQueue#>, completionHandler: <#T##(NSURLResponse?, NSData?, NSError?) -> Void#>)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response:NSURLResponse?, imageData:NSData?, error:NSError?) -> Void in
            
            // cell?.catImageView?.image = UIImage(data: imageData)
            
            offer.image =  UIImage(data:imageData!)
            cell?.img.image = offer.image
            
            })
            }
            }
            */
            
            // NSOperationQueue.mainQueue().cancelAllOperations()
            imgData?.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    
                    if UIImage(data:imageData!) != nil {
                        let img = UIImage(data:imageData!)
                        offer.image = img
                        cell?.img.image = img
                    }
                    
                }
            })
            
        }
        
        //Font
        
        cell?.lblOut.font = UIFont(name: fontName, size: 21)
        cell?.title.font = UIFont(name: fontName, size: 25)
        cell?.place.font = UIFont(name: fontName, size: 16)
        cell?.dayName.font = UIFont(name: fontName, size: 22)
        cell?.dayNumber.font = UIFont(name: fontName, size: 30)
        cell?.price.font = UIFont(name: "SFUIDisplay-Medium", size: 28)
        cell?.price.adjustsFontSizeToFitWidth = true
        cell?.title.adjustsFontSizeToFitWidth = true
        
        cell?.separatorInset = UIEdgeInsetsZero
       if #available(iOS 8.0, *) {
            cell?.layoutMargins = UIEdgeInsetsZero
        } else {
            // Fallback on earlier versions
        }
        
        cell?.title?.text = offer.title
        cell?.title.adjustsFontSizeToFitWidth = true
        cell?.place?.text = offer.localName + " en " + offer.area
        
        cell?.lblOut.backgroundColor = alphaColor
        cell?.lblOut.sizeToFit()
        cell?.lblOut.layer.masksToBounds = true
        cell?.lblOut.layer.cornerRadius = 5
        
        let att = NSMutableAttributedString(string: " " + offer.oldPrice + "€")
        
        att.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, att.length))
        
        att.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(0, att.length))
        att.appendAttributedString(NSMutableAttributedString(string: " " + offer.price + "€"))
        
        cell?.price.attributedText = att
        
        cell?.price.backgroundColor = UIColor(red:0.97, green:0.35, blue:0.18, alpha:0.9)
        cell?.price.layer.masksToBounds = true
        cell?.price.layer.cornerRadius = 5
        
        
        if offer.price == "0" {
            cell?.price.hidden = true
            
        }else{
            cell?.price.hidden = false
        }
      
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = "dd-MM-yyyy"

        if dateFormatter.stringFromDate(getToday()) == dateFormatter.stringFromDate(offer.date) || offer.date.compare(getToday()) == .OrderedAscending {
            cell?.dayNumber.text = "Hoy"
            cell?.dayName.text = ""
        } else {
            
            cell?.dayName.adjustsFontSizeToFitWidth = true
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "GMT")
            dateFormatter.dateFormat = "EEEE"
            var dateString = dateFormatter.stringFromDate(offer.date)
            dateString.replaceRange(dateString.startIndex...dateString.startIndex, with: String(dateString[dateString.startIndex]).capitalizedString)

            cell?.dayName.text = dateString
            dateFormatter.dateFormat = "dd"
            let str = dateFormatter.stringFromDate(offer.date)
            cell?.dayNumber.text = str
        }
        
        if offer.number == NSNumber(int: 1) {
            cell?.lblOut.text = "\(offer.number) cupón "
        }else {
            cell?.lblOut.text = "\(offer.number) cupones "
        }
        
        if offer.number.integerValue < 1 {
            
            cell?.lblOut.backgroundColor = grayalpha
            cell?.lblOut.text = "Agotados "
            offer.state = .Out
        }
        
        if boughtIds! != [] {
            if boughtIds!.contains(offer.localId) {
                
                cell?.lblOut.backgroundColor = grayalpha
                cell?.lblOut.text = "Comprado "
                offer.state = .Bought
                
            }}
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let offer = offerArray[indexPath.row]
        selectedOffer = offer
        selectedOfferObj = offerArray[indexPath.row].object
        
        dispatch_async(dispatch_get_main_queue(),{
            self.performSegueWithIdentifier("detail_segue", sender: self)
        })
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detail_segue") {
            let svc = segue.destinationViewController as? DetailViewController
            
            svc!.offer = selectedOffer
            svc?.offerObj = selectedOfferObj
            
        }
        
    }
    
}

