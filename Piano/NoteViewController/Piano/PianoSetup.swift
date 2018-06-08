//
//  PianoType.swift
//  PianoNote
//
//  Created by Kevin Kim on 26/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

protocol PianoSetup {
    func setup(pianoMode: Bool, to view: UIView)
}

extension PianoView: PianoSetup {
    
    func setup(pianoMode: Bool, to view: UIView) {
        
        if pianoMode {
            guard let pianoView = view.createSubviewIfNeeded(PianoView.self) else { return }
            view.addSubview(pianoView)
            pianoView.translatesAutoresizingMaskIntoConstraints = false
            let topAnchor = pianoView.topAnchor.constraint(equalTo: view.topAnchor)
            let leadingAnchor = pianoView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let trailingAnchor = pianoView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            let bottomAnchor = pianoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            NSLayoutConstraint.activate([topAnchor, leadingAnchor, trailingAnchor, bottomAnchor])
            
        } else {
            guard let pianoView = view.subView(PianoView.self) else { return }
            pianoView.removeFromSuperview()
        }
        
    }
}

extension PianoSegmentControl: PianoSetup {
    func setup(pianoMode: Bool, to view: UIView) {
        
        if pianoMode {
            guard let segmentControl = view.createSubviewIfNeeded(PianoSegmentControl.self),
                let pianoView = view.createSubviewIfNeeded(PianoView.self),
                let textView = view.createSubviewIfNeeded(PianoTextView.self) else { return }
            view.insertSubview(segmentControl, belowSubview: textView)
            segmentControl.pianoView = pianoView
            segmentControl.tapColor("")
            
            segmentControl.translatesAutoresizingMaskIntoConstraints = false
            let topAnchor = segmentControl.topAnchor.constraint(equalTo: view.topAnchor)
            topAnchor.identifier = ConstraintIdentifier.pianoSegmentControlTop
            let leadingAnchor = segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let trailingAnchor = segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            let heightAnchor = segmentControl.heightAnchor.constraint(equalToConstant: PianoSegmentControl.height)
            NSLayoutConstraint.activate([topAnchor, leadingAnchor, trailingAnchor, heightAnchor])
            
        } else {
            guard let segmentControl = view.subView(PianoSegmentControl.self) else { return }
            UIView.animate(withDuration: 0.33, animations: {
                view.constraints.forEach { (constraint) in
                    if let identifier = constraint.identifier,
                        identifier == ConstraintIdentifier.pianoSegmentControlTop {
                        constraint.constant = pianoMode ? 0 : PianoSegmentControl.height
                        view.layoutIfNeeded()
                        return
                    }
                }
            }, completion: { (bool) in
                if bool {
                    segmentControl.removeFromSuperview()
                }
            })
        }
    }
}

extension PianoControl: PianoSetup {
    func setup(pianoMode: Bool, to view: UIView) {

        if pianoMode {
            guard let controlView = view.createSubviewIfNeeded(PianoControl.self),
                let pianoView = view.createSubviewIfNeeded(PianoView.self),
                let textView = view.createSubviewIfNeeded(PianoTextView.self) else { return }
            controlView.pianoView = pianoView
            controlView.textView = textView
            
            controlView.translatesAutoresizingMaskIntoConstraints = false
            let topAnchor = controlView.topAnchor.constraint(equalTo: view.topAnchor)
            let leadingAnchor = controlView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let trailingAnchor = controlView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            let bottomAnchor = controlView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            NSLayoutConstraint.activate([topAnchor, leadingAnchor, trailingAnchor, bottomAnchor])
        }
    
    }
}




