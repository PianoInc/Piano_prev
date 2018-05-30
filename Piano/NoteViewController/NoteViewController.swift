//
//  NoteViewController.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit
import DynamicTextEngine_iOS
import RealmSwift
import CloudKit

class NoteViewController: UIViewController {
    
    
    @IBOutlet weak var textView: PianoTextView!
    var type: NoteType!
    
    
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
    
    private func setLastModifiedString(for noteID: String) {
        guard let realm = try? Realm(),
            let noteModel = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
        
        let coder = NSKeyedUnarchiver(forReadingWith: noteModel.ckMetaData)
        coder.requiresSecureCoding = true
        guard let record = CKRecord(coder: coder) else {fatalError("Data poluted!!")}
        coder.finishDecoding()
        let modifiedDateString = noteModel.isModified.timeFormat
        
        if let lastUser = record.lastModifiedUserRecordID, CloudManager.shared.userID != lastUser {
            
            CKContainer.default().discoverUserIdentity(withUserRecordID: lastUser) { (identity, error) in
                if let nameComponent = identity?.nameComponents {
                    let name = (nameComponent.givenName ?? "") + (nameComponent.familyName ?? "")
                    
                    let modified = "\(name)님이 \(modifiedDateString)에 마지막으로 수정했습니다."
                } else {
                    // default string
                }
            }
            
        } else {
            let modified = "\(modifiedDateString)에 마지막으로 수정했습니다."
        }
    }

}

extension NoteViewController {
    struct NoteInfo {
        let id: String
        let isShared: Bool
    }
    
    enum NoteType {
        case create
        case open(NoteInfo)
        case trash(NoteInfo)
        case lock(NoteInfo)
        
        var id: String? {
            switch self {
            case .lock(let info), .open(let info), .trash(let info):
                return info.id
            case .create:
                return nil
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
            case .create:
                return false
                
            case .lock(let info), .open(let info), .trash(let info):
                return info.isShared
            }
        }
        
        var rightBarItems: ((UIViewController) -> [UIBarButtonItem]) {
            return {vc in
            switch self {
            case .create:
                let barButton1 = UIBarButtonItem(image: #imageLiteral(resourceName: "piano"), style: .plain, target: vc, action: #selector(NoteViewController.tapPiano))
                let barButton2 = UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: .plain, target: vc, action: #selector(NoteViewController.tapShare))
                return [barButton1, barButton2]
            case .open(let info):
                let barButton1 = UIBarButtonItem(image: #imageLiteral(resourceName: "piano"), style: .plain, target: vc, action: #selector(NoteViewController.tapPiano))
                let barButton2 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: vc, action: #selector(NoteViewController.tapShare))
                return [barButton1, barButton2]
                
            case .trash(let info):
                let barButton1 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: vc, action: #selector(NoteViewController.tapShare))
                let barButton2 = UIBarButtonItem(title: "복구하기", style: .plain, target: vc, action: #selector(NoteViewController.tapRestore))
                let barButton3 = UIBarButtonItem(title: "영구삭제", style: .plain, target: vc, action: #selector(NoteViewController.tapCompletelyDelete))
                return [barButton1, barButton2, barButton3]
                
            case .lock(let info):
                let barButton1 = UIBarButtonItem(image: #imageLiteral(resourceName: "piano"), style: .plain, target: vc, action: #selector(NoteViewController.tapPiano))
                let barButton2 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: vc, action: #selector(NoteViewController.tapShare))
                let barButton3 = UIBarButtonItem(title: "잠금해제", style: .plain, target: vc, action: #selector(NoteViewController.tapRestore))
                return [barButton1, barButton2, barButton3]
                
                }
                
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
        navigationItem.setRightBarButtonItems(type.rightBarItems(self), animated: true)
    }
    
    @objc func tapPiano() {
        textView.beginPiano()
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
