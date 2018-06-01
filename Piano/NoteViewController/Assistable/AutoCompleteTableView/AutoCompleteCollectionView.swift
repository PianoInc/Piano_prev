//
//  AutoCompleteCollectionView.swift
//  Piano
//
//  Created by Kevin Kim on 2018. 6. 1..
//  Copyright © 2018년 Piano. All rights reserved.
//

import UIKit

class AutoCompleteCollectionView: UICollectionView {

    let width: CGFloat = 150
    let margin: CGFloat = 10
    let cellHeight: CGFloat = 40
    let minimumHeight: CGFloat = 130
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        layer.shadowColor = Color.black.cgColor
//        layer.shadowOpacity = 0.2
//        layer.shadowOffset = CGSize(width: 0, height: 1)
//        layer.shadowRadius = 5
//        layer.cornerRadius = 10
//        layer.masksToBounds = false
        
    }
    
    internal func setPosition(textView: UITextView, at caretRect: CGRect) {
        
        //가로 좌표 결정
        if textView.frame.width - caretRect.origin.x <= width {
            self.frame.origin.x = textView.frame.width - (width + margin)
        } else {
            self.frame.origin.x = caretRect.origin.x
        }
        
        //세로 좌표 + 높이 결정
        let heightBelowCaret = textView.frame.height - (textView.contentInset.bottom + caretRect.origin.y - textView.contentOffset.y + caretRect.height)
        
        if heightBelowCaret > minimumHeight {
            
            self.frame.origin.y = caretRect.origin.y + caretRect.height
            self.frame.size.height = min(cellHeight * CGFloat(numberOfItems(inSection: 0)), heightBelowCaret)
            
        } else {
            
            self.frame.size.height = min(cellHeight * CGFloat(numberOfItems(inSection: 0)), caretRect.origin.y - textView.contentOffset.y)
            self.frame.origin.y = caretRect.origin.y - self.frame.size.height
            
        }
        
        self.frame.size.width = width
        
    }
}
