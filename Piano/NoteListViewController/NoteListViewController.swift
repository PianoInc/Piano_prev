//
//  NoteListViewController.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

class NoteListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var type: CategoryType!
    //temp
    var tempSubscription = true
    var tempCalendar = true
    var tempHold = true
    
    lazy var dataSource: [[CollectionDatable]] = {
        
        //TODO: type을 바라보며 데이터 소스 세팅하기
        
        guard let type = self.type else { return []}
        switch type {
        case .all:
            ()
        case .custom(let categoryStr):
            ()
        case .deleted:
            ()
        case .locked:
            ()
        }
        
        var dataSource: [[CollectionDatable]] = []
        
        //section 0: 새 메모 작성
        //TODO: description에 대한 모델 대입하기
        let noteCreate: [CollectionDatable] = [NoteCreate(type: .create(NoteViewController.NoteInfo(id: "newID", isShared: false)), title: "새 메모 작성", description: "누구에게 투표했나요? 피아노한테만 알려주세요!")]
        
        dataSource.append(noteCreate)
        
        //section 1: 예정(구독하고, 캘린더 데이터가 있을 경우에만 보여줌)
        //TODO: 구독 체크
        if tempSubscription && tempCalendar {
            let noteCalendar: [CollectionDatable] = [NoteCalendar(title: "로즈데이", startDate: Date(), endDate: Date(), sectionTitle: "예정")]
            dataSource.append(noteCalendar)
        } else {
            dataSource.append([])
        }

        //section 2: 고정된 메모
        //TODO: 해당 카테고리 이면서 hold된 메모들 fetch하여 나타내기
        if tempHold {
            let holdNotes: [Note] = [
                
                Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "일기", subTitle: "오늘의 일기는 매우매우 슬픈 내용이다", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "고정된 메모", sectionIdentifier: NotePeriodReusableView.identifier),
                Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: false)), title: "피아노 일정", subTitle: "출시까지 앞으로 2주", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "고정된 메모", sectionIdentifier: NotePeriodReusableView.identifier)]
            dataSource.append(holdNotes)
        } else {
            dataSource.append([])
        }
        
        
        //section 3: 일반 메모들
        //TODO: 여기에 realm Note모델 50~100개 limit으로 해서 넣기
        //방식: 오늘날짜, 어제날짜, 그제 ~ 일주일 전 날짜, 한달전(1월까지), 년도수
        
        let todayNotes: [Note] = [
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "오늘", subTitle: "오늘의 일기", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "오늘", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "일정3232", subTitle: "출시까지 앞으로 2주3232", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "오늘", sectionIdentifier: NotePeriodReusableView.identifier)]
        dataSource.append(todayNotes)
        
        let yesterdayNotes: [Note] = [
            Note(type: .trash(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "어제자 일기", subTitle: "배가 너무 너무 고프다", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "피아노 업데이트 계획", subTitle: "어마어마 하다 정말", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "어제자 일기", subTitle: "배가 너무 너무 고프다", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "피아노 업데이트 계획", subTitle: "어마어마 하다 정말", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "어제자 일기", subTitle: "배가 너무 너무 고프다", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "피아노 업데이트 계획", subTitle: "어마어마 하다 정말", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "어제자 일기", subTitle: "배가 너무 너무 고프다", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "피아노 업데이트 계획", subTitle: "어마어마 하다 정말", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "어제자 일기", subTitle: "배가 너무 너무 고프다", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "피아노 업데이트 계획", subTitle: "어마어마 하다 정말", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "어제자 일기", subTitle: "배가 너무 너무 고프다", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier),
            Note(type: .open(NoteViewController.NoteInfo(id: "id", isShared: true)), title: "피아노 업데이트 계획", subTitle: "어마어마 하다 정말", footnote: DateFormatter.formatter.string(from: Date()), sectionTitle: "어제", sectionIdentifier: NotePeriodReusableView.identifier)]
        
        dataSource.append(yesterdayNotes)
        
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
        navigationItem.setRightBarButtonItems(type.rightBarItems, animated: true)
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
        
        var rightBarItems: [UIBarButtonItem] {
            switch self {
            case .all, .custom:
                let item1 = UIBarButtonItem(image: #imageLiteral(resourceName: "attachment"), style: .plain, target: self, action: #selector(NoteListViewController.tapAttachment))
                item1.tintColor = .black
                let item2 = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(NoteListViewController.tapSearch))
                item2.tintColor = .black
                return [item1, item2]
            case .deleted, .locked:
                let item1 = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(NoteListViewController.tapEdit))
                return [item1]
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
        performSegue(withIdentifier: NoteListViewController.identifier, sender: nil)
    }
}
