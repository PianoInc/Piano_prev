//
//  PianoTextView_extension.swift
//  Piano
//
//  Created by Kevin Kim on 2018. 6. 1..
//  Copyright © 2018년 Piano. All rights reserved.
//

import Foundation
import CoreGraphics
import DynamicTextEngine_iOS

typealias PianoTrigger = () -> [Piano]?

//MARK: Piano
extension PianoTextView {
    
    var lineSpacing: CGFloat { return 12 }
    
    //internal
    internal func beginPiano() {
        operate(on: true)
    }
    
    internal func finishPiano() {
        operate(on: false)
    }
    
    internal func endPiano(with result: [PianoResult]) {
        
        setAttributes(with: result)
        removeCoverView()
        isUserInteractionEnabled = true
    }
    
    internal func attachControl() {
        guard let control = createSubviewIfNeeded(identifier: PianoControl.identifier) as? PianoControl,
            let pianoView = superview?.createSubviewIfNeeded(identifier: PianoView.identifier) as? PianoView else { return }
        control.removeFromSuperview()
        control.textView = self
        control.pianoView = pianoView
        
        let point = CGPoint(x: 0, y: contentOffset.y + contentInset.top)
        var size = bounds.size
        size.height -= (contentInset.top + contentInset.bottom)
        control.frame = CGRect(origin: point, size: size)
        addSubview(control)
    }
    
    internal func detachControl() {
        guard let control = subView(identifier: PianoControl.identifier) as? PianoControl else { return }
        control.removeFromSuperview()
    }
    
    internal func pianoTrigger(touch: Touch) -> PianoTrigger {
        return { [weak self] in
            guard let strongSelf = self,
                let info: (rect: CGRect, range: NSRange, attrString: NSAttributedString) = strongSelf.lineInfo(at: touch) else { return nil }
            
            //이미지가 존재할 경우 리턴
            guard !strongSelf.attributedText.containsAttachments(in: info.range),
                info.attrString.length != 0 else { return nil }
            
            strongSelf.addCoverView(rect: info.rect)
            strongSelf.isUserInteractionEnabled = false
            
            return strongSelf.makePianos(info: info)
            
        }
    }
    
    internal var toolbarItems: [BarButtonItem] {
        get {
            let flexibleSpace = BarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil)
            let done = BarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(tapPianoDone(sender:)))
            
