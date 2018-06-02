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
    
    func configure(with id: String) {
        guard let realm = try? Realm(), let imageModel = realm.object(ofType: RealmImageModel.self, forPrimaryKey: id) else { return }
        
        guard let image = UIImage(data: imageModel.image) else { return }
        imageView.image = image
    }
}
