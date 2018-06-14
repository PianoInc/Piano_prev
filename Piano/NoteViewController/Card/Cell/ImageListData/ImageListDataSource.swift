//
//  ImageListDataSource.swift
//  Piano
//
//  Created by JangDoRi on 2018. 6. 14..
//  Copyright © 2018년 Piano. All rights reserved.
//

import UIKit
import RealmSwift

class ImageListDataSource<Cell: ImageListCell>: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private weak var listView: UICollectionView?
    private var data = [UIImage]()
    
    var didSelectRowAt: ((UIImage) -> ())?
    
    init(with listView: UICollectionView, imageListModel id: String) {
        super.init()
        
        listView.delegate = self
        listView.dataSource = self
        self.listView = listView
        
        guard let realm = try? Realm(),
            let imageModel = realm.object(ofType: RealmImageListModel.self, forPrimaryKey: id)
            else {return}
        for id in imageModel.imageIDs.components(separatedBy: "|") {
            guard let imageModel = realm.object(ofType: RealmImageModel.self, forPrimaryKey: id),
            let image = UIImage(data: imageModel.image) else {continue}
            data.append(image)
        }
        
        listView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
        cell.imageView.image = data[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        didSelectRowAt?(data[indexPath.row])
    }
    
}

