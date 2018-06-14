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
import RxCocoa
import RxSwift
import EventKitUI

class NoteViewController: UIViewController {
    
    var noteType: NoteType!
    lazy var dataSource: [[CollectionDatable]] = []
    
    

    @IBOutlet weak var textView: PianoTextView!
    var noteID: String!
    var isSaving: Bool = false
    var initialImageRecordNames: Set<String> = []
    let disposeBag = DisposeBag()
    var synchronizer: NoteSynchronizer!
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
     
        super.viewDidLoad()
        
        guard let noteType = self.noteType else { return }
        
        switch noteType {
        case .create(let categoryStr):
            let newModel = RealmNoteModel.getNewModel(content: "", categoryRecordName: categoryStr)
            let id = newModel.id
            ModelManager.saveNew(model: newModel)
            noteID = id
            textView.noteID = noteID
            textView.becomeFirstResponder()
            
        case .open(let noteInfo):
            ()
        case .lock(let noteInfo):
            ()
        case .trash(let noteInfo):
            ()
        default:
            
            ()
        }
        
        if let realm = try? Realm(),
            let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID),
            let code = ColorPreset(rawValue: note.colorThemeCode) {
            
            resetColors(code: code)
        }

        setTextViewContainer(view.bounds.size)
        setFormAttributes()
        setDelegates()
        registerNibs() //카드관련
        setNavigationBar()
        
        textView.noteID = noteID
        textView.typingAttributes = FormAttributes.defaultTypingAttributes
        
        synchronizer = NoteSynchronizer(textView: textView)
        synchronizer?.registerToCloud()
        
        setNoteContents()
        subscribeToChange()

        
    }
    
    deinit {
        synchronizer?.unregisterFromCloud()
        notificationToken?.invalidate()
        removeGarbageImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unRegisterKeyboardNotification()
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
    
    private func setDelegates() {
        textView.delegate = self
        
        if #available(iOS 11.0, *) {
            textView.textDragDelegate = self
            textView.textDropDelegate = self
            textView.pasteDelegate = self
        }
        
        textView.dynamicDelegate = self
        textView.dynamicDataSource = self
    }
    
    private func resetColors(code: ColorPreset) {
        textView.resetColors(preset: code)
    }
    
    private func registerNibs() {
        
        textView.register(nib: UINib(nibName: "TextImageCell", bundle: nil), forCellReuseIdentifier: TextImageCell.identifier)
        textView.register(nib: UINib(nibName: "TextImageListCell", bundle: nil), forCellReuseIdentifier: TextImageListCell.identifier)
        textView.register(nib: UINib(nibName: "TextEventCell", bundle: nil), forCellReuseIdentifier: TextEventCell.identifier)
        textView.register(nib: UINib(nibName: "TextAddressCell", bundle: nil), forCellReuseIdentifier: TextAddressCell.identifier)

    }
    
    private func setFormAttributes() {
        FormAttributes.defaultFont = PianoFontAttribute.standard().getFont()
        FormAttributes.numFont = UIFont(name: "Avenir Next", size: PianoFontAttribute.standard().getFont().pointSize)!
        FormAttributes.effectColor = ColorManager.shared.pointForeground()
        FormAttributes.defaultColor = ColorManager.shared.defaultForeground()
        FormAttributes.customMakeParagraphStyle = { bullet, spaceCount, tabCount in
            return DynamicParagraphStyle(bullet: bullet, spaceCount: spaceCount, tabCount: tabCount)
        }
        
        
    }
    
    private func setNoteContents() {
        do {
            let realm = try Realm()
            guard let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
            let attributes = try JSONDecoder().decode([AttributeModel].self, from: note.attributes)
            
            textView.set(string: note.content, with: attributes)
            
            let imageRecordNames = attributes.compactMap { attribute -> String? in
                if case let .attachment(reuseIdentifier, id) = attribute.style,
                    reuseIdentifier == TextImageCell.identifier {return id}
                else {return nil}
            }
            
            initialImageRecordNames = Set<String>(imageRecordNames)
            
        } catch {print(error)}
    }
    
    private func subscribeToChange() {
        textView.rx.didChange
            .skip(1)
            .debounce(2.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                DispatchQueue.main.async {
                    self?.saveText(isDeallocating: false)
                }
            }).disposed(by: disposeBag)

        /*
        //TODO: 이 부분 빼도 되지 않나 Check by Zio
        NotificationCenter.default.rx.notification(.pianoSizeInspectorSizeChanged)
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.reset
                }
            }).disposed(by: disposeBag)
        */
        
        
        if let realm = try? Realm(),
            let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) {
            notificationToken = note.observe { [weak self] change in
                switch change {
                case .change(let properties):
                    if let colorThemeCode = (properties.filter{ $0.name == Schema.Note.colorThemeCode }).first?.newValue as? String,
                        let code = ColorPreset(rawValue: colorThemeCode) {
                        self?.resetColors(code: code)
                    }
                default: break
                }
            }
        }
    }
    
    private func resetFonts() {
        self.textView.textStorage.addAttributes([.font: PianoFontAttribute.standard().getFont()], range: NSMakeRange(0, textView.textStorage.length))
        
        self.textView.textStorage.enumerateAttribute(.pianoFontInfo, in: NSMakeRange(0, textView.textStorage.length), options: .longestEffectiveRangeNotRequired) { value, range, _ in
            guard let fontAttribute = value as? PianoFontAttribute else {return}
            let font = fontAttribute.getFont()
            textView.textStorage.addAttribute(.font, value: font, range: range)
        }
    }
    
    private func removeGarbageImages() {
        guard let realm = try? Realm(),
            let noteID = noteID,
            let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
        //get zoneID from record
        let coder = NSKeyedUnarchiver(forReadingWith: note.ckMetaData)
        coder.requiresSecureCoding = true
        guard let record = CKRecord(coder: coder) else {fatalError("Data polluted!!")}
        coder.finishDecoding()
        
        let (_, attributes) = textView.attributedText.getStringWithPianoAttributes()
        
        let imageRecordNames = attributes.map { attribute -> String in
            if case let .attachment(reuseIdentifier, id) = attribute.style,
                reuseIdentifier == TextImageCell.identifier {return id}
            else {return ""}
            }.filter{!$0.isEmpty}
        
        let currentImageRecordNames = Set<String>(imageRecordNames)
        initialImageRecordNames.subtract(currentImageRecordNames)
        
        let deletedImageRecordIDs = Array<String>(initialImageRecordNames).map{ CKRecordID(recordName: $0, zoneID: record.recordID.zoneID)}
        
        if note.isInSharedDB {
            CloudManager.shared.sharedDatabase.delete(recordIDs: deletedImageRecordIDs) { error in
                guard error == nil else { return }
            }
        } else {
            CloudManager.shared.privateDatabase.delete(recordIDs: deletedImageRecordIDs) { error in
                guard error == nil else { return print(error!) }
            }
        }
    }
    
    func saveText(isDeallocating: Bool) {
        if self.isSaving || self.textView.isSyncing {
            return
        }
        let (string, attributes) = self.textView.get()
        let noteID = self.noteID ?? ""
        self.isSaving = true
        
        DispatchQueue.global().async {
            let jsonEncoder = JSONEncoder()
            guard let data = try? jsonEncoder.encode(attributes) else {self.isSaving = false;return}
            let kv: [String: Any] = ["content": string, "attributes": data, "isModified": Date()]
            
            let completion: ((Error?) -> Void)? = isDeallocating ? nil : { [weak self] error in
                if let error = error {print(error)}
                else {print("happy")}
                self?.isSaving = false
            }
            
            ModelManager.update(id: noteID, type: RealmNoteModel.self, kv: kv, completion: completion)
        }
    }
    
    func saveWhenDeallocating() {
        if isSaving {
            return
        }
        let (string, attributes) = textView.get()
        let noteID = self.noteID ?? ""
        guard let data = try? JSONEncoder().encode(attributes) else {isSaving = false;return}
        let kv: [String: Any] = [Schema.Note.content: string,
                                 Schema.Note.attributes: data,
                                 "isModified": Date()]
        
        ModelManager.update(id: noteID, type: RealmNoteModel.self, kv: kv, completion: nil)
    }
    
    
    func perform(autoCompleteType: AutoComplete.AutoCompleteType) {
        switch autoCompleteType {
        case .calendar:
            LocalAuth.share.request(calendar: {
                let eventController = EKEventEditViewController()
                let eventStore = EKEventStore()
                eventController.eventStore = eventStore
                eventController.event = EKEvent(eventStore: eventStore)
                eventController.editViewDelegate = self
                self.present(eventController, animated: true)
            })
        case .drawing:
            let drawingMapCtrl = viewCtrl(type: DrawingMapController.self)
            drawingMapCtrl.noteID = noteID
            drawingMapCtrl.drawDismissed = { [weak self] id in
                self?.attachment(with: id, cellId: TextImageCell.identifier)
            }
            present(drawingMapCtrl, animated: true)
        case .images:
            LocalAuth.share.request(photo: {
                let albumCardCtrl = viewCtrl(type: AlbumCardController.self)
                albumCardCtrl.noteID = self.noteID
                albumCardCtrl.albumDismissed = { [weak self] ids, isGrouped in
                    if isGrouped {
                        self?.attachment(with: ids, cellId: TextImageListCell.identifier)
                    } else {
                        ids.components(separatedBy: "|").forEach {
                            self?.attachment(with: $0, cellId: TextImageCell.identifier)
                        }
                    }
                }
                self.present(UINavigationController(rootViewController: albumCardCtrl), animated: true)
            })
        case .map:
            let cardMapCtrl = viewCtrl(type: CardMapController.self)
            cardMapCtrl.noteID = noteID
            cardMapCtrl.mapDismissed = { [weak self] id in
                self?.attachment(with: id, cellId: TextAddressCell.identifier)
            }
            present(UINavigationController(rootViewController: cardMapCtrl), animated: true)
        }
    }

}

