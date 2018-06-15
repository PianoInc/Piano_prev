//
//  View.swift
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

public extension AnchorView {
    
    /**
     Constraints 정의 helper.
     - parameter closure : View에 대한 constraints 선언부.
     */
    public func anchor(_ closure: (AnchorMaker) -> ()) {
        AnchorMaker.make(self, closure: closure)
    }
    
}

