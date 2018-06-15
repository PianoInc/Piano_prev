//
//  AnchorPriortizable.swift
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

/// 생성된 anchor에 대한 우선순위 설정.
public class AnchorPriortizable: AnchorFinalizable {
    
    @discardableResult
    public func priority(_ priority: AnchorPriority) -> AnchorFinalizable {
        anchorDescription.priority = priority
        return self
    }
    
}

