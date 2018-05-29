//
//  DynamicAttachmentCell.swift
//  DynamicTextEngine
//
//  Created by 김범수 on 2018. 3. 22..
//

import Foundation
import CoreGraphics

extension DynamicAttachmentCell {
    
    public func isRelated(to attachment: DynamicTextAttachment) -> Bool {
        return (relatedAttachment?.uniqueID ?? "") == attachment.uniqueID
    }

    func sync(to bounds: CGRect) {
        guard let superView = superview as? DynamicTextView else {return}
        let newBounds = bounds.offsetBy(dx: superView.textContainerInset.left,
                                        dy: superView.textContainerInset.top)
                              .insetBy(dx: 1.5, dy: 0)
        
        if newBounds.minX != leadingConstraint!.constant
            || newBounds.minY != topConstraint!.constant
            || newBounds.width != widthConstraint!.constant
            || newBounds.height != heightConstraint!.constant {

            leadingConstraint?.constant = newBounds.minX
            topConstraint?.constant = newBounds.minY
            widthConstraint?.constant = newBounds.width
            heightConstraint?.constant = newBounds.height
        }
    }
    

    @objc open func prepareForReuse() {
    }
    
    public func changeSize(to size: CGSize) {
        guard let relatedAttachment = relatedAttachment else {return}
        relatedAttachment.currentSize = size
    }
}

