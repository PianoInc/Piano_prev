//
//  AnchorEditable.swift
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

/// Relationship의 정의된 anchor에 대한 추가 수정사항.
public class AnchorEditable: AnchorPriortizable {
    
    @discardableResult
    public func offset(_ amount: AnchorConstant) -> AnchorEditable {
        anchorDescription.offset = amount
        return self
    }
    
}

