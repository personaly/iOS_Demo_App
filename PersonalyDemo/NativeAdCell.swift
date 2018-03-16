//
//  NativeAdCell.swift
//  PersonalyDemo
//
//  Created by Mobexs on 11/8/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import UIKit
import Personaly

class NativeAdCell: UITableViewCell {

    @IBOutlet weak var nativeAdView: PersonalyNativeAdView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
