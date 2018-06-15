//
//  DrawingMapController.swift
//  Piano
//
//  Created by JangDoRi on 2018. 6. 4..
//  Copyright © 2018년 Piano. All rights reserved.
//

import UIKit
import RealmSwift
import CloudKit

/// 그림판 ViewCtrl.
class DrawingMapController: UIViewController {
    
    @IBOutlet private var safeView: UIView!
    @IBOutlet private var canvasView: CanvasView!
    @IBOutlet private var menuView: UIView!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var undoButton: UIButton!
    @IBOutlet private var redoButton: UIButton!
    @IBOutlet private var clearButton: UIButton!
    
    var drawDismissed: ((String) -> ())?
    var noteID = ""
    var modelID = ""
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initConst()
        device(orientationDidChange: { [weak self] _ in
            self?.initConst()
            self?.canvasOrientation()
        })
    }
    
    private func initView() {
        view.backgroundColor = UIColor(hex6: "e5e5e5")
        menuView.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        clearButton.setTitleColor(UIColor(hex6: "9d9d9d"), for: .normal)
        clearButton.setTitle("Clear", for: .normal)
        canvasView.canvas.image = image
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        canvasView.frame.size = safeView.bounds.size
    }()
    
    private func initConst() {
        menuView.anchor {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.height.equalTo(minSize * 0.08)
        }
        closeButton.anchor {
            $0.leading.equalTo(minSize * 0.0266)
            $0.top.equalTo(0)
            $0.width.equalTo(menuView.heightAnchor)
            $0.height.equalTo(menuView.heightAnchor)
        }
        undoButton.anchor {
            $0.leading.equalTo(closeButton.trailingAnchor).offset(minSize * 0.0266)
            $0.top.equalTo(0)
            $0.width.equalTo(menuView.heightAnchor)
            $0.height.equalTo(menuView.heightAnchor)
        }
        redoButton.anchor {
            $0.leading.equalTo(undoButton.trailingAnchor).offset(minSize * 0.0266)
            $0.top.equalTo(0)
            $0.width.equalTo(menuView.heightAnchor)
            $0.height.equalTo(menuView.heightAnchor)
        }
        clearButton.anchor {
            $0.leading.equalTo(redoButton.trailingAnchor).offset(minSize * 0.0266)
            $0.top.equalTo(0)
            $0.width.greaterThanOrEqualTo(0)
            $0.height.equalTo(menuView.heightAnchor)
        }
    }
    
    /// 현재 orientation 맞추어 canvasView를 scaleAspectFit 처리한다.
    private func canvasOrientation() {
        let oldValue = max(canvasView.bounds.width, canvasView.bounds.height)
        if canvasView.bounds.width < canvasView.bounds.height {
            let scale = safeView.bounds.height / canvasView.bounds.height
            let width = canvasView.bounds.width * scale
            let height = canvasView.bounds.height * scale
            let x = safeView.bounds.width / 2 - width / 2
            canvasView.frame = CGRect(x: x, y: 0, width: width, height: height)
        } else {
            let scale = safeView.bounds.width / canvasView.bounds.width
            let width = canvasView.bounds.width * scale
            let height = canvasView.bounds.height * scale
            var y =  safeView.bounds.height / 2 - height / 2
            if UIApplication.shared.statusBarOrientation.isLandscape {y = 0}
            canvasView.frame = CGRect(x: 0, y: y, width: width, height: height)
        }
        let newValue = max(canvasView.bounds.width, canvasView.bounds.height)
        if oldValue != newValue {canvasView.drawingPen.scale = newValue / oldValue}
    }
    
    @IBAction private func action(close: UIButton) {
        if let image = canvasView.canvas.image {
            guard let realm = try? Realm()else {return}
            
            if let imageModel = realm.object(ofType: RealmImageModel.self, forPrimaryKey: modelID),
                !imageModel.isPhoto {
                let imageData = UIImageJPEGRepresentation(image, 1) ?? Data()
                ModelManager.update(id: modelID, type: RealmImageModel.self, kv: [Schema.Image.image : imageData])
                dismiss(animated: true) {
                    self.drawDismissed?(self.modelID)
                }
            } else {
                guard let noteModel = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
                
                let coder = NSKeyedUnarchiver(forReadingWith: noteModel.ckMetaData)
                coder.requiresSecureCoding = true
                guard let record = CKRecord(coder: coder) else {fatalError("Data poluted!!")}
                coder.finishDecoding()
                
                let model = RealmImageModel.getNewModel(sharedZoneID: record.recordID.zoneID, noteRecordName: record.recordID.recordName, image: image)
                model.isPhoto = false
                ModelManager.saveNew(model: model)
                
                dismiss(animated: true) {
                    self.drawDismissed?(model.id)
                }
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction private func action(undo: UIButton) {
        if self.canvasView.drawingManager.canUndo {
            self.canvasView.drawingManager.undo()
            self.canvasView.canvas.image = self.canvasView.drawingManager.lastImage
        }
    }
    
    @IBAction private func action(redo: UIButton) {
        if self.canvasView.drawingManager.canRedo {
            self.canvasView.drawingManager.redo()
            self.canvasView.canvas.image = self.canvasView.drawingManager.lastImage
        }
    }
    
    @IBAction private func action(clear: UIButton) {
        if self.canvasView.drawingManager.canClear {
            self.canvasView.drawingManager.clear()
            self.canvasView.canvas.image = self.canvasView.drawingManager.lastImage
        }
    }
    
    deinit {
        #if DEBUG
        print("deinit :", self)
        #endif
    }
    
}

