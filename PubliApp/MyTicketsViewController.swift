//
//  TicketsViewController.swift
//  PubliApp
//
//  Created by Karim on 01/10/15.
//  Copyright © 2015 Karim. All rights reserved.
//

import UIKit
import CoreData

class MyTicketsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var table: UITableView!
    @IBOutlet var lblCoins: UILabel!
    
    var customView: UIView!
    var customImage: UIImageView!
    var timer: NSTimer!
    
    var refreshControl:UIRefreshControl!
    var managedContext: NSManagedObjectContext!
    var ticketsArray: [Ticket]!
    var selectedTicket: Ticket?
    var lbl = UILabel(frame: CGRectMake(0, 0, 380, 21))
    var mainColor: UIColor = UIColor(red:0.97, green:0.35, blue:0.18, alpha:1.0)
    var alphaColor: UIColor = UIColor(red:0.97, green:0.35, blue:0.18, alpha:0.9)
    var fontName: String = "SFUIDisplay-Medium"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 65
                
        let appDelegate =   UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        navigationController?.navigationBar.layer.borderWidth = 2.0
        navigationController?.navigationBar.layer.borderColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0).CGColor
            
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.clearColor()
        self.refreshControl.backgroundColor = UIColor.clearColor()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.table.addSubview(refreshControl)
        
        loadCustomRefreshContents()

        lblCoins.font = UIFont(name: "SFUIDisplay-SemiBold", size: 21)
        lblCoins.adjustsFontSizeToFitWidth = true
        lbl.center = view.center
        lbl.font = UIFont(name: fontName, size: 18)
        lbl.numberOfLines = 3
        lbl.lineBreakMode = .ByTruncatingTail
        lbl.text = "Aún no tienes ningún cupón, ¿a qué esperas?"
        lbl.textColor = UIColor(red:0.97, green:0.35, blue:0.18, alpha:1.0)
        lbl.textAlignment = .Center
        lbl.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        lbl.center = view.center

        
        ticketsArray = []
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        updateCoins()
        let n = getCoins()
        
        switch n {
        case 0:
            lblCoins.text = "No te quedan cupones para esta semana"
            
        case 1:
            lblCoins.text = "Te queda 1 cupón para esta semana"
            
        default:
            lblCoins.text = "Te quedan \(n) cupones para esta semana"
            
        }
        fetchTickets()

        table.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: REFRESH
    
    func loadCustomRefreshContents() {
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents[0] as! UIView
        customView.frame = refreshControl.bounds
        customImage = customView.subviews[0] as! UIImageView

        refreshControl.addSubview(customView)
        
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
        updateCoins()
        let n = getCoins()
        
        switch n {
        case 0:
            lblCoins.text = "No te quedan cupones para esta semana"

        case 1:
            lblCoins.text = "Te queda 1 cupón para esta semana"

        default:
            lblCoins.text = "Te quedan \(n) cupones para esta semana"

        }
        
        timer.invalidate()
        timer = nil
        
        self.customImage.layer.removeAllAnimations()
        self.customImage.transform = CGAffineTransformMakeRotation(CGFloat(0.0))
        self.refreshControl.endRefreshing()
    }

    //MARK: FETCH
    
    func fetchTickets() {
                
        let fetchRequest = NSFetchRequest(entityName: "Ticket")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            ticketsArray = try managedContext.executeFetchRequest(fetchRequest) as? [Ticket]
        } catch let error as NSError {
            // failure
            ticketsArray = []
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        if (self.ticketsArray == []) {
            self.view.addSubview(self.lbl)
        }else{
            self.lbl.removeFromSuperview()
        }
        
        for tic in ticketsArray.reverse() {
            
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
                
                ticketsArray.removeAtIndex(ticketsArray.indexOf(tic)!)
                ticketsArray.append(tic)
                
            }
            
                    }
        
        
    }
    
        
    //MARK: TABLEVIEW
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.table.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let ticket = ticketsArray[indexPath.row]
        
        cell.backgroundColor = alphaColor
        cell.textLabel?.font = UIFont(name: fontName, size: 17)
        cell.detailTextLabel?.font = UIFont(name: fontName, size: 13)
        cell.textLabel?.text = ticket.name
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.blackColor()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = "dd"
        let strDay = dateFormatter.stringFromDate(ticket.date!)
        dateFormatter.dateFormat = "MMMM"
        let strMonth = dateFormatter.stringFromDate(ticket.date!)
        
        cell.detailTextLabel?.text = "\(strDay) de \(strMonth)"
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
        
        cell.selectionStyle = .None
        cell.accessoryType = .DisclosureIndicator
        cell.separatorInset = UIEdgeInsetsZero
        if #available(iOS 8.0, *) {
            cell.layoutMargins = UIEdgeInsetsZero
        } else {
            // Fallback on earlier versions
        }
        
        if ticket.used == true {
            cell.backgroundColor = UIColor(white: 0.6, alpha: 0.5)
            cell.detailTextLabel?.textColor = UIColor.grayColor()
            cell.textLabel?.textColor = UIColor.grayColor()
            cell.accessoryType = .None
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedTicket = ticketsArray[indexPath.row]
        self.performSegueWithIdentifier("ticket_segue", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ticket_segue") {
            let svc = segue.destinationViewController as? TicketViewController
            
            svc!.ticket = selectedTicket
        }
        
    }

}
