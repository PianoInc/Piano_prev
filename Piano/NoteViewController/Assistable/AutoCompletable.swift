//
//  Assistable.swift
//  AssistView
//
//  Created by Kevin Kim on 10/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import Foundation
import CoreGraphics

/*
< PianoTextView에서 해야할 일 >
 1. assistDatas에 모든 키워드 할당하기
 1. assistDataSource = [] 할당하기
 2. canBecomeFirstResponder를 true로 오버라이드하기
 3. keyCommands에 assistableKeyCommands를 append하여 오버라이드하기
 
 */

protocol AutoCompletable: class where Self: PianoTextView {
    var dataSource: [AutoComplete] { get set }
}

extension AutoCompletable {
    var autoCompletableKeyCommands: [KeyCommand] {
        get {
            guard self.hasSubView(identifier: AutoCompleteTableView.identifier) else { return [] }
            return [
                KeyCommand(input: "UIKeyInputUpArrow", modifierFlags: [], action: #selector(upArrow(sender:))),
                KeyCommand(input: "UIKeyInputDownArrow", modifierFlags: [], action: #selector(downArrow(sender:))),
                KeyCommand(input: "UIKeyInputEscape", modifierFlags: [], action: #selector(escape(sender:))),
                KeyCommand(input: "\r", modifierFlags: [], action: #selector(newline(sender:)))
            ]
        }
    }
    
    func showAutoCompleteTableViewIfNeeded() {
        dataSource = []
        guard let textRange = textRangeAfterSharp(),
            let position = selectedTextRange?.end else {
            hideAutoCompleteTableViewIfNeeded()
                
                return
        }
        
        let caretRect = self.caretRect(for: position)
        let matchedText = (text as NSString).substring(with: textRange)
        
        if matchedText.isEmpty {
            //전체 키워드를 대입
            dataSource = DynamicAttachment.datas
            showAutoCompleteTableView(caretRect)
            return
        } else {
            for var data in DynamicAttachment.datas {
                if data.keyword.hangul.contains(matchedText.hangul) {
                    data.input = matchedText
                    dataSource.append(data)
                }
            }
            if !dataSource.isEmpty {
                showAutoCompleteTableView(caretRect)
                return
            }
        }
        hideAutoCompleteTableViewIfNeeded()
    }
    
    func hideAutoCompleteTableViewIfNeeded() {
        subView(identifier: AutoCompleteTableView.identifier)?.removeFromSuperview()
    }
    
    func replaceProcess() {
        
        guard let tableView = subView(identifier: AutoCompleteTableView.identifier) as? AutoCompleteTableView,
            let selectedIndexPath = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRow(at: selectedIndexPath) as? AutoCompleteTableViewCell,
            let text = cell.titleLabel.text,
            let textRange = textRangeAfterSharp() else { return }
        
        textStorage.replaceCharacters(in: textRange, with: text)
        selectedRange.location += (text.count - textRange.length)
        hideAutoCompleteTableViewIfNeeded()
        
    }
}

extension AutoCompletable {
    private func textRangeAfterSharp() -> NSRange? {
        let paraRange = (text as NSString).paragraphRange(for: selectedRange)
        let regex = "^\\s*(#)(?=)"
        if let (_, range) = text.detect(searchRange: paraRange, regex: regex),
            selectedRange.location >= range.location + 1 {
            
            return NSMakeRange(range.location + 1, selectedRange.location - (range.location + 1))
        }
        return nil
    }
    
    private func showAutoCompleteTableView(_ caretRect: CGRect) {
        if let autoCompleteTableView = createSubviewIfNeeded(identifier: AutoCompleteTableView.identifier) as? AutoCompleteTableView {
            autoCompleteTableView.setup(autoCompletable: self)
            addSubview(autoCompleteTableView)
            autoCompleteTableView.setPosition(textView: self, at: caretRect)
        }
    }
}




