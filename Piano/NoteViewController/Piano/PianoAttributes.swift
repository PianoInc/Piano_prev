//
//  PianoAttributes.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation
import CoreGraphics

enum PianoAttributes: Int {
    case foregroundColor = 0
    case backgroundColor
    case strikeThrough
    case bold
    case italic
    case underline
    case header1
    case header2
    case header3
    
    func addAttribute(from attr: [NSAttributedStringKey : Any]) -> [NSAttributedStringKey : Any] {
        
        var newAttr = attr
        switch self {
        case .foregroundColor:
            newAttr[.foregroundColor] = ColorManager.shared.pointForeground()
            
        case .backgroundColor:
            newAttr[.backgroundColor] = ColorManager.shared.highlightBackground()
            
        case .strikeThrough:
            newAttr[.strikethroughStyle] = 1
            newAttr[.strikethroughColor] = ColorManager.shared.underLine()
            
        case .bold, .italic:
            let fontAttribute = newAttr[.pianoFontInfo] as? PianoFontAttribute ?? PianoFontAttribute.standard()
            let newTraits = fontAttribute.traits.union( self == .bold ? [.bold] : [.italic])
            let newFontAttribute = PianoFontAttribute(traits: newTraits, sizeCategory: fontAttribute.sizeCategory)

            newAttr[.pianoFontInfo] = newFontAttribute
            newAttr[.font] = newFontAttribute.getFont()

        case .underline:
            newAttr[.underlineStyle] = 1
            newAttr[.underlineColor] = ColorManager.shared.underLine()
            
        case .header1:
            let fontAttribute = PianoFontAttribute(traits: [], sizeCategory: .title1)
            newAttr[.pianoFontInfo] = fontAttribute
            newAttr[.font] = fontAttribute.getFont()
            
        case .header2:
            let fontAttribute = PianoFontAttribute(traits: [], sizeCategory: .title2)
            newAttr[.pianoFontInfo] = fontAttribute
            newAttr[.font] = fontAttribute.getFont()
            
        case .header3:
            let fontAttribute = PianoFontAttribute(traits: [], sizeCategory: .title3)
            newAttr[.pianoFontInfo] = fontAttribute
            newAttr[.font] = fontAttribute.getFont()
            
        }
        
        return newAttr
        
    }
    
    func removeAttribute(from attr: [NSAttributedStringKey : Any]) -> [NSAttributedStringKey : Any] {
        
        var newAttr = attr
        switch self {
        case .foregroundColor:
            newAttr[.foregroundColor] = Color.basic
            
        case .backgroundColor:
            newAttr[.backgroundColor] = Color.clear
            
        case .strikeThrough:
            newAttr[.strikethroughStyle] = 0
            
        case .bold, .italic:
            let fontAttribute = newAttr[.pianoFontInfo] as? PianoFontAttribute ?? PianoFontAttribute.standard()
            let newTraits = fontAttribute.traits.subtracting(self == .bold ? .bold : .italic)
            let newFontAttribute = PianoFontAttribute(traits: newTraits, sizeCategory: fontAttribute.sizeCategory)

            newAttr[.pianoFontInfo] = newFontAttribute
            newAttr[.font] = newFontAttribute.getFont()

        case .underline:
            newAttr[.underlineStyle] = 0
            
            
        case .header1, .header2, .header3:
            let sizeCategory: FontSizeCategory
            
            switch self {
                case .header1: sizeCategory = .title1
                case .header2: sizeCategory = .title2
                case .header3: sizeCategory = .title3
                default: return newAttr
            }
            
            guard let fontAttribute = newAttr[.pianoFontInfo] as? PianoFontAttribute,
                fontAttribute.sizeCategory == sizeCategory else {return newAttr}
            
            newAttr[.pianoFontInfo] = nil
            newAttr[.font] = PianoFontAttribute.standard().getFont()
            
        }
        
        return newAttr
        
    }
    
}
