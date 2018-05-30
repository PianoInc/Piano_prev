//
//  InteractiveAttachmentModel.swift
//  InteractiveTextEngine_iOS
//
//  Created by Kevin Kim on 27/04/2018.
//
import Foundation

struct DynamicAttachment {
    //TODO: regexs localized ex: regexString.localized
    
    static let datas: [AutoComplete] = {
        return DynamicAttachment.keywords.map{
            return AutoComplete(keyword: $0, input: "")
        }
    }()
    
    static let keywords = ["사진", "링크", "주소", "연락처", "파일", "일정", "미리알림"]
    
    //TODO: regexs localized ex: regexString.localized
    private let regexs: [(type: InteractiveAttachmentType, regex: String)] = [
        (.image, "^\\s*(#\(DynamicAttachment.keywords[0])\\s*)(?=)"),
        (.url, "^\\s*(#\(DynamicAttachment.keywords[1])\\s*)(?=)"),
        (.address, "^\\s*(#\(DynamicAttachment.keywords[2])\\s*)(?=)"),
        (.contact, "^\\s*(#\(DynamicAttachment.keywords[3])\\s*)(?=)"),
        (.file, "^\\s*(#\(DynamicAttachment.keywords[4])\\s*)(?=)"),
        (.calendar, "^\\s*(#\(DynamicAttachment.keywords[5])\\s*)(?=)"),
        (.reminders, "^\\s*(#\(DynamicAttachment.keywords[6])\\s*)(?=)")
    ]
    
    // replace해야하는 범위: 문단의 맨 앞 위치 <= 범위 <=커서의 위치
    
    
    public enum InteractiveAttachmentType {
        case image
        case url
        case address
        case contact
        case file
        case calendar
        case reminders
    }
    
    init?(text: String, selectedRange: NSRange) {
        let nsText = text as NSString
        let paraRange = nsText.paragraphRange(for: selectedRange)
        let searchRange = NSMakeRange(paraRange.location, selectedRange.location - paraRange.location)
        
        for (type, regex) in regexs {
            if let (_, range) = text.detect(searchRange: searchRange, regex: regex) {
                self.range = range
                self.type = type
                self.textRange = NSMakeRange(range.location + range.length,
                                             selectedRange.location - (range.location + range.length))
                self.paraRange = paraRange
                return
            }
        }
        
        return nil
    }
    
    public let range: NSRange
    public let textRange: NSRange
    public let paraRange: NSRange
    public let type: InteractiveAttachmentType
    
    
    //TODO: 이부분 만들어야함
//    public func attachment() -> InteractiveTextAttachment {
//        
//        return InteractiveTextAttachment()
//    }
}
