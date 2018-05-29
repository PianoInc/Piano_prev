//
//  ExtraCell.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

//TODO: CategoryExtra 데이터 구조 바꾸기

struct CategoryExtra: CollectionDatable {

    let versionStr: String
    let licenceStr: String
    let sendMailStr: String
    var sectionTitle: String?
    var sectionIdentifier: String?
    
    var presentLicenseVC: (() -> Void)
    var presentMailVC: (() -> Void)
    
    init(versionStr: String, licenceStr: String, sendMailStr: String, sectionTitle: String? = nil, sectionIdentifier: String? = nil, presentLicenseVC: @escaping (() -> Void), presentMailVC: @escaping (() -> Void)) {
        self.versionStr = versionStr
        self.licenceStr = licenceStr
        self.sendMailStr = sendMailStr
        self.sectionTitle = sectionTitle
        self.sectionIdentifier = sectionIdentifier
        self.presentMailVC = presentMailVC
        self.presentLicenseVC = presentLicenseVC
    }
    
    func size(maximumWidth: CGFloat) -> CGSize {
        return CGSize(width: maximumWidth, height: 140)
    }
    
    func didSelectItem(fromVC viewController: ViewController) {
        //아무 반응도 안함
    }
    
}

class CategoryExtraCell: UICollectionViewCell, CollectionDataAcceptable {
    @IBOutlet weak var sendMailButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var licenseButton: UIButton!
    var presentMailVC: (() -> Void)?
    var presentLicenseVC: (() -> Void)?
    
    var data: CollectionDatable? {
        didSet {
            guard let data = self.data as? CategoryExtra else { return }
            sendMailButton.setTitle(data.sendMailStr, for: .normal)
            versionLabel.text = data.versionStr
            licenseButton.setTitle(data.licenceStr, for: .normal)
            presentLicenseVC = data.presentLicenseVC
            presentMailVC = data.presentMailVC
        }
    }
    
    @IBAction func tapLicense(_ sender: Any) {
        presentLicenseVC?()
    }
    
    @IBAction func tapSendMail(_ sender: Any) {
        presentMailVC?()
    }
    
}
