//
//  PianoLabel.swift
//  Piano
//
//  Created by Kevin Kim on 2018. 6. 1..
//  Copyright © 2018년 Piano. All rights reserved.
//

import Foundation
import CoreGraphics

struct Piano {
    let characterRect: CGRect
    let characterRange: NSRange
    let characterOriginCenter: CGPoint
    let characterText: String
    var characterAttrs: [NSAttributedStringKey : Any]
}

class PianoLabel: Label {
    
    var data: Piano? {
        didSet {
            guard let data = self.data else { return }
            frame = data.characterRect
            attributedText = NSAttributedString(string: data.characterText, attributes: data.characterAttrs)
        }
    }
}
