//
//  TitleCell.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

struct CategoryCustomTag: CollectionDatable {
    
    
    
    let type: NoteListViewController.CategoryType
    let order: Int
    var sectionTitle: String?
    var sectionIdentifier: String?
    
    init(type: NoteListViewController.CategoryType, order: Int, sectionTitle: String? = nil, sectionIdentifier: String? = nil) {
        self.type = type
        self.order = order
        self.sectionTitle = sectionTitle
        self.sectionIdentifier = sectionIdentifier
    }
    
    func size(maximumWidth: CGFloat) -> CGSize {
        return CGSize(width: maximumWidth, height: 64)
    }
    
    func didSelectItem(fromVC viewController: ViewController) {
        viewController.performSegue(withIdentifier: NoteListViewController.identifier, sender: type)
    }

    
}

class CategoryCustomTagCell: UICollectionViewCell, CollectionDataAcceptable {
    @IBOutlet weak var titleLabel: UILabel!
    var data: CollectionDatable? {
        didSet {
            guard let data = self.data as? CategoryCustomTag else { return }
            titleLabel.text = data.type.string
        }
    }
    
}
