//
//  ClassTableViewCell.swift
//  SBCC Coursewatch
//
//  Created by Justin Oroz on 5/29/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var instructor: UILabel!
    @IBOutlet weak var days: UILabel!
    @IBOutlet weak var time: UILabel!
    
    var classData: [String: String] = [:]
    
    func format() {
        switch self.classData["status"] {
        case "OPEN"?:
            self.status.textColor = UIColor.greenColor()
            break
        case "CLOSED"?:
            self.status.textColor = UIColor.redColor()
            break
        default:
            break
        }
        
        self.instructor.sizeToFit()
    }
    
}
