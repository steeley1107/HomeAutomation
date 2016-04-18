//
//  FolderTableViewCell.swift
//  HomeAutomation
//
//  Created by Steele on 2016-04-15.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class FolderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nodeTitle: UILabel!
    @IBOutlet weak var nodeImage: UIImageView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
