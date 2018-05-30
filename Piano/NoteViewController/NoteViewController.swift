//
//  NoteViewController.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit
import DynamicTextEngine_iOS

class NoteViewController: UIViewController {
    
    var type: NoteType!
    @IBOutlet weak var textView: DynamicTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupNavigationBar()
        setupTextView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textViewBecomeFirstResponderIfNeeded()
        
    }
    
    func textViewBecomeFirstResponderIfNeeded() {
        if type.becomeFirstResponder {
            //textView.becomeFirstResponder
        }
    }

}

extension NoteViewController {
    struct NoteInfo {
        let id: String
        let isShared: Bool
    }
    
    enum NoteType {
        case create(NoteInfo)
        case open(NoteInfo)
        case trash(NoteInfo)
        case lock(NoteInfo)
        
        var id: String {
            switch self {
            case .create(let info), .lock(let info), .open(let info), .trash(let info):
                return info.id
            }
        }
        
        var becomeFirstResponder: Bool {
            switch self {
            case .create:
                return true
            case .lock, .open, .trash:
                return false
            }
        }
        
        var textViewEditable: Bool {
            switch self {
            case .create, .open, .lock:
                return true
            case .trash:
                return false
            }
        }
        
        var isShared: Bool {
            switch self {
            case .create(let info), .lock(let info), .open(let info), .trash(let info):
                return info.isShared
            }
        }
        
        var rightBarItems: [UIBarButtonItem] {
            switch self {
            case .create(let info), .open(let info):
                let barButton1 = UIBarButtonItem(image: #imageLiteral(resourceName: "piano"), style: .plain, target: self, action: #selector(NoteViewController.tapPiano))
                let barButton2 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: self, action: #selector(NoteViewController.tapShare))
                return [barButton1, barButton2]
                
            case .trash(let info):
                let barButton1 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: self, action: #selector(NoteViewController.tapShare))
                let barButton2 = UIBarButtonItem(title: "복구하기", style: .plain, target: self, action: #selector(NoteViewController.tapRestore))
                let barButton3 = UIBarButtonItem(title: "영구삭제", style: .plain, target: self, action: #selector(NoteViewController.tapCompletelyDelete))
                return [barButton1, barButton2, barButton3]
                
            case .lock(let info):
                let barButton1 = UIBarButtonItem(image: #imageLiteral(resourceName: "piano"), style: .plain, target: self, action: #selector(NoteViewController.tapPiano))
                let barButton2 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: self, action: #selector(NoteViewController.tapShare))
                let barButton3 = UIBarButtonItem(title: "잠금해제", style: .plain, target: self, action: #selector(NoteViewController.tapRestore))
                return [barButton1, barButton2, barButton3]
                
            }
        }
    }
}

//MARK: TextView
extension NoteViewController {
    private func setupTextView() {
        if type.textViewEditable {
            
        }
    }
}


//MARK: NavigationController
extension NoteViewController {
    private func setupNavigationBar() {
        navigationItem.setRightBarButtonItems(type.rightBarItems, animated: true)
    }
    
    @objc func tapPiano() {
        
    }
    
    @objc func tapShare() {
        
    }
    
    @objc func tapRestore() {
        
    }
    
    @objc func tapCompletelyDelete() {
        
    }
    
    @objc func tapUnlock() {
        
    }
}
