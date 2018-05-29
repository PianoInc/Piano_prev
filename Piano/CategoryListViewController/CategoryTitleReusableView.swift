//
//  CategoryTitleReusableView.swift
//  Piano
//
//  Created by Kevin Kim on 26/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

class CategoryTitleReusableView: UICollectionReusableView, CollectionDataAcceptable {
    @IBOutlet weak var titleLabel: UILabel!
    
    var data: CollectionDatable? {
        didSet {
            titleLabel.text = data?.sectionTitle
        }
    }
    
}
