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

    //TODO: 컬렉션뷰 뷰 모델로 만들어서 구조짜기
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with id: String) {
        guard let realm = try? Realm(),
            let imageModel = realm.object(ofType: RealmImageListModel.self, forPrimaryKey: id)
            else {return}
        let imageIDs = imageModel.imageIDs.components(separatedBy: "|")
        print("imageIDs :", imageIDs)
    }

}

