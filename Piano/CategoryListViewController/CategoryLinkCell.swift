//
//  LinkCell.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

struct CategoryLink: CollectionDatable, Linkable {
    
    var link: UniversialLink
    var sectionTitle: String?
    var sectionIdentifier: String?
    var hasSeparator: Bool
    
    init(link: UniversialLink, sectionTitle: String? = nil, sectionIdentifier: String? = nil, hasSeparator: Bool) {
        self.link = link
        self.sectionTitle = sectionTitle
        self.sectionIdentifier = sectionIdentifier
        self.hasSeparator = hasSeparator
    }
    
    func size(maximumWidth: CGFloat) -> CGSize {
        return CGSize(width: maximumWidth, height: 50)
    }
    
    var headerSize: CGSize {
        return CGSize(width: 100, height: 66)
    }
    
    func didSelectItem(fromVC viewController: ViewController) {
        link.openURL(fromVC: viewController)
    }
    
}

class CategoryLinkCell: UICollectionViewCell, CollectionDataAcceptable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    var data: CollectionDatable? {
        didSet {
            guard let data = self.data as? CategoryLink else { return }
            titleLabel.text = data.link.string
            separatorView.isHidden = !data.hasSeparator
        }
    }
    
}
