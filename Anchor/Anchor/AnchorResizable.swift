//
//  AnchorResizable.swift
//  Anchor
//
//  Created by JangDoRi on 2018. 5. 31..
//  Copyright © 2018년 piano. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif

/// Relationship의 정의된 anchor에 대한 추가 수정사항.
public class AnchorResizable: AnchorPriortizable {
    
    /// Anchor: Target과 offset의 값을 고정한다.
    @discardableResult
    public func fit() -> AnchorResizable {
        // TODO...
        return self
    }
    
}
