//
//  AnchorAttribute.swift
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

struct AnchorAttribute : OptionSet {
    
    private(set) var rawValue: UInt
    
    init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    static var leading: AnchorAttribute {return self.init(rawValue: 0)}
    static var trailing: AnchorAttribute {return self.init(rawValue: 1)}
    static var top: AnchorAttribute {return self.init(rawValue: 2)}
    static var bottom: AnchorAttribute {return self.init(rawValue: 3)}
    static var width: AnchorAttribute {return self.init(rawValue: 4)}
    static var height: AnchorAttribute {return self.init(rawValue: 5)}
    static var centerX: AnchorAttribute {return self.init(rawValue: 6)}
    static var centerY: AnchorAttribute {return self.init(rawValue: 7)}
    
}

