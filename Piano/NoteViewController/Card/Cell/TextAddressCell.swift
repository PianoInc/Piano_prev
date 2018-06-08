//
//  TextAddressCell.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 9..
//  Copyright © 2018년 piano. All rights reserved.
//

import DynamicTextEngine_iOS
import RealmSwift
import GoogleMaps

class TextAddressCell: DynamicAttachmentCell, AttributeModelConfigurable {
    
    @IBOutlet private var mapView: UIView!
    @IBOutlet private var hLine: UIView!
    @IBOutlet private var name: UILabel!
    @IBOutlet private var vLine1: UIView!
    @IBOutlet private var duplicate: UIButton!
    @IBOutlet private var address: UILabel!
    @IBOutlet private var arrow: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor(hex8: "b5b5b540").cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 9
        mapView.layer.borderColor = UIColor(hex6: "9aa4af").cgColor
        mapView.layer.borderWidth = 0.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with id: String) {
        DispatchQueue.main.async {
            guard let realm = try? Realm(),
                let model = realm.object(ofType: RealmAddressModel.self, forPrimaryKey: id)
                else {return}
            
            let data = MapData(with: model.address)
            let camera = GMSCameraPosition.camera(withLatitude: data.coordinate[0],
                                                  longitude: data.coordinate[1],
                                                  zoom: Float(data.coordinate[2]))
            let mapView = GMSMapView.map(withFrame: self.mapView.bounds, camera: camera)
            mapView.settings.setAllGesturesEnabled(false)
            self.mapView.addSubview(mapView)
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: data.coordinate[0],
                                                     longitude: data.coordinate[1])
            marker.map = mapView
            
            self.name.text = data.title
            self.address.text = data.location
            self.duplicate.setTitle("mapCopyAddr".loc, for: .normal)
        }
    }
    
    @IBAction private func action(copy: UIButton) {
        
    }
    
}
