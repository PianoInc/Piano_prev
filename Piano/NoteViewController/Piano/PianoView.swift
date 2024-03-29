//
//  PianoView.swift
//  Piano
//
//  Created by Kevin Kim on 28/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

typealias CaptivatePianoResult = ([PianoResult]) -> Void

class PianoView: UIView {
    var attributes: PianoAttributes = .foregroundColor
    var dataSource: [Piano]? {
        didSet {
            if let pianos = self.dataSource {
                createLabels(for: pianos)
                displayLink(on: true)
            } else {
                removeLabels()
                currentFrame = 0
                totalFrame = 0
                progress = 0
                leftEndTouchX = nil
                rightEndTouchX = nil
                animating = false
            }
        }
    }
    
    var pianoLabels: [PianoLabel] = []
    
    func setPianos(trigger: PianoTrigger) {
        guard !animating else { return }
        if dataSource == nil {
            dataSource = trigger()
        }
    }
    
    
    private var totalFrame: Int = 0
    private var currentFrame: Int = 0
    private var progress: CGFloat = 0.0
    
    private var currentTouchX: CGFloat?
    private var leftEndTouchX: CGFloat?
    private var rightEndTouchX: CGFloat?
    internal var animating: Bool = false
    
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(PianoView.displayFrameTick))
        displayLink.add(
            to: RunLoop.current,
            forMode: RunLoopMode.commonModes)
        return displayLink
    }()
    
    
    internal func playPiano(at touch: Touch) {
        
        guard dataSource != nil, !animating else { return }
        let x = touch.location(in: self).x
        updateCoordinateXs(with: x)
        updateLabels(to: x)
        
    }
    
    internal func endPiano(completion: @escaping CaptivatePianoResult) {
        animateToOrigin(completion: completion)
    }
    
}

extension PianoView {
    
    private var cosPeriod_half: CGFloat { return 70 } //이거 Designable
    private var cosMaxHeight: CGFloat { return 35 }  //이것도 Designable
    private var animationDuration: Double { return 0.3 }
    
    @objc private func displayFrameTick() {
        if displayLink.duration > 0.0 && totalFrame == 0 {
            let frameRate = displayLink.duration
            totalFrame = Int(animationDuration / frameRate) + 1
        }
        currentFrame += 1
        if currentFrame <= totalFrame {
            progress += 1.0 / CGFloat(totalFrame)
            guard let touchX = currentTouchX else { return }
            backgroundColor = UIColor.white.withAlphaComponent(progress * 0.9)
            updateLabels(to: touchX)
        } else {
            displayLink(on: false)
        }
    }
    
    internal func updateLabels(to touchX: CGFloat){
        pianoLabels.forEach { (label) in
            applyAttrTo(label, by: touchX)
            move(label, by: touchX)
        }
        
    }
    
    private func move(_ label: PianoLabel, by touchX: CGFloat) {
        guard let data = label.data else { return }
        let distance = abs(touchX - data.characterOriginCenter.x)
        let rect = data.characterRect
        
        if distance < cosPeriod_half {
            let y = cosMaxHeight * (cos(CGFloat.pi * distance / cosPeriod_half ) + 1) * progress
            label.frame.origin.y = rect.origin.y - y
            
            if !(touchX > rect.origin.x && touchX < rect.origin.x + rect.width){
                //TODO: distance = 0일수록 알파값 0.3에 가까워지게 하기
                label.alpha = distance / cosPeriod_half + 0.3
            } else {
                label.alpha = 1
            }
        } else {
            //프레임 원위치로
            label.frame.origin = rect.origin
            //알파값 세팅
            label.alpha = 1
        }
    }
    
    private func applyAttrTo(_ label: PianoLabel, by touchX: CGFloat) {
        
        guard let type = operationType(label: label , by: touchX),
            let data = label.data else { return }
        
        switch type {
        case .apply:
            label.data?.characterAttrs = attributes.addAttribute(from: data.characterAttrs)
        case .remove:
            label.data?.characterAttrs = attributes.removeAttribute(from: data.characterAttrs)
        case .none:
            ()
        }
//        label.sizeToFit()
        
    }
    
    enum PianoOperationType {
        case apply
        case remove
        case none
    }
    
    private func operationType(label: PianoLabel, by touchX: CGFloat) -> PianoOperationType? {
        guard let leftEndTouchX = leftEndTouchX,
            let rightEndTouchX = rightEndTouchX else { return nil }
        
        let applyAttribute = touchX > label.frame.maxX && leftEndTouchX < label.frame.maxX
        let removeAttribute = touchX < label.frame.minX && rightEndTouchX > label.frame.minX
        
        if applyAttribute {
            return .apply
        } else if removeAttribute {
            return .remove
        } else {
            return .none
        }
    }
    
    
    internal func updateCoordinateXs(with pointX: CGFloat) {
        
        leftEndTouchX = leftEndTouchX ?? pointX
        rightEndTouchX = rightEndTouchX ?? pointX
        currentTouchX = pointX
        
        if pointX < leftEndTouchX!{
            leftEndTouchX = pointX
        }
        
        if pointX > rightEndTouchX! {
            rightEndTouchX = pointX
        }
    }
    
    private func displayLink(on: Bool) {
        displayLink.isPaused = !on
    }
    
    internal func animateToOrigin(completion: @escaping CaptivatePianoResult) {
        animating = true
        displayLink(on: false)
        
        
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            self?.backgroundColor = UIColor.white.withAlphaComponent(0)
            self?.pianoLabels.forEach({ (label) in
                guard let rect = label.data?.characterRect else { return }
                label.frame = rect
                label.alpha = 1
            })
        }) { [weak self](_) in
            if let results = self?.pianoResults()
                 {
                    let startDate = Date()
                completion(results)
                    let finishDate = Date()
                    print(finishDate.timeIntervalSince(startDate))
                self?.removeLabels()
                self?.dataSource = nil
            }
        }
    }
    
    private func pianoResults() -> [PianoResult]? {
        return pianoLabels.compactMap {
            guard let data = $0.data else { return nil }
            return PianoResult(range: data.characterRange, attrs: data.characterAttrs)
        }
    }
    
    private func createLabels(for pianos: [Piano]){
        pianoLabels = []
        pianos.forEach { (piano) in
            let label = PianoLabel()
            label.data = piano
            pianoLabels.append(label)
            addSubview(label)
        }
        
    }
    
    private func removeLabels() {
        pianoLabels.forEach { (label) in
            label.removeFromSuperview()
        }
        pianoLabels = []
    }
    
}

