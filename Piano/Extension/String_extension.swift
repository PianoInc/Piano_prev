//
//  String_extension.swift
//  Piano
//
//  Created by Kevin Kim on 29/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreText

extension String {
    
    func localized(withComment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var nsString: NSString {
        return NSString(string: self)
    }
}

extension String {
    func firstLineText(font: Font, width: CGFloat) -> String {
        let attrStr = NSAttributedString(string: self, attributes: [.font : font])
        let frameSetter = CTFramesetterCreateWithAttributedString(attrStr)
        let maxHeight = CGFloat.greatestFiniteMagnitude
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: maxHeight))
        let path = CGPath(rect: rect, transform: nil)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        guard let line = (CTFrameGetLines(frame) as! [CTLine]).first else { return ""}
        return self.sub(0...CTLineGetStringRange(line).length)
    }
}


extension String {
    
    /// 해당 id를 가지는 localized string을 반환한다.
    var locale: String {
        return NSLocalizedString(self, comment: self)
    }
    
    /**
     앞에서부터 해당 문자열의 index를 검출한다.
     - parameter of : 해당 문자열.
     - returns : 검출된 index.
     */
    func index(of: String) -> Int {
        guard let range = range(of: of) else {return 0}
        return distance(from: startIndex, to: range.lowerBound)
    }
    
    /**
     뒤에서부터 해당 문자열의 index를 검출한다.
     - parameter of : 해당 문자열.
     - returns : 검출된 index.
     */
    func index(lastOf: String) -> Int {
        guard let range = range(of: lastOf, options: .backwards) else {return 0}
        return distance(from: startIndex, to: range.upperBound)
    }
    
    /**
     주어진 range의 substring을 반환한다.
     - parameter r : from...to
     */
    func sub(_ r: CountableClosedRange<Int>) -> String {
        return substring(r.lowerBound..<r.upperBound)
    }
    
    /**
     주어진 range의 substring을 반환한다.
     - parameter r : from...
     */
    func sub(_ r: CountablePartialRangeFrom<Int>) -> String {
        return substring(r.lowerBound..<count)
    }
    
    /**
     주어진 range의 substring을 반환한다.
     - parameter r : ...to
     */
    func sub(_ r: PartialRangeThrough<Int>) -> String {
        return substring(0..<r.upperBound)
    }
    
    /// Substring 계산 함수.
    private func substring(_ r: CountableRange<Int>) -> String {
        let from = (r.startIndex > 0) ? index(startIndex, offsetBy: r.startIndex) : startIndex
        let to = (count > r.endIndex) ? index(startIndex, offsetBy: r.endIndex) : endIndex
        guard from >= startIndex && to <= endIndex else {return self}
        return String(self[from..<to])
    }
    
    /**
     해당 String이 가지는 boundingRect중에서 height값을 반환한다.
     - parameter width: 계산에 사용될 width.
     - parameter point: 계산에 사용될 font point size.
     - returns: 주어진 data를 통해 계산된 height값.
     */
    func boundingRect(with width: CGFloat, font point: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let set: StringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let font = [NSAttributedStringKey.font : Font.systemFont(ofSize: point)]
        let contentSize = self.boundingRect(with: size, options: set, attributes: font, context: nil)
        return contentSize.height
    }
    
    /**
     한글을 초,중,종성으로 분리하여준다.
     */
    var hangul: String {
        get {
            let hangle = [
                ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"],
                ["ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ","ㅘ","ㅙ","ㅚ","ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ","ㅡ","ㅢ","ㅣ"],
                ["","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ","ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ","ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
            ]
            
            return reduce("") { result, char in
                
                if case let code = Int(String(char).unicodeScalars.reduce(0, { (value, scalar) -> UInt32 in
                    return value + scalar.value
                })) - 44032, code > -1 && code < 11172 {
                    let cho = code / 21 / 28, jung = code % (21 * 28) / 28, jong = code % 28;
                    return result + hangle[0][cho] + hangle[1][jung] + hangle[2][jong]
                }
                
                return result + String(char)
            }
        }
    }
    
    /**
     정규식 검사 진행
     */
    public func detect(searchRange: NSRange, regex: String) -> (String, NSRange)? {
        
        do {
            let regularExpression = try NSRegularExpression(pattern: regex, options: .anchorsMatchLines)
            guard let result = regularExpression.matches(in: self, options: .withTransparentBounds, range: searchRange).first else { return nil }
            let range = result.range(at: 1)
            let string = (self as NSString).substring(with: range)
            return (string, range)
        } catch {
            print(error.localizedDescription)
        }
        return nil
        
    }
    
}
