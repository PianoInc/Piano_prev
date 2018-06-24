//
//  FontManager.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation
import UIKit

class FontManager {
    static let shared = FontManager()

    private init() {}

    ///각 상황에맞는 font descriptor를 얻기 위해 종류별 Font 객체들
    private var customFont = UIFont.systemFont(ofSize: 17)
    private var customBoldFont = UIFont.boldSystemFont(ofSize: 17)
    private var customExtraBoldFont = UIFont.systemFont(ofSize: 17, weight: .heavy)

    
    ///Descriptor getter들. Italic의 경우는 특정한 rotation matrix를 통해 descriptor를 얻는다.
    private func getFontDescriptor() -> UIFontDescriptor {
        return customFont.fontDescriptor
    }

    private func getBoldFontDescriptor() -> UIFontDescriptor {
        return customBoldFont.fontDescriptor
    }

    private func getItalicFontDescriptor() -> UIFontDescriptor {
        let matrix = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(Float(11*Double.pi/180.0))), d: 1, tx: 0, ty: 0)
        return customFont.fontDescriptor.withMatrix(matrix)
    }

    private func getBoldItalicFontDescriptor() -> UIFontDescriptor {
        let matrix = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(Float(11*Double.pi/180.0))), d: 1, tx: 0, ty: 0)
        return customBoldFont.fontDescriptor.withMatrix(matrix)
    }

    ///FontTraits(bold, italic등)에 따른 descriptor 리턴
    private func getDescriptor(from traits: FontTraits) -> UIFontDescriptor {
        if traits.contains(.bold) && traits.contains(.italic){
            return getBoldItalicFontDescriptor()
        } else if traits.contains(.bold) {
            return getBoldFontDescriptor()
        } else if traits.contains(.italic) {
            return getItalicFontDescriptor()
        } else {
            return getFontDescriptor()
        }
    }
    
    ///Size가 .title1일 경우 extra bold폰트 descriptor를 사용하는 룰때문에 존재하는 메소드. extra bold폰트 descriptor 리턴
    private func getDescriptor(by size: FontSizeCategory) -> UIFontDescriptor {
        return size == .title1 ? customExtraBoldFont.fontDescriptor: customBoldFont.fontDescriptor
    }
    
    private func getOffsetFromSize() -> CGFloat {
        switch PianoNoteSizeInspector.shared.get() {
        case .verySmall: return -8.0
        case .small: return -4.0
        case .normal: return 0.0
        case .large: return 4.0
        case .veryLarge: return 8.0
        }
    }

    private func getSize(from category: FontSizeCategory) -> CGFloat{
        let offset = getOffsetFromSize()
        switch category {
            case .title1: return 45.0 + offset
            case .title2: return 30.0 + offset
            case .title3: return 22.0 + offset
            case .body: return 17.0 + offset
        }
    }

    ///Font attribute에 해당하는 font 리턴
    func font(for attribute: PianoFontAttribute) -> UIFont {
        
        let size = getSize(from: attribute.sizeCategory)
        let descriptor = attribute.sizeCategory == .body ? getDescriptor(from: attribute.traits)
            : getDescriptor(by: attribute.sizeCategory)

        return UIFont(descriptor: descriptor, size: size)
    }
}
