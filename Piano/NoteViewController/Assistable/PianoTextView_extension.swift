//
//  PianoTextView_Assistable.swift
//  AssistView
//
//  Created by Kevin Kim on 10/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import Foundation

extension PianoTextView {
    
//    @objc func escape(sender: KeyCommand) {
//        hideAutoCompleteTableViewIfNeeded()
//    }
    
    @objc func upArrow(sender: KeyCommand) {
        
        guard let collectionView = subView(identifier: AutoCompleteCollectionView.identifier) as? AutoCompleteCollectionView,
            let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        
        let numberOfRows = collectionView.numberOfItems(inSection: 0)
        
        let newIndexPath: IndexPath
        if selectedIndexPath.item == 0 {
            newIndexPath = IndexPath(row: numberOfRows - 1, section: 0)
        } else {
            newIndexPath = IndexPath(row: selectedIndexPath.item - 1, section: 0)
        }
        
        collectionView.selectItem(at: newIndexPath, animated: false, scrollPosition: .top)
        
    }
    
    @objc func downArrow(sender: KeyCommand) {
        
        guard let collectionView = subView(identifier: AutoCompleteCollectionView.identifier) as? AutoCompleteCollectionView,
            let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        
        let numberOfRows = collectionView.numberOfItems(inSection: 0)
        
        let newIndexPath: IndexPath
        if selectedIndexPath.item + 1 == numberOfRows {
            newIndexPath = IndexPath(row: 0, section: 0)
        } else {
            newIndexPath = IndexPath(row: selectedIndexPath.item + 1, section: 0)
        }
        
        collectionView.selectItem(at: newIndexPath, animated: false, scrollPosition: .top)
        
    }
}
