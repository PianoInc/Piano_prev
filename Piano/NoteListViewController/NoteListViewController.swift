//
//  NoteListViewController.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit
import RealmSwift
import CloudKit

class NoteListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var type: CategoryType!
//    //temp
    var tempSubscription = true
    var tempCalendar = true
    var tempHold = true
    
    lazy var dataSource: [[CollectionDatable]] = {
        
        //TODO: type을 바라보며 데이터 소스 세팅하기
        
        guard let type = self.type else { return []}
        var dataSource: [[CollectionDatable]] = []
        
        
        switch type {
        case .all:
            
            //section 0: 새 메모 작성
            //TODO: description에 대한 모델 대입하기
            let noteCreate: [CollectionDatable] = [NoteCreate(type: .create, title: "새 메모 작성", description: "누구에게 투표했나요? 피아노한테만 알려주세요!")]
            dataSource.append(noteCreate)
            
            
            let realm = try! Realm()
            let objects = realm.objects(RealmNoteModel.self)
            
            
            let holdResults = objects.filter("isPinned = true AND isInTrash = false").sorted(byKeyPath: "isModified", ascending: false)
            let holdNotes: [Note] = holdResults.map({ (noteModel) -> Note in
                var shared = noteModel.isInSharedDB
                if shared == false,
                    let shareRecordName = noteModel.shareRecordName,
                    let shareModel = realm.object(ofType: RealmCKShare.self, forPrimaryKey: shareRecordName),
                    let share = CKShare.unarchieve(from: shareModel.shareData) as? CKShare {
                    shared = share.participants.count > 1
                }
                
                let content = noteModel.content.prefix(50)
                let str = String(content)
                let dateStr = DateFormatter.formatter.string(from: noteModel.isModified)
                return Note(type: NoteViewController.NoteType.open(NoteViewController.NoteInfo(id: noteModel.id, isShared: shared)),content: str, footnote: dateStr, sectionTitle: "고정된 메모", sectionIdentifier: NotePeriodReusableView.identifier)
            })
            dataSource.append(holdNotes)
            
            let normalResults = objects.filter("isPinned = false AND isInTrash = false").sorted(byKeyPath: "isModified", ascending: false)
            let normalNotes: [Note] = normalResults.map({ (noteModel) -> Note in
                var shared = noteModel.isInSharedDB
                if shared == false,
                    let shareRecordName = noteModel.shareRecordName,
                    let shareModel = realm.object(ofType: RealmCKShare.self, forPrimaryKey: shareRecordName),
                    let share = CKShare.unarchieve(from: shareModel.shareData) as? CKShare {
                    shared = share.participants.count > 1
                }
                
                let title = noteModel.content.prefix(50)
                let str = String(title)
                let dateStr = DateFormatter.formatter.string(from: noteModel.isModified)
                return Note(type: NoteViewController.NoteType.open(NoteViewController.NoteInfo(id: noteModel.id, isShared: shared)), content: str, footnote: dateStr, sectionTitle: "오늘", sectionIdentifier: NotePeriodReusableView.identifier)
            })
            
            dataSource.append(normalNotes)
            
        case .custom(let categoryStr):
            //section 0: 새 메모 작성
            //TODO: description에 대한 모델 대입하기
            let noteCreate: [CollectionDatable] = [NoteCreate(type: .create, title: "새 메모 작성", description: "누구에게 투표했나요? 피아노한테만 알려주세요!")]
            
            dataSource.append(noteCreate)
            
            
        case .deleted:
            ()
        case .locked:
            //section 0: 새 메모 작성
            //TODO: description에 대한 모델 대입하기
            let noteCreate: [CollectionDatable] = [NoteCreate(type: .create, title: "새 메모 작성", description: "누구에게 투표했나요? 피아노한테만 알려주세요!")]
            dataSource.append(noteCreate)
        }
        
        //section 1: 예정(구독하고, 캘린더 데이터가 있을 경우에만 보여줌)
//        //TODO: 구독 체크
//        if tempSubscription && tempCalendar {
//            let noteCalendar: [CollectionDatable] = [NoteCalendar(title: "로즈데이", startDate: Date(), endDate: Date(), sectionTitle: "예정")]
//            dataSource.append(noteCalendar)
//        } else {
//            dataSource.append([])
//        }

        //section 2: 고정된 메모
        //TODO: 해당 카테고리 이면서 hold된 메모들 fetch하여 나타내기

        
        //section 3: 일반 메모들
        //TODO: 여기에 realm Note모델 50~100개 limit으로 해서 넣기
        //방식: 오늘날짜, 어제날짜, 그제 ~ 일주일 전 날짜, 한달전(1월까지), 년도수
        
        return dataSource
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        updateCollectionViewInset()

    }
    
    private func setupNavigationBar() {
        //TODO: 네비게이션 바 세팅
        navigationItem.title = type.string
        navigationItem.setRightBarButtonItems(type.rightBarItems(self), animated: true)
    }
    
    private func updateCollectionViewInset() {
        collectionView.contentInset = UIEdgeInsetsMake(0, collectionView.marginLeft, 0, collectionView.marginRight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { [weak self] (context) in
            guard let strongSelf = self else { return }
            strongSelf.updateCollectionViewInset()
            strongSelf.collectionView.performBatchUpdates({
                strongSelf.collectionView
                    .setCollectionViewLayout(
                        strongSelf.collectionView.collectionViewLayout,
                        animated: true)
            }, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? NoteViewController, let type = sender as? NoteViewController.NoteType {
            destinationVC.type = type
        }
    }

}

extension NoteListViewController {
    
    enum CategoryType {
        case all
        case custom(String)
        case deleted
        case locked
        
        var string: String {
            switch self {
            case .all:
                return "모든 메모"
            case .custom(let string):
                return string
            case .deleted:
                return "삭제된 메모"
            case .locked:
                return "잠긴 메모"
            }
        }
    
        var rightBarItems: ((UIViewController) -> [UIBarButtonItem]) {
            return {vc in
                switch self {
                case .all, .custom:
                    let item1 = UIBarButtonItem(image: #imageLiteral(resourceName: "attachment"), style: .plain, target: vc, action: #selector(NoteListViewController.tapAttachment))
                    item1.tintColor = .black
                    let item2 = UIBarButtonItem(barButtonSystemItem: .search, target: vc, action: #selector(NoteListViewController.tapSearch))
                    item2.tintColor = .black
                    return [item1, item2]
                case .deleted, .locked:
                    let item1 = UIBarButtonItem(barButtonSystemItem: .edit, target: vc, action: #selector(NoteListViewController.tapEdit))
                    return [item1]
                }
            }
        }
        
        var leftBarItem: UIBarButtonItem? {
            return UIBarButtonItem(title: "전체선택", style: .plain, target: self, action: #selector(NoteListViewController.tapSelectAll))
        }
    }
}

//MARK: NavigationController
extension NoteListViewController {
    
    @objc func tapAttachment() {
        performSegue(withIdentifier: AttachmentViewController.identifier, sender: nil)
    }
    
    @objc func tapEdit() {
        guard let type = self.type else { return }
        switch type {
        case .deleted:
            ()
        case .locked:
            ()
        default:
            ()
        }
    }
    
    @objc func tapSelectAll() {
        guard let type = self.type else { return }
        switch type {
        case .deleted:
            ()
        case .locked:
            ()
        default:
            ()
        }
    }
    
    @objc func tapSearch() {
        performSegue(withIdentifier: SearchViewController.identifier, sender: nil)
    }
}
