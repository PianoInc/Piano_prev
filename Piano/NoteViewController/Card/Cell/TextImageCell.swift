//
//  TextImageCell.swift
//  Piano
//
//  Created by Kevin Kim on 2018. 6. 2..
//  Copyright © 2018년 Piano. All rights reserved.
//

import DynamicTextEngine_iOS
import  RealmSwift

class TextImageCell: DynamicAttachmentCell, AttributeModelConfigurable {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    private var isPhoto = true
    private var modelID = ""
    
    func configure(with id: String) {
        modelID = id
        
        guard let realm = try? Realm(), let imageModel = realm.object(ofType: RealmImageModel.self, forPrimaryKey: id) else { return }
        isPhoto = imageModel.isPhoto
        
        guard let image = UIImage(data: imageModel.image) else { return }
        imageView.image = image
    }
    
    @IBAction private func action(select: UIButton) {
        guard let noteViewCtrl = AppNavigator.currentViewController as? NoteViewController else {return}
        if isPhoto {
            let albumReview = viewCtrl(type: AlbumReviewController.self)
            albumReview.image = imageView.image
            noteViewCtrl.present(UINavigationController(rootViewController: albumReview), animated: true)
        } else {
            let drawingMapCtrl = viewCtrl(type: DrawingMapController.self)
            drawingMapCtrl.modelID = modelID
            drawingMapCtrl.image = imageView.image
            drawingMapCtrl.drawDismissed = { [weak self] id in
                noteViewCtrl.textView.reload(attachmentID: id)
            }
            noteViewCtrl.present(drawingMapCtrl, animated: true)
        }
    }
    
}

