//
//  TextImageListCell.swift
//  Piano
//
//  Created by Kevin Kim on 07/06/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import DynamicTextEngine_iOS
import RealmSwift

class TextImageListCell: DynamicAttachmentCell, AttributeModelConfigurable {
    
    @IBOutlet private weak var listView: UICollectionView!
    
    private var dataSource: ImageListDataSource<ImageListCell>!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with id: String) {
        let nib = UINib(nibName: "ImageListCell", bundle: nil)
        listView.register(nib, forCellWithReuseIdentifier: ImageListCell.identifier)
        dataSource = ImageListDataSource<ImageListCell>(with: listView, imageListModel: id)
        dataSource.didSelectRowAt = {self.review(with: $0)}
    }
    
    private func review(with image: Image) {
        guard let noteViewCtrl = AppNavigator.currentViewController as? NoteViewController else {return}
        let cardMapCtrl = viewCtrl(type: AlbumReviewController.self)
        cardMapCtrl.image = image
        noteViewCtrl.present(UINavigationController(rootViewController: cardMapCtrl), animated: true)
    }
    
}

