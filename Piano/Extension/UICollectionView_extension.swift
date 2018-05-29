//
//  UICollectionView_extension.swift
//  Piano
//
//  Created by Kevin Kim on 28/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    var marginLeft: CGFloat {
        guard let superview = superview else { return 0 }
        let safeAreaWidth = superview.bounds.width - (superview.safeAreaInsets.left + superview.safeAreaInsets.right)
        if safeAreaWidth < 768 {
            return 16 + superview.safeAreaInsets.left
        } else if safeAreaWidth < 1024 {
            return 34 + superview.safeAreaInsets.left
        } else {
            return 51 + superview.safeAreaInsets.left
        }
    }
    
    var marginRight: CGFloat {
        guard let superview = superview else { return 0 }
        let safeAreaWidth = superview.bounds.width - (superview.safeAreaInsets.left + superview.safeAreaInsets.right)
        if safeAreaWidth < 768 {
            return 16 + superview.safeAreaInsets.right
        } else if safeAreaWidth < 1024 {
            return 34 + superview.safeAreaInsets.right
        } else {
            return 51 + superview.safeAreaInsets.right
        }
    }
}
