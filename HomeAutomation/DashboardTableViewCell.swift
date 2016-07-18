//
//  DashboardTableViewCell.swift
//  HomeAutomation
//
//  Created by Steele on 2016-07-08.
//  Copyright © 2016 11thHourIndustries. All rights reserved.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {

 
    @IBOutlet weak var dashboardItemStatus: UISwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func dashboardItemSwitch(sender: UISwitch) {
//        let predicate = NSPredicate(format: "id = %@", self.program.id)
//        let nodeRealm = realm.objects(Program.self).filter(predicate)
//        
//        if sender.on
//        {
//            try! realm.write {
//                nodeRealm.setValue(true, forKey: "dashboardItem")
//            }
//        }
//        else
//        {
//            try! realm.write {
//                nodeRealm.setValue(false, forKey: "dashboardItem")
//            }
//        }

        
    }
}
