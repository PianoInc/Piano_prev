//
//  AnchorFinalizable.swift
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

public class AnchorFinalizable: NSObject {
    
    let anchorDescription: AnchorDescription
    
    init(_ anchorDescription: AnchorDescription) {
        self.anchorDescription = anchorDescription
    }
    
}

