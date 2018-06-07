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
        var dataSource: [[CollectionDatable]] = []
        guard let type = self.type else { return dataSource }
        
        switch type {
        case .all:
            
            //section 0: 새 메모 작성
            //TODO: description에 대한 모델 대입하기
            let noteCreate = [NoteCreate(type: .create(""), title: "새 메모 작성", description: "누구에게 투표했나요? 피아노한테만 알려주세요!")]
            dataSource.append(noteCreate)
            
            let realm = try! Realm()
            
            //section 1: 캘린더 정보 (구독하고, 캘린더 데이터가 있을 경우에만 보여줌)
            //TODO: 지오한테 물어봐서 개발하기
            //        if tempSubscription && tempCalendar {
            //            let noteCalendar: [CollectionDatable] = [NoteCalendar(title: "로즈데이", startDate: Date(), endDate: Date(), sectionTitle: "예정")]
            //            dataSource.append(noteCalendar)
            //        } else {
            //            dataSource.append([])
            //        }
            
            //1단계: all인 경우, 휴지통에 있거나, 잠금에 있는 것들을 제외한 모든 것들을 우선 fetch하고 카운트를 기록한다.
            let allPredicate = NSPredicate(format: "isLocked == false AND isInTrash == false")
            let allResults = realm.objects(RealmNoteModel.self).filter(allPredicate)
            
            let allCount = allResults.count
            var fetchedCount = 0
            
            //section 2: 고정 메모
            //고정 메모의 경우, 1단계로 필터한 것에서 다시 필터를 돌려 isPinned = true인 것들을 찾아낸다.
            let holdPredicate = NSPredicate(format: "isPinned == true")
            let holdResults = allResults.filter(holdPredicate).sorted(byKeyPath: "isModified", ascending: false)
            fetchedCount += holdResults.count
            if fetchedCount == allCount { return dataSource }
            
            // 뷰모델로 변환
            //TODO: shared 방법 Zio에게 물어봐서 적용시키기
            let holdNotes: [Note] = holdResults.map { (noteModel) -> Note in
                let content = String(noteModel.content.prefix(30))
                let dateStr = DateFormatter.formatter.string(from: noteModel.isModified)
                return Note(noteType: .open(NoteViewController.NoteInfo(id: noteModel.id, isShared: false, isPinned: true)),content: content, footnote: dateStr, sectionTitle: "고정된 메모", sectionIdentifier: NotePeriodReusableView.identifier)
            }
            dataSource.append(holdNotes)
            
            //TODO: struct만들어서 오늘 날짜를 받으면, 오늘, 어제, .... 순으로 predicate,sectionTitle를 리턴하도록 만들기
            //i에 따라서 섹션 타이틀
            
            //오늘, 어제, 이전 7일, 이전 30일, 월별, 년도별
            
            //section 3: 오늘 날짜
            var calendar = Calendar.current
            calendar.timeZone = NSTimeZone.local
            
            let date = Date(timeIntervalSinceNow: -60 * 60 * 24 * 0)
            let dateFrom = calendar.startOfDay(for: date)
            
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dateFrom)
            components.day! += 1
            let dateTo = calendar.date(from: components)!
            
            let todayPredicate = NSPredicate(format: "(%@ <= isModified) AND (isModified < %@) AND isPinned == false",
                                             argumentArray: [dateFrom, dateTo])
            let todayResults = allResults.filter(todayPredicate).sorted(byKeyPath: "isModified", ascending: false)
            fetchedCount += todayResults.count
            if fetchedCount == allCount { return dataSource }
            
            // 뷰모델로 변환
            //TODO: shared 방법 Zio에게 물어봐서 적용시키기
            let todayNotes: [Note] = todayResults.map { (noteModel) -> Note in
                let content = String(noteModel.content.prefix(30))
                let dateStr = DateFormatter.formatter.string(from: noteModel.isModified)
                return Note(noteType: .open(NoteViewController.NoteInfo(id: noteModel.id, isShared: false, isPinned: false)),content: content, footnote: dateStr, sectionTitle: "오늘", sectionIdentifier: NotePeriodReusableView.identifier)
            }
            dataSource.append(holdNotes)
            
            
            //section 4: 어제 날짜
            
            
            
        case .custom(let categoryStr):
            //section 0: 새 메모 작성
            //TODO: description에 대한 모델 대입하기
            let noteCreate = [NoteCreate(type: .create(categoryStr), title: "새 메모 작성", description: "누구에게 투표했나요? 피아노한테만 알려주세요!")]
            dataSource.append(noteCreate)
            
            //section 1: 캘린더 정보 (구독하고, 캘린더 데이터가 있을 경우에만 보여줌)
            //TODO: 지오한테 물어봐서 개발하기
            //        if tempSubscription && tempCalendar {
            //            let noteCalendar: [CollectionDatable] = [NoteCalendar(title: "로즈데이", startDate: Date(), endDate: Date(), sectionTitle: "예정")]
            //            dataSource.append(noteCalendar)
            //        } else {
            //            dataSource.append([])
            //        }
            
            
            //section 2: 고정 메모
            //TODO: tag도 필터링해줘야함
            
            
        case .deleted:
            ()
        case .locked:
            //section 0: 새 메모 작성
            //TODO: description에 대한 모델 대입하기
            let noteCreate: [CollectionDatable] = [NoteCreate(type: .create(""), title: "새 메모 작성", description: "누구에게 투표했나요? 피아노한테만 알려주세요!")]
            dataSource.append(noteCreate)
        }

        
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
        navigationItem.title = type.title
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
            destinationVC.noteType = type
        }
    }

}

extension NoteListViewController {
    
    enum CategoryType {
        case all
        case custom(String)
        case deleted
        case locked
        
        var title: String {
            switch self {
            case .all:
                return NSLocalizedString("All Note", comment: "모든 메모")
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