            return [flexibleSpace, done, flexibleSpace]
        }
    }
    
    @objc func tapPianoDone(sender: Any) {
        finishPiano()
    }
    
    //private
    private func makePianos(info: (CGRect, NSRange, NSAttributedString)) -> [Piano] {
        let (rect, range, attrText) = info
        return attrText.string.enumerated().map(
            { (index, character) -> Piano in
                //외부 요인에 의한 값들 반영
                var origin = layoutManager.location(forGlyphAt: range.location + index)
                origin.y = rect.origin.y + textContainerInset.top - contentOffset.y
                origin.y += self.frame.origin.y
                origin.x += self.textContainerInset.left
                
                //text
                let characterText = String(character)
                
                //attrs
                var characterAttrs = attrText.attributes(at: index, effectiveRange: nil)
                characterAttrs[.paragraphStyle] = nil
                
                //range
                let characterRange = NSMakeRange(range.location + index, 1)
                
                let characterAttrText = NSAttributedString(string: characterText, attributes: characterAttrs)
                
                //rect
                let characterRect = CGRect(origin: origin, size: CGSize(width: characterAttrText.size().width, height: rect.height))
                
                //center
                let characterOriginCenter = CGPoint(x: characterRect.midX, y: characterRect.midY)
                
                return Piano(characterRect: characterRect, characterRange: characterRange, characterOriginCenter: characterOriginCenter, characterText: characterText, characterAttrs: characterAttrs)
        })
    }
    
    private func lineInfo(at touch: Touch) -> (CGRect, NSRange, NSAttributedString)? {
        guard attributedText.length != 0 else { return nil }
        var point = touch.location(in: self)
        point.y -= textContainerInset.top
        let index = layoutManager.glyphIndex(for: point, in: textContainer)
        var lineRange = NSRange()
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
        let (rect, range) = exclusiveBulletArea(rect: lineRect, in: lineRange)
        let attrText = attributedText.attributedSubstring(from: range)
        return (rect, range, attrText)
    }
    
    private func exclusiveBulletArea(rect: CGRect, in lineRange: NSRange) -> (CGRect, NSRange) {
        var newRect = rect
        var newRange = lineRange
        if let bullet = PianoBullet(text: text, lineRange: lineRange) {
            newRange.length = newRange.length - (bullet.baselineIndex - newRange.location)
            newRange.location = bullet.baselineIndex
            let offset = layoutManager.location(forGlyphAt: bullet.baselineIndex).x
            newRect.origin.x += offset
            newRect.size.width -= offset
        }
        return (newRect, newRange)
    }
    
    private func setAttributes(with results: [PianoResult]) {
        results.forEach { (result) in
            if let color = result.attrs[.backgroundColor] as? Color,
                color == ColorManager.shared.highlightBackground()
                    && textStorage.attributedSubstring(from: NSMakeRange(result.range.upperBound-1, 1)).string == "\n" {
                return
            }
//            let startDate = Date()
            
            textStorage.addAttributes(result.attrs, range: result.range)
            
            
//            let finishDate = Date()
//            print("어트리뷰트 편집시간: \(finishDate.timeIntervalSince(startDate))")
        }
    }
    
    private func addCoverView(rect: CGRect) {
        var correctRect = rect
        correctRect.origin.y += textContainerInset.top
        let coverView = createSubviewIfNeeded(identifier: PianoCoverView.identifier)
        let control = createSubviewIfNeeded(identifier: PianoControl.identifier)
        coverView.backgroundColor = self.backgroundColor
        coverView.frame = correctRect
        insertSubview(coverView, belowSubview: control)
    }
    
    private func removeCoverView(){
        subView(identifier: PianoCoverView.identifier)?.removeFromSuperview()
    }
    
    private func operate(on: Bool) {
        
        setNavigationController(pianoMode: on)
        
        guard let superView = superview,
            let pianoView = (on
                ? superView.createSubviewIfNeeded(identifier: PianoView.identifier)
                : superView.subView(identifier: PianoView.identifier)) as? PianoView,
            let segmentControl = (on
                ? superView.createSubviewIfNeeded(identifier: PianoSegmentControl.identifier)
                : superView.subView(identifier: PianoSegmentControl.identifier)) as? PianoSegmentControl
            else { return }
        
        pianoView.setup(pianoMode: on, to: superView)
        segmentControl.setup(pianoMode: on, to: superView)
        self.setup(pianoMode: on, to: superView)
    }
    
    private func setup(pianoMode: Bool, to view: View) {
        changeStates(for: pianoMode)
        animate(for: pianoMode, to: view)
        setupPianoControl(pianoMode: pianoMode)
    }
    
    private func changeStates(for pianoMode: Bool) {
        isEditable = !pianoMode
        isSelectable = !pianoMode
    }
    
    private func setupPianoControl(pianoMode: Bool) {
        if pianoMode {
            attachControl()
        } else {
            detachControl()
        }
    }
    
    private func animate(for pianoMode: Bool, to view: View) {
        view.constraints.forEach { (constraint) in
            if let identifier = constraint.identifier,
                identifier == ConstraintIdentifier.pianoTextViewTop {
                constraint.constant = pianoMode ? PianoSegmentControl.height : 0
                View.animate(withDuration: 0.3) {
                    view.layoutIfNeeded()
                }
                return
            }
        }
    }
    
    private func setNavigationController(pianoMode: Bool) {
        AppNavigator.currentNavigationController?.setNavigationBarHidden(pianoMode, animated: true)
        AppNavigator.currentViewController?.setToolbarItems(toolbarItems, animated: true)
        AppNavigator.currentNavigationController?.setToolbarHidden(!pianoMode, animated: true)
    }
}

//MARK: AutoComplete
extension PianoTextView {
    
    @objc func newline(sender: KeyCommand) {
        if let collectionView = subView(identifier: AutoCompleteCollectionView.identifier) as? AutoCompleteCollectionView, let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            collectionView.delegate?.collectionView!(collectionView, didSelectItemAt: selectedIndexPath)
        }

    }
    
    @objc func escape(sender: KeyCommand) {
        hideAutoCompleteCollectionViewIfNeeded()
    }
    
    @objc func upArrow(sender: KeyCommand) {
        
        guard let collectionView = subView(identifier: AutoCompleteCollectionView.identifier) as? AutoCompleteCollectionView,
            let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        
        let numberOfRows = collectionView.numberOfItems(inSection: 0)
        
        let newIndexPath: IndexPath
        if selectedIndexPath.item == 0 {
            newIndexPath = IndexPath(row: numberOfRows - 1, section: 0)
        } else {
            newIndexPath = IndexPath(row: selectedIndexPath.item - 1, section: 0)
        }
        
        collectionView.selectItem(at: newIndexPath, animated: false, scrollPosition: .top)
        
    }
    
    @objc func downArrow(sender: KeyCommand) {
        guard let collectionView = subView(identifier: AutoCompleteCollectionView.identifier) as? AutoCompleteCollectionView,
            let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        
        let numberOfRows = collectionView.numberOfItems(inSection: 0)
        
        let newIndexPath: IndexPath
        if selectedIndexPath.item + 1 == numberOfRows {
            newIndexPath = IndexPath(row: 0, section: 0)
        } else {
            newIndexPath = IndexPath(row: selectedIndexPath.item + 1, section: 0)
        }
        
        collectionView.selectItem(at: newIndexPath, animated: false, scrollPosition: .top)
    }
    
    internal func hideAutoCompleteCollectionViewIfNeeded(){
        subView(identifier: AutoCompleteCollectionView.identifier)?.removeFromSuperview()
    }
}

