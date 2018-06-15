//
//  AnchorTarget.swift
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

public protocol AnchorTarget {}

extension Int: AnchorTarget {}
extension UInt: AnchorTarget {}
extension Float: AnchorTarget {}
extension Double: AnchorTarget {}
extension CGFloat: AnchorTarget {}
extension NSLayoutXAxisAnchor: AnchorTarget {}
extension NSLayoutYAxisAnchor: AnchorTarget {}
extension NSLayoutDimension: AnchorTarget {}

