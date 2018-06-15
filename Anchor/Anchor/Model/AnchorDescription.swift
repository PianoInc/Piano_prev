//
//  AnchorDescription.swift
//  Anchor
//
//  Created by JangDoRi on 2018. 5. 30..
//  Copyright © 2018년 piano. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif

/// anchor에 대한 정의 설명서.
public class AnchorDescription: NSObject {
    
    /// View와 superview의 anchorLayout.
    var anchor: AnchorLayout
    /// Anchor의 attribute.
    var attribute: AnchorAttribute
    
    /// Anchor의 relationship.
    var relation: AnchorRelation? = nil
    /// View의 anchor 또는 constant.
    var target: AnchorTarget? = nil
    
    /// 추가 수정 offset.
    var offset: AnchorConstant? = 0
    /// 우선순위.
    var priority: AnchorPriority? = nil
    
    init(_ anchor: AnchorLayout, attribute: AnchorAttribute) {
        self.anchor = anchor
        self.attribute = attribute
    }
    
}

