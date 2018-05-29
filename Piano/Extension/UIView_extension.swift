//
//  UIView_Extension.swift
//  GroupingTableView
//
//  Created by Kevin Kim on 15/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

extension UIView {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
