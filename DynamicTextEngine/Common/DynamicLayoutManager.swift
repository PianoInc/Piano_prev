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
    
//    override func fillBackgroundRectArray(_ rectArray: UnsafePointer<CGRect>, count rectCount: Int, forCharacterRange charRange: NSRange, color: UIColor) {
//
//        let glyphRange = self.glyphRange(forCharacterRange: NSMakeRange(charRange.upperBound-1, 1), actualCharacterRange: nil)
//
//
//        let rect = boundingRect(forGlyphRange: glyphRange, in: textContainers.first!)
//
//        if rect.maxX == UIScreen.main.bounds.width {
//            return
//        }
//        print(rectArray.pointee.maxX, rect.maxX)
////        if rect.origin.x + rect.size.width < rectArray.pointee.origin.x + rectArray.pointee.size.width {
////            print("야")
////        } else if rect.origin.x + rect.size.width == rectArray.pointee.origin.x + rectArray.pointee.size.width {
////
////        } else {
////            print("맨")
////        }
//
//
////        print("rectArray.pointee: \(rectArray.pointee), rectCount: \(rectCount), charRange: \(charRange)")
//        super.fillBackgroundRectArray(rectArray, count: rectCount, forCharacterRange: charRange, color: color)
//    }

    
}

extension NSAttributedStringKey {
    public static let animatingBackground = NSAttributedStringKey(rawValue: "animatingBackground")
}
