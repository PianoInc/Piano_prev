//
//  CameraViewController.swift
//  Piano
//
//  Created by JangDoRi on 2018. 6. 5..
//  Copyright © 2018년 Piano. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet private var safeView: UIView!
    private var cameraView: CameraView!
    
    var cameraDismissed: ((UIImage?) -> ())?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        cameraView = CameraView(frame: safeView.bounds)
        safeView.addSubview(cameraView)
        cameraView.cameraShoted = { [weak self] image in
            self?.dismiss(animated: false, completion: {
                self?.cameraDismissed?(image)
            })
        }
    }()
    
    deinit {
        #if DEBUG
        print("deinit :", self)
        #endif
    }
    
}

