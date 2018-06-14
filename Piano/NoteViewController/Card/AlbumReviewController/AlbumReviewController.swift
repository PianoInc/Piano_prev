//
//  AlbumReviewController.swift
//  Piano
//
//  Created by JangDoRi on 2018. 6. 14..
//  Copyright © 2018년 Piano. All rights reserved.
//

import UIKit
import Photos

class AlbumReviewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let navigationCtrl = navigationController else {return}
        navigationCtrl.navigationBar.shadowImage = UIImage()
        navigationCtrl.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationCtrl.navigationBar.backgroundColor = UIColor(hex6: "151515")
        
        navigationCtrl.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        navigationCtrl.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        navigationCtrl.toolbar.backgroundColor = UIColor(hex6: "151515")
        navigationCtrl.isToolbarHidden = false
        
        imageView.image = image
    }
    
    @IBAction private func action(close: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction private func action(save: UIBarButtonItem) {
        guard let image = image else {return}
        try? PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
    
    @IBAction private func action(share: UIBarButtonItem) {
        guard let image = image else {return}
        let imageData = UIImageJPEGRepresentation(image, 1.0)!
        let writePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("instagram.ig")
        do {
            try imageData.write(to: writePath)
            let documentsInteractionsController = UIDocumentInteractionController(url: writePath)
            documentsInteractionsController.uti = "com.instagram.photo"
            documentsInteractionsController.presentOpenInMenu(from: .zero, in: view, animated: true)
        }catch {
            return
        }
    }
    
}