//
//  AlbumCardController.swift
//  Piano
//
//  Created by JangDoRi on 2018. 6. 4..
//  Copyright © 2018년 Piano. All rights reserved.
//

import UIKit
import RealmSwift
import CloudKit
import Photos

/// 최소한의 화질을 보장받을 수 있는 image size 값.
let PHImageManagerMinimumSize: CGFloat = 125

protocol AlbumDelegates: NSObjectProtocol {
    /**
     Photo 선택에 대한 처리를 진행한다.
     - parameter indexPath : 선택한 photo의 indexPath.
     */
    func select(photo indexPath: IndexPath)
    /**
     Folder 선택에 대한 처리를 진행한다.
     - parameter indexPath : 선택한 folder의 indexPath.
     */
    func select(folder indexPath: IndexPath)
}

class AlbumCardController: UIViewController {
    
    @IBOutlet private var safeView: UIView!
    
    @IBOutlet private var photoListView: AlbumPhotoListView!
    @IBOutlet private var folderListView: AlbumFolderListView!
    
    var albumDismissed: ((String, Bool) -> ())?
    var isGrouped = false
    var noteID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoListView.delegates = self
        folderListView.delegates = self
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
        updateTitle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(action(folder:)), for: .touchUpInside)
        navigationItem.titleView = button
        updateTitle()
        
        navigationController?.isToolbarHidden = false
        navigationController?.toolbarItems = toolbarItems
        guard let toolbarItems = navigationController?.toolbarItems else {return}
        toolbarItems[0].image = #imageLiteral(resourceName: "plus")
        toolbarItems[0].tintColor = .gray
        toolbarItems[1].title = "묶어보내기"
    }()
    
    private func initConst() {
        photoListView.anchor {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        folderListView.anchor {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.width.equalTo(safeView.widthAnchor)
            $0.height.equalTo(safeView.heightAnchor)
            $0.bottom.equalTo(safeView.topAnchor)
        }
    }
    
    @IBAction private func action(close: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func action(folder: UIButton) {
        guard let titleView = navigationItem.titleView as? UIButton else {return}
        titleView.isSelected = !folder.isSelected
        let offset = titleView.isSelected ? 0 : -safeView.bounds.height
        if titleView.isSelected {folderListView.isHidden = false}
        UIView.animate(withDuration: 0.3, animations: {
            self.folderListView.frame.origin.y = offset
        }, completion: { _ in
            if !titleView.isSelected {self.folderListView.isHidden = true}
        })
        updateTitle()
    }
    
    @IBAction private func action(done: UIButton) {
        model()
    }
    
    @IBAction private func action(group: UIButton) {
        guard let toolbarItems = navigationController?.toolbarItems else {return}
        toolbarItems[0].tintColor = (toolbarItems[0].tintColor == .gray) ? .blue : .gray
        isGrouped = (toolbarItems[0].tintColor == .blue)
    }
    
    /// 현재 display 되고 있는 folder에 따라 title을 갱신한다.
    private func updateTitle() {
        guard let titleView = navigationItem.titleView as? UIButton else {return}
        let str = photoListView.albumTitle + (titleView.isSelected ? " ▲" : " ▼")
        let attStr = NSMutableAttributedString(string: str)
        attStr.addAttributes([NSAttributedStringKey.font :
            UIFont.systemFont(ofSize: titleView.titleLabel!.font.pointSize / 2),
                              NSAttributedStringKey.baselineOffset : 2.5],
                             range: NSMakeRange(attStr.length - 1, 1))
        titleView.setAttributedTitle(attStr, for: .normal)
        titleView.sizeToFit()
    }
    
    private func model(with image: UIImage? = nil) {
        guard let realm = try? Realm(),
            let noteModel = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
        
        let coder = NSKeyedUnarchiver(forReadingWith: noteModel.ckMetaData)
        coder.requiresSecureCoding = true
        guard let record = CKRecord(coder: coder) else {fatalError("Data poluted!!")}
        coder.finishDecoding()
        
        if let image = image {
            let model = RealmImageModel.getNewModel(sharedZoneID: record.recordID.zoneID,
                                                    noteRecordName: record.recordID.recordName, image: image)
            ModelManager.saveNew(model: model)
            dismiss(animated: true) {
                self.albumDismissed?(model.id, false)
            }
        } else {
            var ids: [String] = []
            photoListView.selectedIndex.forEach {
                let model = RealmImageModel.getNewModel(sharedZoneID: record.recordID.zoneID,
                                                        noteRecordName: record.recordID.recordName)
                ids.append(model.id)
                ModelManager.saveNew(model: model)
                
                let options = PHImageRequestOptions()
                options.isSynchronous = false
                photoListView.imageManager.requestImage(for: photoListView.photoAssets[$0.row - 1],
                                                        targetSize: PHImageManagerMaximumSize,
                                                        contentMode: .aspectFit,
                                                        options: options) { image, _ in
                                                            guard let wrappedImage = image,
                                                                let imageData = UIImageJPEGRepresentation(wrappedImage, 1.0) else {return}
                                                            ModelManager.update(id: model.id, type: RealmImageModel.self,
                                                                                kv: [Schema.Image.image: imageData])
                }
            }
            
            if isGrouped {
                let newImageListModel = RealmImageListModel.getNewModel(sharedZoneID: record.recordID.zoneID,
                                                                        noteRecordName: noteModel.recordName,
                                                                        imageIDs: ids)
                ModelManager.saveNew(model: newImageListModel)
                dismiss(animated: true) {
                    self.albumDismissed?(newImageListModel.id, true)
                }
            } else {
                dismiss(animated: true) {
                    self.albumDismissed?(ids.joined(separator: "|"), false)
                }
            }
        }
    }
    
    deinit {
        #if DEBUG
        print("deinit :", self)
        #endif
    }
    
}

extension AlbumCardController: AlbumDelegates {
    
    func select(photo indexPath: IndexPath) {
        if indexPath.row == 0 {
            LocalAuth.share.request(camera: {
                let cameraViewCtrl = viewCtrl(type: CameraViewController.self)
                cameraViewCtrl.cameraDismissed = { [weak self] in
                    guard let image = $0 else {return}
                    self?.model(with: image)
                }
                self.present(cameraViewCtrl, animated: true)
            })
        } else {
            photoListView.reload(selected: indexPath)
            navigationItem.rightBarButtonItem?.isEnabled = !photoListView.selectedIndex.isEmpty
            guard let toolbarItems = navigationController?.toolbarItems else {return}
            toolbarItems[0].isEnabled = (photoListView.selectedIndex.count > 1)
            toolbarItems[1].isEnabled = (photoListView.selectedIndex.count > 1)
        }
    }
    
    func select(folder indexPath: IndexPath) {
        guard let titleView = navigationItem.titleView as? UIButton else {return}
        photoListView.requestPhoto(from: folderListView.albumAssets[indexPath.row])
        action(folder: titleView)
        updateTitle()
    }
    
}

