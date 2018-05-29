//
//  AppNavigator.swift
//  Piano
//
//  Created by Kevin Kim on 29/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

class AppNavigator {
    static var currentViewController: UIViewController? {
        let window = UIApplication.shared.keyWindow
        
        if let navigationController = window?.rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        } else {
            return window?.rootViewController
        }
    }
    
    static var currentNavigationController: UINavigationController? {
        let window = UIApplication.shared.keyWindow
        
        return window?.rootViewController as? UINavigationController
    }
    
    class func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        currentViewController?.present(viewController, animated: animated, completion: completion)
    }
}
