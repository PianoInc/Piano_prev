//
//  PianoTextView.swift
//  Piano
//
//  Created by Kevin Kim on 30/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit
import DynamicTextEngine_iOS

class PianoTextView: DynamicTextView {
    
    var dataSource: [AutoComplete] = []
    
    var isSyncing: Bool = false
    var noteID: String = ""
    
    override var typingAttributes: [String : Any] {
        get {
            return FormAttributes.defaultTypingAttributes
        } set {}
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        //최종 세팅 값
        setup()
    }
    
     //스토리보드 값 세팅해주는 위치
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let newTextView = PianoTextView(frame: self.frame)
        newTextView.autocorrectionType = self.autocorrectionType
        newTextView.backgroundColor = self.backgroundColor
        newTextView.dataDetectorTypes = self.dataDetectorTypes
        newTextView.returnKeyType = self.returnKeyType
        newTextView.keyboardAppearance = self.keyboardAppearance
        newTextView.keyboardDismissMode = self.keyboardDismissMode
        newTextView.keyboardType = self.keyboardType
        newTextView.alwaysBounceVertical = self.alwaysBounceVertical
        newTextView.translatesAutoresizingMaskIntoConstraints = false
        return newTextView
    }
    
    private func setup() {
        textContainer.lineFragmentPadding = 0
        tag = PianoTextView.identifier.hashValue
    }
    
    func getScreenShot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

}

//MARK: AutoCompletable
extension PianoTextView: AutoCompletable {
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var keyCommands: [UIKeyCommand]? {
        var commands: [UIKeyCommand] = []
        commands.append(contentsOf: autoCompletableKeyCommands)
        return commands
    }
}

extension PianoTextView {
    func set(string: String, with attributes: [AttributeModel]) {
        let newAttributedString = NSMutableAttributedString(string: string)
        newAttributedString.addAttributes(FormAttributes.defaultAttributes, range: NSMakeRange(0, newAttributedString.length))
        attributes.forEach{ newAttributedString.add(attribute: $0) }
        
        set(newAttributedString: newAttributedString)
    }
    
    func get() -> (string: String, attributes: [AttributeModel]) {
        
        return attributedText.getStringWithPianoAttributes()
    }
    
    func resetColors(preset: ColorPreset) {
        let foregroundAttributes = get().attributes.filter{ $0.style == .foregroundColor }
        ColorManager.shared.set(preset: preset)
        FormAttributes.defaultColor = ColorManager.shared.defaultForeground()
        FormAttributes.effectColor = ColorManager.shared.pointForeground()
        
        textStorage.addAttribute(.foregroundColor, value: FormAttributes.defaultColor, range: NSMakeRange(0, textStorage.length))
        foregroundAttributes.forEach { textStorage.add(attribute: $0) }
    }
}
