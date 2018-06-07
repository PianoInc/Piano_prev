//
//  ImagePickerViewController.swift
//  Piano
//
//  Created by Kevin Kim on 2018. 6. 2..
//  Copyright © 2018년 Piano. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import RealmSwift
import CloudKit

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class ImagePickerViewController: UIViewController {
    
    weak var noteViewController: NoteViewController?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var attachButton: UIBarButtonItem!
    
    private var allPhotos: PHFetchResult<PHAsset>?
    fileprivate var thumbnailSize: CGSize!
    fileprivate lazy var imageManager = PHCachingImageManager()
    fileprivate var previousPreheatRect = CGRect.zero
    private var isSelectedArray: [Bool] = []
    
    var noteID: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let allPhotosOptions = PHFetchOptions()
        let date = Date()
        allPhotosOptions.predicate = NSPredicate(format: "creationDate <= %@ && modificationDate <= %@", date as CVarArg, date as CVarArg)
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        isSelectedArray = [Bool](repeating: false, count: allPhotos!.count)
        
        PHPhotoLibrary.shared().register(self)
        
        updateItemSize()
        collectionView.reloadData()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateItemSize), name: Notification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    @IBAction func tapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
        //우선 선택된 이미지들을 가져오기
        
        guard let result = allPhotos else { return }
        isSelectedArray.filter{ $0 }.enumerated().forEach { [weak self] (offset, _) in
            let asset = result[offset]
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
            requestOptions.isSynchronous = false
            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (image, dic) in
                guard let unWrapImage = image,
                    let imageData = UIImageJPEGRepresentation(unWrapImage, 1.0) else { return }
                
                guard let range = self?.noteViewController?.textView?.selectedRange else { return }
                self?.noteViewController?.textView.insertImageCell(image: unWrapImage, at: range)
                
                
            })
        }
        
        
        
        
        //끄기
        dismiss(animated: true, completion: nil)

        
        
        //TODO: if count == 1, then make image card, not image list card.
//        guard let realm = try? Realm(),
//            let noteModel = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID),
//            let result = allPhotos else {return}
//
//        let coder = NSKeyedUnarchiver(forReadingWith: noteModel.ckMetaData)
//        coder.requiresSecureCoding = true
//        guard let record = CKRecord(coder: coder) else {fatalError("Data poluted!!")}
//        coder.finishDecoding()
//
//        var ids: [String] = []
//        isSelectedArray.filter{ $0 }.enumerated().forEach { offset, _ in
//            let asset = result[offset]
//            let newImageModel = RealmImageModel.getNewModel(sharedZoneID: record.recordID.zoneID, noteRecordName: record.recordID.recordName)
//            let newID = newImageModel.id
//            ids.append(newID)
//            ModelManager.saveNew(model: newImageModel)
//
//            let requestOptions = PHImageRequestOptions()
//
//            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
//            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
//            requestOptions.isSynchronous = false
//
//            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions) { (image, dic) in
//                guard let wrappedImage = image,
//                    let imageData = UIImageJPEGRepresentation(wrappedImage, 1.0) else { return }
//                ModelManager.update(id: newID, type: RealmImageModel.self, kv: [Schema.Image.image: imageData])
//            }
//        }
//
//        let newImageListModel = RealmImageListModel.getNewModel(sharedZoneID: record.recordID.zoneID, noteRecordName: noteModel.recordName, imageIDs: ids)
//        ModelManager.saveNew(model: newImageListModel)
//        //get id & make card
////        if !ids.isEmpty {
////            Util.share.imageID = ids[0]
////        }
        
    }
    
    @IBAction func closeButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ImagePickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCell.identifier, for: indexPath) as! ImagePickerCell
        guard let asset = allPhotos?.object(at: indexPath.item) else { return cell }
        // PHAsset이 Live Photo라면 badge를 추가한다.
        
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImageView.image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.imageView.image = image
            }
        })
//        cell.imageView.alpha = isSelectedArray[indexPath.item] ? 0.6 : 1.0
        cell.checkImageView.image = isSelectedArray[indexPath.item] ? UIImage(named: "check") : nil
//        cell.checkImageView.isHidden = !isSelectedArray[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos?.count ?? 0
    }
}

extension ImagePickerViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isSelectedArray[indexPath.item] = !isSelectedArray[indexPath.item]
        collectionView.reloadItems(at: [indexPath])
        attachButton.isEnabled = true
        //        guard let asset = allPhotos?.object(at: indexPath.item) else { return }
        //
        
    }
}

extension ImagePickerViewController {
    @objc private func updateItemSize() {
        if UIApplication.shared.statusBarOrientation == .portraitUpsideDown { return }
        var height = view.maxSize
        if #available(iOS 11.0, *) {
            height -= safeInset.left + safeInset.right
        }
        
        let itemWidth = UIApplication.shared.statusBarOrientation.isPortrait ? (view.minSize - 6) / 3 : (height - 12) / 5
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        let padding: CGFloat = 3
        
//        let width = view.bounds.width / 4 - (3 * 3)
//        let itemSize = CGSize(width: width, height: width)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    // MARK: Asset Caching
    
    fileprivate func updateCachedAssets() {
        // Update only if the collectionView is visible.
        guard let fetchResult = allPhotos, !collectionView.isHidden else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > collectionView.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

extension ImagePickerViewController: PHPhotoLibraryChangeObserver {
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let unwrapallPhotos = allPhotos,
            let changes = changeInstance.changeDetails(for: unwrapallPhotos)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.\
            allPhotos = changes.fetchResultAfterChanges
            isSelectedArray = [Bool](repeating: false, count: allPhotos!.count)
            
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, !changed.isEmpty {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
    }
}

//extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = view.bounds.width / 6 - (3 * 5)
//        return CGSize(width: width, height: width)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 3
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 3
//    }
//}

