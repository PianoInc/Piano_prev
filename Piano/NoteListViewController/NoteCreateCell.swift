//
//  NoteCreateCell.swift
//  Piano
//
//  Created by Kevin Kim on 24/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

struct NoteCreate: CollectionDatable {
    
    let type: NoteViewController.NoteType
    let title: String
    let description: String
    
    var sectionTitle: String?
    var sectionIdentifier: String?
    
    init(type: NoteViewController.NoteType, title: String, description: String, sectionTitle: String? = nil, sectionIdentifier: String? = nil) {
        self.type = type
        self.title = title
        self.description = description
        self.sectionTitle = sectionTitle
        self.sectionIdentifier = sectionIdentifier
    }
    
    var sectionInset: EdgeInsets {
        return UIEdgeInsetsMake(10, 0, 0, 0)
    }
    
    func size(maximumWidth: CGFloat) -> CGSize {
        let width = maximumWidth - (sectionInset.left + sectionInset.right)
        return CGSize(width: width, height: 64)
    }
    
    func didSelectItem(fromVC viewController: ViewController) {
        viewController.performSegue(withIdentifier: NoteViewController.identifier, sender: type)
    }
    
}

class NoteCreateCell: UICollectionViewCell, CollectionDataAcceptable {
    
    var data: CollectionDatable? {
        didSet {
            
        }
    }
    
    
}
