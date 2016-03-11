//
//  NodeListTableViewCell.swift
//  HomeAutomation
//
//  Created by Steele on 2016-03-11.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class NodeListTableViewCell: UITableViewCell {

    @IBOutlet weak var nodeTitle: UILabel!
    @IBOutlet weak var nodeImage: UIImageView!
    @IBOutlet weak var nodeStatus: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
    }

}
