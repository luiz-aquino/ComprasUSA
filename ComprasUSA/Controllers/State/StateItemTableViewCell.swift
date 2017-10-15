//
//  StateItemTableViewCell.swift
//  ComprasUSA
//
//  Created by Luiz Aquino on 14/10/17.
//  Copyright © 2017 Luiz Aquino. All rights reserved.
//

import UIKit

class StateItemTableViewCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
