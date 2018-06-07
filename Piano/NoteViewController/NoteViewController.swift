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
    
    lazy var dataSource: [[CollectionDatable]] = []
    @IBOutlet weak var textView: PianoTextView!
    var type: NoteType!
    var noteID: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard let type = self.type else { return }
        
        switch type {
        case .create(let categoryStr):
            let newModel = RealmNoteModel.getNewModel(content: "", categoryRecordName: categoryStr)
            let id = newModel.id
            ModelManager.saveNew(model: newModel)
            noteID = id
            textView.noteID = noteID
            
        case .open(let noteInfo):
            ()
        case .lock(let noteInfo):
            ()
        case .trash(let noteInfo):
            ()
        default:
            
            ()
        }

        
        setupNavigationBar()
        setupTextView()
        
        setTextViewContainer(view.bounds.size)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textViewBecomeFirstResponderIfNeeded()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController, let imagePickerViewController = navigationController.topViewController as? ImagePickerViewController {
            imagePickerViewController.noteViewController = self
        }
    }
    
    func textViewBecomeFirstResponderIfNeeded() {
        if type.becomeFirstResponder {
            textView.becomeFirstResponder
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
    
    private func setTextViewContainer(_ size: CGSize) {
        if size.width > size.height {
            textView.textContainerInset.left = size.width / 10
            textView.textContainerInset.right = size.width / 10
        } else {
            textView.textContainerInset.left = 0
            textView.textContainerInset.right = 0
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setTextViewContainer(size)
        
        coordinator.animate(alongsideTransition: nil) {[weak self] (_) in
            guard let strongSelf = self else { return }
            
            if !strongSelf.textView.isEditable {
                strongSelf.textView.attachControl()
                
            }
        }
    }
    
    
    func perform(autoCompleteType: AutoComplete.AutoCompleteType) {
        switch autoCompleteType {
        case .calendar:
            print("일정화면을 띄우자")
        case .drawing:
            print("그리기화면을 띄우자")
        case .images:
            performSegue(withIdentifier: ImagePickerViewController.identifier, sender: nil)
            print("앨범을 띄우자")
        case .map:
            print("지도를 띄우자")
        }
    }

}

extension NoteViewController {
    struct NoteInfo {
        let id: String
        let isShared: Bool
        let isPinned: Bool
    }
    
    enum NoteType {
        case create(String) //CategoryStr
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
                barButton1.tintColor = .black
                barButton2.tintColor = .black
                return [barButton2, barButton1]
            case .open(let info):
                let barButton1 = UIBarButtonItem(image: #imageLiteral(resourceName: "piano"), style: .plain, target: vc, action: #selector(NoteViewController.tapPiano))
                let barButton2 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: vc, action: #selector(NoteViewController.tapShare))
                barButton1.tintColor = .black
                barButton2.tintColor = .black
                return [barButton2, barButton1]
                
            case .trash(let info):
                let barButton1 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: vc, action: #selector(NoteViewController.tapShare))
                let barButton2 = UIBarButtonItem(title: "복구하기", style: .plain, target: vc, action: #selector(NoteViewController.tapRestore))
                let barButton3 = UIBarButtonItem(title: "영구삭제", style: .plain, target: vc, action: #selector(NoteViewController.tapCompletelyDelete))
                barButton1.tintColor = .black
                barButton2.tintColor = .black
                barButton3.tintColor = .black
                
                return [barButton3, barButton2, barButton1]
                
            case .lock(let info):
                let barButton1 = UIBarButtonItem(image: #imageLiteral(resourceName: "piano"), style: .plain, target: vc, action: #selector(NoteViewController.tapPiano))
                let barButton2 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: vc, action: #selector(NoteViewController.tapShare))
                let barButton3 = UIBarButtonItem(title: "잠금해제", style: .plain, target: vc, action: #selector(NoteViewController.tapRestore))
                barButton1.tintColor = .black
                barButton2.tintColor = .black
                barButton3.tintColor = .black
                return [barButton3, barButton2, barButton1]
                
                }
                
            }
        }
    }
}

//MARK: TextView
extension NoteViewController {
    private func setupTextView() {
        
//        if #available(iOS 11.0, *) {
//            textView.textDragDelegate = self
//            textView.textDropDelegate = self
//            textView.pasteDelegate = self
//        }
        
        textView.delegate = self
        textView.DynamicDelegate = self
        textView.DynamicDataSource = self
        let nib = UINib(nibName: TextImageCell.identifier, bundle: nil)
        textView.register(nib: nib, forCellReuseIdentifier: TextImageCell.identifier)
        if type.textViewEditable {
            
        }
    }
}

extension NoteViewController: UITextViewDelegate {
    var typingButtons: [UIBarButtonItem] {
        let completeButton = UIBarButtonItem(title: NSLocalizedString("Complete", comment: "완료"), style: .plain, target: self, action: #selector(NoteViewController.tapComplete(sender:)))
        let copyAllButton = UIBarButtonItem(title: NSLocalizedString("CopyAll", comment: "전체복사"), style: .plain, target: self, action: #selector(NoteViewController.tapCopyAll(sender:)))
        completeButton.tintColor = .black 
        copyAllButton.tintColor = .black
        return [completeButton, copyAllButton]
    }
    
    @objc func tapComplete(sender: UIBarButtonItem) {
        textView.resignFirstResponder()
    }
    
    @objc func tapCopyAll(sender: UIBarButtonItem) {
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //네비게이션바에 타이핑용 아이템들 세팅하기
        navigationItem.setRightBarButtonItems(typingButtons, animated: true)
    }
//
    func textViewDidEndEditing(_ textView: UITextView) {
        //내비게이션바에 디폴트 아이템들 세팅하기
        navigationItem.setRightBarButtonItems(type.rightBarItems(self), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard let textView = scrollView as? PianoTextView,
            !textView.isEditable else { return }
        textView.attachControl()
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        guard let textView = scrollView as? PianoTextView,
            !textView.isEditable,
            !decelerate else { return }
        textView.attachControl()
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        guard let textView = scrollView as? PianoTextView,
            !textView.isEditable else { return }
        textView.detachControl()
        
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        showAutoCompleteTableViewIfNeeded(in: textView)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        (textView as? PianoTextView)?.hideAutoCompleteCollectionViewIfNeeded()
    }

    
    func showAutoCompleteTableViewIfNeeded(in textView: UITextView) {
        
        dataSource = []
        
        //#이 문단 맨 앞에 있는지, position이 있는지 판단
        guard let range = rangeAfterSharp(textView: textView) else {
            (textView as? PianoTextView)?.hideAutoCompleteCollectionViewIfNeeded()
            return }
        
        //커서 frame과 샾 뒤에 글자 추출
        let matchedText = (textView.text as NSString).substring(with: range)
        
        if matchedText.isEmpty {
            dataSource = [AutoComplete.all]
            showAutoCompleteCollectionView(in: textView)
            return
        } else {
            let completes = AutoComplete.all.compactMap { (complete) -> AutoComplete? in
                return complete.type.string.hangul.contains(matchedText.hangul) ? complete : nil
            }
            dataSource = [completes]
            if !dataSource.first!.isEmpty {
                showAutoCompleteCollectionView(in: textView)
                return
            }
        }
        (textView as? PianoTextView)?.hideAutoCompleteCollectionViewIfNeeded()
    }
    
    private func rangeAfterSharp(textView: UITextView) -> NSRange? {
        let paraRange = (textView.text as NSString).paragraphRange(for: textView.selectedRange)
        let regex = "^\\s*(#)(?=)"
        if let (_, range) = textView.text.detect(searchRange: paraRange, regex: regex),
            textView.selectedRange.location >= range.location + 1 {
            
            return NSMakeRange(range.location + 1, textView.selectedRange.location - (range.location + 1))
        }
        return nil
    }
    
    private func showAutoCompleteCollectionView(in textView: UITextView) {
        
        guard let position = textView.selectedTextRange?.end else { return }
        let caretRect = textView.caretRect(for: position)
        
        if let autoCompleteCollectionView = textView.createSubviewIfNeeded(identifier: AutoCompleteCollectionView.identifier) as? AutoCompleteCollectionView {
            
            let cellNib = UINib(nibName: AutoCompleteCell.identifier, bundle: nil)
            
            autoCompleteCollectionView.register(cellNib, forCellWithReuseIdentifier: AutoCompleteCell.identifier)
            autoCompleteCollectionView.dataSource = self
            autoCompleteCollectionView.delegate = self
            autoCompleteCollectionView.reloadData()
            let indexPath = IndexPath(item: 0, section: 0)
            autoCompleteCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            textView.addSubview(autoCompleteCollectionView)
            autoCompleteCollectionView.setPosition(textView: textView, at: caretRect)
            
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
