//
//  AlbumPhotoCell.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 9..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class AlbumPhotoCell: UICollectionViewCell {
    
    weak var delegates: AlbumDelegates!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var livePhotoBadgeImageView: UIImageView!
    @IBOutlet var checkImageView: UIImageView!
    @IBOutlet var button: UIButton!
    
    var indexPath: IndexPath!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkImageView.isHidden = (indexPath.row == 0)
        checkImageView.image = isSelected ? #imageLiteral(resourceName: "check") : nil
    }
    
    @IBAction private func action(select: UIButton) {
        delegates.select(photo: indexPath)
    }
    
}

