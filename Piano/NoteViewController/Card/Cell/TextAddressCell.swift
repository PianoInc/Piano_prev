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
    @IBOutlet private var arrow: UIImageView!
    
    private var mapData: MapData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor(hex8: "b5b5b540").cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 9
        mapView.layer.borderColor = UIColor(hex6: "9aa4af").cgColor
        mapView.layer.borderWidth = 0.5
        
        initConst()
    }
    
    private func initConst() {
        mapView.anchor {
            $0.leading.equalTo(13.fit)
            $0.trailing.equalTo(-13.fit)
            $0.top.equalTo(13.fit)
            if UIDevice.current.userInterfaceIdiom == .pad {
                $0.height.equalTo(330.fit)
            } else {
                $0.height.equalTo(130.fit)
            }
        }
        hLine.anchor {
            $0.leading.equalTo(13.fit)
            $0.trailing.equalTo(-13.fit)
            $0.top.equalTo(mapView.bottomAnchor).offset(8.fit)
            $0.height.equalTo(0.5)
        }
        name.anchor {
            $0.leading.equalTo(13.fit)
            $0.top.equalTo(mapView.bottomAnchor).offset(17.fit)
            $0.width.lessThanOrEqualTo(230.fit)
        }
        vLine1.anchor {
            $0.leading.equalTo(name.trailingAnchor).offset(13.fit)
            $0.top.equalTo(mapView.bottomAnchor).offset(20.fit)
            $0.width.equalTo(0.5)
            $0.height.equalTo(13.fit)
        }
        duplicate.anchor {
            $0.leading.equalTo(vLine1.trailingAnchor).offset(13.fit)
            $0.top.equalTo(mapView.bottomAnchor).offset(18.fit)
            $0.height.equalTo(17.fit)
        }
        address.anchor {
            $0.leading.equalTo(13.fit)
            $0.top.equalTo(mapView.bottomAnchor).offset(43.fit)
            $0.width.lessThanOrEqualTo(262.fit)
        }
        arrow.anchor {
            $0.leading.equalTo(address.trailingAnchor).offset(13.fit)
            $0.top.equalTo(mapView.bottomAnchor).offset(45.fit)
            $0.height.equalTo(13.fit)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with id: String) {
        DispatchQueue.main.async {
            guard let realm = try? Realm(),
                let model = realm.object(ofType: RealmAddressModel.self, forPrimaryKey: id)
                else {return}
            self.mapData = MapData(with: model.address)
            guard let data = self.mapData else {return}
            
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
        guard let data = self.mapData else {return}
        UIPasteboard.general.string = data.location
        
        let isPhoneX = [UIScreen.main.bounds.width, UIScreen.main.bounds.height].contains(812)
        
        guard let naviCtrl = AppNavigator.currentNavigationController else {return}
        let statusFrame = UIApplication.shared.statusBarFrame
        let barFrame = naviCtrl.navigationBar.frame
        let height = isPhoneX ? statusFrame.height + barFrame.height : statusFrame.height
        
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: barFrame.width, height: height))
        window.windowLevel = UIWindowLevelStatusBar + 1
        window.makeKeyAndVisible()
        
        let alertView = UIView(frame: CGRect(x: 0, y: -height, width: barFrame.width, height: height))
        alertView.backgroundColor = UIColor(hex6: "007dfb")
        window.addSubview(alertView)
        
        let alertLabel = UILabel(frame: CGRect(x: 5, y: height - 20, width: barFrame.width - 5, height: 20))
        alertLabel.backgroundColor = .clear
        alertLabel.textColor = .white
        alertLabel.font = UIFont.systemFont(ofSize: 12)
        alertLabel.text = "주소가 복사되었습니다."
        alertView.addSubview(alertLabel)
        
        UIView.animate(withDuration: 0.2) {
            alertView.frame.origin.y = 0
        }
        UIView.animate(withDuration: 0.2, delay: 2.2, options: [.allowUserInteraction], animations: {
            alertView.frame.origin.y = -height
        }, completion: { finished in
            window.removeFromSuperview()
        })
    }
    
}

