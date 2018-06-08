//
//  UIView_Extension.swift
//  PianoNote
//
//  Created by Kevin Kim on 10/05/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation
import CoreGraphics
import Anchor

extension View {
    
    /**
     해당 type의 view가 subView에 속하고 있는지의 여부를 반환한다.
     - parameter type: 확인하려는 view의 type.
     */
    internal func hasSubView<T: View>(_ type: T.Type) -> Bool {
        return (viewWithTag(String(describing: type).hashValue) != nil)
    }
    
    /**
     SubViews에서 해당 type의 view를 반환한다.
     - parameter type: 가져오려는 view의 type.
     */
    internal func subView<T: View>(_ type: T.Type) -> T? {
        return viewWithTag(String(describing: type).hashValue) as? T
    }
    
    /**
     SubViews에서 해당 type의 view를 반환하되, 존재하지 않을시엔 생생하여 반환한다.
     - parameter type: 가져오려는 View의 type.
     */
    internal func createSubviewIfNeeded<T: View>(_ type: T.Type) -> T? {
        let type = String(describing: type)
        
        if let view = self.viewWithTag(type.hashValue) as? T {
            return view
        }
        
        let nib = Nib(nibName: type, bundle: nil)
        if let view = nib.instantiate(withOwner: nil, options: nil).first as? T {
            view.tag = type.hashValue
            return view
        }
        
        return nil
    }
    
}

/**
 View 생성 helper.
 - parameter view : 생성하고자 하는 view.
 - parameter attr : View에 대한 attribute 선언부.
 - returns : Attribute가 설정된 view.
 */
func view<T>(_ view: T, _ attr: ((T) -> ())) -> T {
    attr(view)
    return view
}
