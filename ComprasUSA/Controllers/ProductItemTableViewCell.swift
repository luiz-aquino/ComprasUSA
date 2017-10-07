//
//  ProductItemTableViewCell.swift
//  ComprasUSA
//
//  Created by Luiz Aquino on 07/10/17.
//  Copyright © 2017 Luiz Aquino. All rights reserved.
//

import UIKit

class ProductItemTableViewCell: UITableViewCell {

    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblCreditCard: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
