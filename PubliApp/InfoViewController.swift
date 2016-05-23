//
//  InfoViewController.swift
//  PubliApp
//
//  Created by Karim on 26/10/15.
//  Copyright © 2015 Karim. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet var version: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let ver = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String

        version.text = "Versión " + ver
        
        self.navigationItem.title = "Información"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
