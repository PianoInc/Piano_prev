//
//  DynamicLayoutManager.swift
//  DynamicTextEngine
//
//  Created by 김범수 on 2018. 3. 23..
//

import UIKit

class DynamicLayoutManager: NSLayoutManager {
    
    var textView: UITextView?
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        let stringRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        
        textStorage?.enumerateAttribute(.attachment, in: stringRange,
                                        options: [.longestEffectiveRangeNotRequired, .reverse]) { (value, range, _) in

            let currentGlyphRange = glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            guard let container = textContainer(forGlyphAt: currentGlyphRange.location, effectiveRange: nil),
                let attachment = value as? DynamicTextAttachment else {return}

            //Fix bounds for attachment!!

            let currentBounds = self.boundingRect(forGlyphRange: currentGlyphRange, in: container)
                                            
            attachment.currentCharacterIndex = range.location
            attachment.currentBounds = currentBounds
        }

        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
    }

    
}

extension NSAttributedStringKey {
    public static let animatingBackground = NSAttributedStringKey(rawValue: "animatingBackground")
}
