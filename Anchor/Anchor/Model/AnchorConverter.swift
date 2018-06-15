//
//  AnchorConverter.swift
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

enum AttributeType {
    case X, Y, Dimension
}

/// AnchorDescription를 처리하여 NSLayoutConstraint로 변환한다.
class AnchorConverter: NSObject {
    
    var anchorDescription: AnchorDescription?
    
    /// Converter 작동 closure.
    func constraint(_ closure: (NSLayoutConstraint) -> ()) {
        guard let attribute = anchorDescription?.attribute else {return}
        switch attribute {
        case .leading, .trailing, .centerX: relate(type: .X, closure)
        case .top, .bottom, .centerY: relate(type: .Y, closure)
        case .width, .height: relate(type: .Dimension, closure)
        default: break
        }
    }
    
    private func relate(type: AttributeType, _ closure: (NSLayoutConstraint) -> ()) {
        guard let relation = anchorDescription?.relation else {return}
        switch relation {
        case .equalTo:
            if let value = equalTo() {closure(value)}
        case .lessThanOrEqualTo:
            if let value = lessThanOrEqualTo() {closure(value)}
        case .greaterThanOrEqualTo:
            if let value = greaterThanOrEqualTo() {closure(value)}
        default: break
        }
    }
    
    private func equalTo() -> NSLayoutConstraint? {
        guard let description = anchorDescription else {return nil}
        guard let target = description.target, let offset = description.offset?.value else {return nil}
        if let x = description.anchor.layout as? AnchorX {
            if let constant = (target as? AnchorConstant)?.value {
                return x.t.constraint(equalTo: x.s, constant: constant + offset)
            } else if let target = target as? NSLayoutAnchor<NSLayoutXAxisAnchor> {
                return x.t.constraint(equalTo: target, constant: offset.value)
            }
        } else if let y = description.anchor.layout as? AnchorY {
            if let constant = (target as? AnchorConstant)?.value {
                return y.t.constraint(equalTo: y.s, constant: constant + offset)
            } else if let target = target as? NSLayoutAnchor<NSLayoutYAxisAnchor> {
                return y.t.constraint(equalTo: target, constant: offset.value)
            }
        } else if let dimension = description.anchor.layout as? AnchorDimension {
            if let constant = (target as? AnchorConstant)?.value {
                return dimension.t.constraint(equalToConstant: constant + offset)
            } else if let target = target as? NSLayoutAnchor<NSLayoutDimension> {
                return dimension.t.constraint(equalTo: target, constant: offset)
            }
        }
        return nil
    }
    
    private func lessThanOrEqualTo() -> NSLayoutConstraint? {
        guard let description = anchorDescription else {return nil}
        guard let target = description.target, let offset = description.offset?.value else {return nil}
        if let x = description.anchor.layout as? AnchorX {
            if let constant = (target as? AnchorConstant)?.value {
                return x.t.constraint(lessThanOrEqualTo: x.s, constant: constant + offset.value)
            } else if let target = target as? NSLayoutAnchor<NSLayoutXAxisAnchor> {
                return x.t.constraint(lessThanOrEqualTo: target, constant: offset.value)
            }
        } else if let y = description.anchor.layout as? AnchorY {
            if let constant = (target as? AnchorConstant)?.value {
                return y.t.constraint(lessThanOrEqualTo: y.s, constant: constant + offset)
            } else if let target = target as? NSLayoutAnchor<NSLayoutYAxisAnchor> {
                return y.t.constraint(lessThanOrEqualTo: target, constant: offset)
            }
        } else if let dimension = description.anchor.layout as? AnchorDimension {
            if let constant = (target as? AnchorConstant)?.value {
                return dimension.t.constraint(lessThanOrEqualToConstant: constant + offset)
            } else if let target = target as? NSLayoutAnchor<NSLayoutDimension> {
                return dimension.t.constraint(lessThanOrEqualTo: target, constant: offset)
            }
        }
        return nil
    }
    
    private func greaterThanOrEqualTo() -> NSLayoutConstraint? {
        guard let description = anchorDescription else {return nil}
        guard let target = description.target, let offset = description.offset?.value else {return nil}
        if let x = description.anchor.layout as? AnchorX {
            if let constant = (target as? AnchorConstant)?.value {
                return x.t.constraint(greaterThanOrEqualTo: x.s, constant: constant + offset)
            } else if let target = target as? NSLayoutAnchor<NSLayoutXAxisAnchor> {
                return x.t.constraint(greaterThanOrEqualTo: target, constant: offset)
            }
        } else if let y = description.anchor.layout as? AnchorY {
            if let constant = (target as? AnchorConstant)?.value {
                return y.t.constraint(greaterThanOrEqualTo: y.s, constant: constant + offset)
            } else if let target = target as? NSLayoutAnchor<NSLayoutYAxisAnchor> {
                return y.t.constraint(greaterThanOrEqualTo: target, constant: offset)
            }
        } else if let dimension = description.anchor.layout as? AnchorDimension {
            if let constant = (target as? AnchorConstant)?.value {
                return dimension.t.constraint(greaterThanOrEqualToConstant: constant + offset)
            } else if let target = target as? NSLayoutAnchor<NSLayoutDimension> {
                return dimension.t.constraint(greaterThanOrEqualTo: target, constant: offset)
            }
        }
        return nil
    }
    
}

