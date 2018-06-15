//
//  AnchorRelatable.swift
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

/// Anchor와 정의할 수 있는 relationship의 목록.
public class AnchorRelatable: NSObject {
    
    private let anchorDescription: AnchorDescription
    
    init(_ anchorDescription: AnchorDescription) {
        self.anchorDescription = anchorDescription
    }
    
    private func edit(_ relation: AnchorRelation, target: AnchorTarget) -> AnchorEditable {
        let anchorEditable = AnchorEditable(anchorDescription)
        anchorEditable.anchorDescription.relation = relation
        anchorEditable.anchorDescription.target = target
        return anchorEditable
    }
    
    /**
     equalTo.
     - parameter target : View의 anchor 또는 constant.
     */
    @discardableResult
    public func equalTo(_ target: AnchorTarget) -> AnchorEditable {
        return edit(.equalTo, target: target)
    }
    
    /**
     lessThanOrEqualTo.
     - parameter target : View의 anchor 또는 constant.
     */
    @discardableResult
    public func lessThanOrEqualTo(_ target: AnchorTarget) -> AnchorEditable {
        return edit(.lessThanOrEqualTo, target: target)
    }
    
    /**
     greaterThanOrEqualTo.
     - parameter target : View의 anchor 또는 constant.
     */
    @discardableResult
    public func greaterThanOrEqualTo(_ target: AnchorTarget) -> AnchorEditable {
        return edit(.greaterThanOrEqualTo, target: target)
    }
    
}

