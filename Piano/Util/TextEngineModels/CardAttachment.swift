//
//  CardAttachment.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 5. 18..
//  Copyright © 2018년 piano. All rights reserved.
//

import DynamicTextEngine_iOS
import UIKit

class CardAttachment: DynamicTextAttachment {

    private var privateCellIdentifier = ""

    var idForModel = ""

    override var cellIdentifier: String {
        return privateCellIdentifier
    }

    init(idForModel: String, cellIdentifier: String) {
        super.init()

        if cellIdentifier.contains("|") {
            fatalError("identifier should not contain | character")
        }
        
        self.uniqueID = idForModel
        self.idForModel = idForModel
        self.privateCellIdentifier = cellIdentifier
        self.currentSize = size(forIdentifier: cellIdentifier)
    }

    init(attachment: CardAttachment) {
        super.init(attachment: attachment)
        self.idForModel = attachment.idForModel
        self.privateCellIdentifier = attachment.cellIdentifier
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///This is a substitution of copy() function. It's used when dragging cell
    override func getCopyForDragInteraction() -> DynamicTextAttachment {
        return CardAttachment(attachment: self)
    }

    ///Set size for attachment!
    private func size(forIdentifier identifier: String) -> CGSize {
        let edgeInsets: CGFloat = 53 // head == 30, tail == 20, inset == 3
        let width = self.mainSize.width - edgeInsets
        var height = width * 3 / 4
        
        switch identifier {
        case TextImageCell.identifier: break
        case TextImageListCell.identifier: break
        case TextEventCell.identifier:
            height = 65
        case TextAddressCell.identifier:
            height = 200
        default: break
        }
        
        return CGSize(width: width, height: height)
    }
    
}

extension NSTextAttachment {
    func getImage() -> UIImage? {
        if let unwrappedImage = image {
            return unwrappedImage
        } else if let data = contents,
            let decodedImage = UIImage(data: data) {
            return decodedImage
        } else if let fileWrapper = fileWrapper,
            let imageData = fileWrapper.regularFileContents,
            let decodedImage = UIImage(data: imageData) {
            return decodedImage
        }
        return nil
    }
}

