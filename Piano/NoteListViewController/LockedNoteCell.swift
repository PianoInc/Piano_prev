//
//  LockedNoteCell.swift
//  Piano
//
//  Created by Kevin Kim on 28/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

class LockedNoteCell: UICollectionViewCell, CollectionDataAcceptable {
    @IBOutlet weak var footnoteLabel: UILabel!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var data: CollectionDatable? {
        didSet {
            guard let data = self.data as? Note else { return }
            footnoteLabel.text = data.footnote
            shareImageView.isHidden = !data.type.isShared
            let firstLineText = data.content.firstLineText(font: titleLabel.font, width: titleLabel.bounds.width)
            titleLabel.text = firstLineText
            subTitleLabel.text = data.content.sub(firstLineText.count...)        }
    }
    
    @IBAction func tapUnlock(_ sender: Any) {
        guard let data = self.data as? Note else { return }
        let id = data.type.id
        //TODO: id값으로 해당 메모 잠금 풀기
    }
    
    @IBAction func tapTrash(_ sender: Any) {
        guard let data = self.data as? Note else { return }
        let id = data.type.id
        //TODO: id값으로 해당 메모 휴지통으로 이동시키기

    }
}
