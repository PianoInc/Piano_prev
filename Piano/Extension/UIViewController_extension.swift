//
//  UIViewController_extension.swift
//  Piano
//
//  Created by Kevin Kim on 26/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import Foundation
import UIKit

extension ViewController {
    static var identifier: String {
        return String(describing: self)
    }
}

/**
 주어진 generic type과 동일한 id를 가지는 viewController를 반환한다.
 - parameter type : ViewController type.
 - returns : 일치하는 viewController.
 */
func viewCtrl<T>(type: T.Type) -> T {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: String(describing: type)) as! T
}