extension NoteViewController: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        dismiss(animated: true)
        guard action != .canceled, let eventIdentifier = controller.event?.eventIdentifier else {return}
        
        guard let realm = try? Realm(),
            let noteModel = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
        let coder = NSKeyedUnarchiver(forReadingWith: noteModel.ckMetaData)
        coder.requiresSecureCoding = true
        guard let record = CKRecord(coder: coder) else {fatalError("Data poluted!!")}
        coder.finishDecoding()
        
        if let eventModel = realm.objects(RealmEventModel.self).filter(NSPredicate(format: "event == %@", eventIdentifier)).first {
            if action == .deleted {
                textView.remove(attachmentID: eventModel.id)
            } else {
                textView.reload(attachmentID: eventModel.id)
            }
        } else {
            let model = RealmEventModel.getNewModel(sharedZoneID: record.recordID.zoneID, noteRecordName: record.recordID.recordName, event: eventIdentifier)
            ModelManager.saveNew(model: model)
            attachment(with: model.id, cellId: TextEventCell.identifier)
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
                let barButton2 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: vc, action: #selector(NoteViewController.tapShare(_:)))
                barButton1.tintColor = .black
                barButton2.tintColor = .black
                return [barButton2, barButton1]
                
            case .trash(let info):
                let barButton1 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: vc, action: #selector(NoteViewController.tapShare(_:)))
                let barButton2 = UIBarButtonItem(title: "복구하기", style: .plain, target: vc, action: #selector(NoteViewController.tapRestore))
                let barButton3 = UIBarButtonItem(title: "영구삭제", style: .plain, target: vc, action: #selector(NoteViewController.tapCompletelyDelete))
                barButton1.tintColor = .black
                barButton2.tintColor = .black
                barButton3.tintColor = .black
                
                return [barButton3, barButton2, barButton1]
                
            case .lock(let info):
                let barButton1 = UIBarButtonItem(image: #imageLiteral(resourceName: "piano"), style: .plain, target: vc, action: #selector(NoteViewController.tapPiano))
                let barButton2 = UIBarButtonItem(image: info.isShared ? #imageLiteral(resourceName: "shareded") : #imageLiteral(resourceName: "share"), style: .plain, target: vc, action: #selector(NoteViewController.tapShare(_:)))
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
        navigationItem.setRightBarButtonItems(noteType.rightBarItems(self), animated: true)
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
        
        if let autoCompleteCollectionView = textView.createSubviewIfNeeded(AutoCompleteCollectionView.self) {
            
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
    private func setNavigationBar() {
        navigationItem.setRightBarButtonItems(noteType.rightBarItems(self), animated: true)
    }
    
    @objc func tapPiano() {
        textView.beginPiano()
    }
    
    @objc func tapShare(_ sender: UIBarButtonItem) {
        presentShare(sender)
    }
    
    @objc func tapRestore() {
        
    }
    
    @objc func tapCompletelyDelete() {
        
    }
    
    @objc func tapUnlock() {
        
    }
}
