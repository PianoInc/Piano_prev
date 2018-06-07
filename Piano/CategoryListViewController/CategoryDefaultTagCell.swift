//
//  LargeTitleCell.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

struct CategoryDefaultTag: CollectionDatable {
    
    let categoryType: NoteListViewController.CategoryType
    var sectionTitle: String?
    var sectionIdentifier: String?
    var hasSeparator: Bool
    
    init(categoryType: NoteListViewController.CategoryType, sectionTitle: String? = nil, sectionIdentifier: String? = nil, hasSeparator: Bool) {
        self.categoryType = categoryType
        self.sectionTitle = sectionTitle
        self.sectionIdentifier = sectionIdentifier
        self.hasSeparator = hasSeparator
    }
    
    func size(maximumWidth: CGFloat) -> CGSize {
        return CGSize(width: maximumWidth, height: 82)
    }
    
    func didSelectItem(fromVC viewController: ViewController) {
        viewController.performSegue(withIdentifier: NoteListViewController.identifier, sender: categoryType)
    }

    
}

class CategoryDefaultTagCell: UICollectionViewCell, CollectionDataAcceptable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    
    var data: CollectionDatable? {
        didSet {
            guard let data = self.data as? CategoryDefaultTag else { return }
            titleLabel.text = data.categoryType.title
            separatorView.isHidden = !data.hasSeparator
        }
    }
    
}
