//
//  PeriodReusableView.swift
//  Piano
//
//  Created by Kevin Kim on 24/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

class NotePeriodReusableView: UICollectionReusableView, CollectionDataAcceptable {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var data: CollectionDatable? {
        didSet {
            titleLabel.text = data?.sectionTitle
        }
    }
    
    
    
}
