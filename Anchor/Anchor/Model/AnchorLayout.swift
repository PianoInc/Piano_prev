//
//  AnchorLayout.swift
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

protocol AnchorType {}

struct AnchorX: AnchorType {
    let s: NSLayoutXAxisAnchor
    let t: NSLayoutXAxisAnchor
}

struct AnchorY: AnchorType {
    let s: NSLayoutYAxisAnchor
    let t: NSLayoutYAxisAnchor
}

struct AnchorDimension: AnchorType {
    let s: NSLayoutDimension
    let t: NSLayoutDimension
}

/// NSLayoutAnchor의 집합.
public class AnchorLayout {
    
    private var x: AnchorX?
    private var y: AnchorY?
    private var dimension: AnchorDimension?
    
    var layout: AnchorType? {
        return x ?? y ?? dimension
    }
    
    init(_ x: AnchorX) {
        self.x = x
    }
    
    init(_ y: AnchorY) {
        self.y = y
    }
    
    init(_ dimension: AnchorDimension) {
        self.dimension = dimension
    }
    
}

