//
//  ImageCell.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

struct CategoryNotification: CollectionDatable, Linkable {
    
    let title: String
    let subTitle: String
    var link: UniversialLink
    let subType: String
    let image: UIImage?
    var sectionTitle: String?
    var sectionIdentifier: String?
    
    init(title: String, subTitle: String, link: UniversialLink, subType: String, image: UIImage?, sectionTitle: String? = nil, sectionIdentifier: String? = nil) {
        self.title = title
        self.subTitle = subTitle
        self.link = link
        self.subType = subType
        self.image = image
        self.sectionTitle = sectionTitle
    }
    
    func size(maximumWidth: CGFloat) -> CGSize {
        let notiWidth = maximumWidth > 640 ? maximumWidth / 2 : maximumWidth
        return CGSize(width: notiWidth - 10, height: notiWidth * 3 / 4 + 71)
    }
    
    func didSelectItem(fromVC viewController: ViewController) {
        link.openURL(fromVC: viewController)
    }
    
    var sectionInset: EdgeInsets {
        return UIEdgeInsetsMake(0, 0, 25, 0)
    }
    
}

class CategoryNotificationCell: UICollectionViewCell, CollectionDataAcceptable {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var subTypeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var data: CollectionDatable? {
        didSet {
            guard let data = self.data as? CategoryNotification else { return }
            titleLabel.text = data.title
            subTitleLabel.text = data.subTitle
            typeLabel.text = data.link.string
            imageView.image = data.image
        }
    }
    
}
