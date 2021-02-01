//
//  CollectionViewCell.swift
//  FBLA Project 1
//
//  Created by Mason Dale on 2/24/18.
//  Copyright © 2018 Mason Dale. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    
    @IBAction func checkOutTapped(_ sender: Any) {
    }
}
