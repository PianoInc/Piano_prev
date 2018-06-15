//
//  AnchorRelation.swift
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

struct AnchorRelation : OptionSet {
    
    private(set) var rawValue: UInt
    
    init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    static var equalTo: AnchorRelation {return self.init(rawValue: 0)}
    static var lessThanOrEqualTo: AnchorRelation {return self.init(rawValue: 1)}
    static var greaterThanOrEqualTo: AnchorRelation {return self.init(rawValue: 2)}
    
}

