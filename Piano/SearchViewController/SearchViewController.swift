//
//  SearchViewController.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let disposeBag = DisposeBag()
    var noteFilteredResults: Results<RealmNoteModel>?
    var notificationToken: NotificationToken?
    var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setObserver()
        subscribeToSearchBar()
    }

    private func setObserver() {
        notificationToken?.invalidate()
        
        notificationToken = noteFilteredResults?.observe { [weak self] change in
            guard let collectionView = self?.collectionView else {return}
            switch change {
            case .initial(_): collectionView.reloadData()
            case .update(_, _, _, _):
                collectionView.reloadSections(IndexSet(integer: 0))
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        }
        
    }
    
    private func subscribeToSearchBar() {
        searchBar.rx.text.asObservable().map{$0 ?? ""}
            .filter{ !$0.isEmpty }
            .debounce(1.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (searchText) in
                self?.update(with: searchText)
            }).disposed(by: disposeBag)
        
        searchBar.rx.text.asObservable().map{ ($0 ?? "").isEmpty }
            .bind(to: collectionView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    func update(with searchText: String) {
        self.searchText = searchText
        guard let realm = try? Realm() else { fatalError() }
        
        noteFilteredResults = realm.objects(RealmNoteModel.self)
            .filter("isInTrash = false AND content CONTAINS[cd] %@", searchText)
        
        setObserver()
    }
    
    @IBAction func cancelButtonTouched(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

//TODO: Note structure 활용해서 collectionview 만들기
