//
//  AnchorConstant.swift
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

public protocol AnchorConstant {
    var value: CGFloat {get}
}

public extension AnchorConstant {
    
    var value: CGFloat {
        if let value = self as? Int {
            return CGFloat(value)
        } else if let value = self as? UInt {
            return CGFloat(value)
        } else if let value = self as? Float {
            return CGFloat(value)
        } else if let value = self as? Double {
            return CGFloat(value)
        } else if let value = self as? CGFloat {
            return value
        }
        return 0
    }
    
    
    
}

extension Int: AnchorConstant {}
extension UInt: AnchorConstant {}
extension Float: AnchorConstant {}
extension Double: AnchorConstant {}
extension CGFloat: AnchorConstant {}

