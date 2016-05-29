//
//  LoadingTableViewCell.swift
//  SBCC Coursewatch
//
//  Created by Justin Oroz on 5/27/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        loadingIndicator.hidesWhenStopped = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
