//
//  ImagePickerCell.swift
//  Piano
//
//  Created by Kevin Kim on 2018. 6. 2..
//  Copyright © 2018년 Piano. All rights reserved.
//

import UIKit

//struct ImagePicker: CollectionDatable {
//    let image: UIImage
//    let livePhotoBadgeImage: UIImage?
//
//    var sectionTitle: String?
//    var sectionIdentifier: String?
//
//    func size(maximumWidth: CGFloat) -> CGSize {
//        <#code#>
//    }
//
//    func didSelectItem(fromVC viewController: ViewController) {
//        <#code#>
//    }
//}

class ImagePickerCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var livePhotoBadgeImageView: UIImageView!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var representedAssetIdentifier: String!
    
}
