//
//  ChannelTableViewCell.swift
//  rdio
//
//  Created by Tim Wattenberg on 25.04.18.
//  Copyright © 2018 Tim Wattenberg. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
