//
//  TableCellTableViewCell.swift
//  LiViD
//
//  Created by Matt Carlson on 9/20/16.
//  Copyright © 2016 Matthew Carlson. All rights reserved.
//

import UIKit

class TableCellTableViewCell: UITableViewCell {
    @IBOutlet weak var friendsOutlet: UILabel!

    @IBOutlet weak var acceptUser: UIButton!
    @IBOutlet weak var denyUser: UIButton!
    @IBOutlet weak var newUser: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
