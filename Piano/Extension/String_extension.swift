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
    
    /// 해당 string과 동일한 id의 LocalizedString을 반환한다.
    var loc: String {
        return NSLocalizedString(self, comment: self)
    }
    
    /**
     앞에서부터 찾고자 하는 string의 index를 반환한다.
     - parameter of : 찾고자 하는 string.
     - returns : 찾고자 하는 string의 index값.
     */
    func index(of: String) -> Int {
        if let range = range(of: of) {
            return distance(from: startIndex, to: range.lowerBound)
        } else {
            return 0
        }
    }
    
    /**
     앞에서부터 특정 위치까지 찾고자 하는 string의 index를 반환한다.
     - parameter of : 찾고자 하는 string.
     - parameter from : Start index값.
     - returns : 찾고자 하는 string의 index값.
     */
    func index(of: String, from: Int) -> Int {
        let fromIndex = index(startIndex, offsetBy: from)
        let startRange = Range(uncheckedBounds: (lower: fromIndex, upper: endIndex))
        if let range = range(of: of, range: startRange, locale: nil) {
            return distance(from: startIndex, to: range.lowerBound)
        } else {
            return 0
        }
    }
    
    /**
     뒤에서부터 찾고자 하는 string의 index를 반환한다.
     - parameter lastOf : 찾고자 하는 string.
     - returns : 찾고자 하는 string의 index값.
     */
    func index(lastOf: String) -> Int {
        if let range = range(of: lastOf, options: .backwards, range: nil, locale: nil) {
            return distance(from: startIndex, to: range.upperBound)
        } else {
            return 0
        }
    }
    
    /**
     뒤에서부터 특정 위치까지 찾고자 하는 string의 index를 반환한다.
     - parameter lastOf : 찾고자 하는 string.
     - parameter to : End index값.
     - returns : 찾고자 하는 string의 index값.
     */
    func index(lastOf: String, to: Int) -> Int {
        let toIndex = index(startIndex, offsetBy: to)
        let startRange = Range(uncheckedBounds: (lower: toIndex, upper: endIndex))
        if let range = range(of: lastOf, range: startRange, locale: nil) {
            return distance(from: startIndex, to: range.upperBound)
        } else {
            return 0
        }
    }
    
    /**
     Subtring값을 반환한다.
     - parameter r : [value ..< value]
     - returns : 해당 range만큼의 string값.
     */
    func sub(_ r: CountableRange<Int>) -> String {
        let from = (r.startIndex > 0) ? index(startIndex, offsetBy: r.startIndex) : startIndex
        let to = (count > r.endIndex) ? index(startIndex, offsetBy: r.endIndex) : endIndex
        if from >= startIndex && to <= endIndex {
            return String(self[from..<to])
        }
        return self
    }
    
    /**
     Subtring값을 반환한다.
     - parameter r : [value ... value]
     - returns : 해당 range만큼의 string값.
     */
    func sub(_ r: CountableClosedRange<Int>) -> String {
        return sub(r.lowerBound..<r.upperBound)
    }
    
    /**
     Subtring값을 반환한다.
     - parameter r : [value ...]
     - returns : 해당 range만큼의 string값.
     */
    func sub(_ r: CountablePartialRangeFrom<Int>) -> String {
        return sub(r.lowerBound..<count)
    }
    
    /**
     Subtring값을 반환한다.
     - parameter r : [... value]
     - returns : 해당 range만큼의 string값.
     */
    func sub(_ r: PartialRangeThrough<Int>) -> String {
        return sub(0..<r.upperBound)
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
