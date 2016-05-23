//
//  KustomTableViewCell.swift
//  PubliApp
//
//  Created by Karim on 26/09/15.
//  Copyright © 2015 Karim. All rights reserved.
//

import UIKit

class KustomTableViewCell: UITableViewCell {

    @IBOutlet var img: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var place: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var lblOut: UILabel!
    @IBOutlet var dayNumber: UILabel!
    @IBOutlet var dayName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
