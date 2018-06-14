//
//  AlbumPhotoListView.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 7..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import Photos

class AlbumPhotoListView: UICollectionView {
    
    weak var delegates: AlbumDelegates!
    
    private let emptyView = view(UILabel()) {
        $0.text = "사진 없음"
        $0.textColor = UIColor(hex6: "9d9d9d")
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textAlignment = .center
        $0.backgroundColor = .white
    }
    
    let imageManager = PHCachingImageManager()
    private var photoFetchResult = PHFetchResult<PHAsset>() { didSet {
        photoAssets = reverse(photo: photoFetchResult)
        reloadData()
        }}
    var photoAssets = [PHAsset]()
    var albumTitle = ""
    
    var selectedIndex = [IndexPath]()
    
    convenience init() {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        viewDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewDidLoad()
    }
    
    private func viewDidLoad() {
        initView()
        fetchPhoto()
    }
    
    private func initView() {
        let nib = UINib(nibName: "AlbumPhotoCell", bundle: nil)
        print(nib)
        register(nib, forCellWithReuseIdentifier: "AlbumPhotoCell")
        backgroundColor = UIColor(hex6: "eeeeee")
        allowsSelection = false
        dataSource = self
        delegate = self
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumInteritemSpacing = 2
            flowLayout.minimumLineSpacing = 2
        }
        addSubview(emptyView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emptyView.frame = bounds
    }
    
    private func fetchPhoto() {
        if let album = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject {
            PHPhotoLibrary.shared().register(self)
            photoFetchResult = PHAsset.fetchAssets(in: album, options: nil)
            albumTitle = album.localizedTitle ?? "albumNoTitle".loc
        }
        emptyView.isHidden = (photoFetchResult.count > 0)
    }
    
    /**
     PHFetchResult를 역순으로 만들어 Array로 반환한다.
     - parameter photo : 역순으로 하려는 PHFetchResult.
     - returns : 역순으로 바꾼 PHAsset Array.
     */
    private func reverse(photo: PHFetchResult<PHAsset>) -> [PHAsset] {
        if photo.count <= 0 {return [PHAsset]()}
        var tempArray = [PHAsset]()
        for object in photo.objects(at: IndexSet(0...photo.count - 1)) {
            tempArray.append(object)
        }
        return tempArray.reversed()
    }
    
    /// albumInfo에 기반하여 photo를 reload한다.
    func requestPhoto(from albumInfo: AlbumInfo) {
        if albumInfo.type.rawValue == 1 { // 네이버 클라우드와 같은 외부 폴더
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            for album in albums.objects(at: IndexSet(0...albums.count - 1)) where album.localizedTitle == albumInfo.title {
                photoFetchResult = PHAsset.fetchAssets(in: album, options: nil)
                albumTitle = album.localizedTitle ?? "albumNoTitle".loc
            }
        } else {
            if let album = PHAssetCollection.fetchAssetCollections(with: albumInfo.type, subtype: albumInfo.subType, options: nil).firstObject {
                photoFetchResult = PHAsset.fetchAssets(in: album, options: nil)
                albumTitle = album.localizedTitle ?? "albumNoTitle".loc
            }
        }
    }
    
    /// 선택효과 처리.
    func reload(selected: IndexPath) {
        if selectedIndex.contains(selected) {
            guard let index = selectedIndex.index(where: {$0 == selected}) else {return}
            selectedIndex.remove(at: index)
        } else {
            selectedIndex.append(selected)
        }
        reloadItems(at: [selected])
    }
    
}

extension AlbumPhotoListView: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let newPhotos = changeInstance.changeDetails(for: photoFetchResult) else {return}
        photoFetchResult = newPhotos.fetchResultAfterChanges
        DispatchQueue.main.async {
            if newPhotos.hasIncrementalChanges {
                self.performBatchUpdates({
                    if let removed = newPhotos.removedIndexes, !removed.isEmpty {
                        self.deleteItems(at: removed.map({IndexPath(item: $0, section: 0)}))
                    }
                    if let inserted = newPhotos.insertedIndexes, !inserted.isEmpty {
                        self.insertItems(at: inserted.map({IndexPath(item: $0, section: 0)}))
                    }
                    if let changed = newPhotos.changedIndexes, !changed.isEmpty {
                        self.reloadItems(at: changed.map({IndexPath(item: $0, section: 0)}))
                    }
                    newPhotos.enumerateMoves { from, to in
                        self.moveItem(at: IndexPath(item: from, section: 0), to: IndexPath(item: to, section: 0))
                    }
                })
            } else {
                self.reloadData()
            }
        }
    }
    
}

extension AlbumPhotoListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
        }
        
        // 전체화면에서 보여주고자 하는 Cell의 갯수.
        var portCellNum: CGFloat = 3
        var landCellNum: CGFloat = 5
        if UIDevice.current.userInterfaceIdiom == .pad {
            portCellNum = portCellNum * 2
            landCellNum = landCellNum * 2
        }
        // 아이템 간격만큼 제외한 넓이를 구하기 위한 spacing 값.
        let portCutSpacing = flowLayout.minimumInteritemSpacing * (portCellNum - 1)
        let landCutSpacing = flowLayout.minimumInteritemSpacing * (landCellNum - 1)
        
        var cellSize = collectionView.bounds.height
        if flowLayout.scrollDirection == .vertical {
            cellSize = floor((collectionView.bounds.width - portCutSpacing) / portCellNum)
            if UIApplication.shared.statusBarOrientation.isLandscape {
                cellSize = floor((collectionView.bounds.width - landCutSpacing) / landCellNum)
            }
        }
        return CGSize(width: cellSize, height: cellSize)
    }
    
}

extension AlbumPhotoListView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumPhotoCell", for: indexPath) as! AlbumPhotoCell
        cell.delegates = delegates
        cell.indexPath = indexPath
        cell.isSelected = selectedIndex.contains(indexPath)
        
        if indexPath.row == 0 {
            cell.imageView.contentMode = .center
            cell.imageView.image = #imageLiteral(resourceName: "camera")
        } else {
            let photo = photoAssets[indexPath.row - 1]
            let size = CGSize(width: PHImageManagerMinimumSize, height: PHImageManagerMinimumSize)
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            imageManager.requestImage(for: photo, targetSize: size, contentMode: .aspectFit, options: options) { (image, _) in
                cell.imageView.contentMode = .scaleAspectFill
                cell.imageView.image = image
            }
        }
        return cell
    }
    
}

