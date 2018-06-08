//
//  AutoCompleteCell.swift
//  Piano
//
//  Created by Kevin Kim on 2018. 6. 1..
//  Copyright © 2018년 Piano. All rights reserved.
//

import UIKit

struct AutoComplete: CollectionDatable {
    
    static let all = [
        AutoComplete(type: .images),
        AutoComplete(type: .drawing),
        AutoComplete(type: .calendar),
        AutoComplete(type: .map)
    ]
    
    enum AutoCompleteType {
        case images
        case drawing
        case calendar
        case map
        
        var string: String {
            switch self {
            case .images:
                return NSLocalizedString("Photo", comment: "사진")
            case .drawing:
                return NSLocalizedString("Drawing", comment: "그리기")
            case .calendar:
                return NSLocalizedString("Calendar", comment: "일정")
            case .map:
                return NSLocalizedString("Map", comment: "지도")
            }
        }
    }
    
    let type: AutoCompleteType
    
    var sectionTitle: String?
    var sectionIdentifier: String?
    
    init(type: AutoCompleteType, sectionTitle: String? = nil, sectionIdentifier: String? = nil) {
        self.type = type
        self.sectionTitle = sectionTitle
        self.sectionIdentifier = sectionIdentifier
    }
    
    func didSelectItem(fromVC viewController: ViewController) {
        guard let vc = viewController as? NoteViewController,
            let textView = vc.textView else { return }
        
        //텍스트뷰에서 개행을 제외한 현재 문단을 다 지워버린다.
        let paragraphRange = (textView.text as NSString).paragraphRange(for: textView.selectedRange)
        
        let replaceStr = (textView.text as NSString).substring(with: paragraphRange).contains("\n") ? "\n" : ""
        textView.textStorage.replaceCharacters(in: paragraphRange, with: replaceStr)
        textView.selectedRange.location += (replaceStr.count - paragraphRange.length)
        
        
        //type에 따라 해당 로직을 실행해준다.
        vc.perform(autoCompleteType: type)
        
    }
    
    func size(maximumWidth: CGFloat) -> CGSize {
        return CGSize(width: 150, height: 40)
    }
    

    
}

class AutoCompleteCell: UICollectionViewCell, CollectionDataAcceptable {

    var data: CollectionDatable? {
        didSet {
            guard let data = self.data as? AutoComplete else { return }
            self.titleLabel.text = data.type.string
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView()
        view.backgroundColor = Color.point
        selectedBackgroundView = view
    }
    
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? .white : .black
        }
    }

}
