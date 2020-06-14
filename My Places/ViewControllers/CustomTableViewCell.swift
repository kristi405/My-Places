//
//  CustomTableViewCell.swift
//  My Places
//
//  Created by kris on 19/05/2020.
//  Copyright © 2020 kris. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var ImageOfPlaces: UIImageView! {
        didSet {
            
            ImageOfPlaces.layer.cornerRadius = ImageOfPlaces.frame.size.height / 2
            ImageOfPlaces.clipsToBounds = true
        }
    }
    @IBOutlet var NameLabel: UILabel!
    @IBOutlet var LocationLabel: UILabel!
    @IBOutlet var TypeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    
}
