//
//  TransParentNavigationController.swift
//  GroupingTableView
//
//  Created by Kevin Kim on 15/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

class TransParentNavigationController: UINavigationController {
    
    let navColor = UIColor.white.withAlphaComponent(0.97)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.backgroundColor = navColor
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        setStatusBarView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) {[weak self] (_) in
            self?.setStatusBarView()
        }
    }
    
    private func setStatusBarView() {
        
        if UIApplication.shared.statusBarFrame.height != 0 {
            let statusBarView = view.createSubviewIfNeeded(identifier: StatusBarView.identifier)
            statusBarView.backgroundColor = navColor
            statusBarView.frame = UIApplication.shared.statusBarFrame
            view.addSubview(statusBarView)
        } else {
            view.subView(identifier: StatusBarView.identifier)?.removeFromSuperview()
        }
        
    }

    

}

//extension ViewTag {
//    static let StatusBarView = "StatusBarView"
//}
