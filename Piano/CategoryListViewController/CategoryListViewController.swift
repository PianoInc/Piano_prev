//
//  CategoryViewController.swift
//  Piano
//
//  Created by Kevin Kim on 22/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

//Logic: DataSource가 유일한 인풋으로 되게!, 이 인풋을 통해 모든 것이 결정됨
//TODO: 앱 내 url을 UniversialLink로 바꾸기

import UIKit
import MessageUI

class CategoryListViewController: UIViewController {
    
    //(모든 폴더, 커스텀 폴더), (잠긴 폴더, 삭제된 폴더), 이미지 데이터,
    lazy var dataSource: [[CollectionDatable]] = {
        
        var dataSource: [[CollectionDatable]] = []
        //section 0
        let allCategory: [CollectionDatable] = [CategoryDefaultTag(categoryType: .all, hasSeparator: true)]
        dataSource.append(allCategory)
        
        //section 1
        //TODO: 여기에 realm 카테고리 str 넣기
        let customCategories: [CategoryCustomTag] = [
            CategoryCustomTag(categoryType: .custom("피아노"), order: 1),
            CategoryCustomTag(categoryType: .custom("비지니스"), order: 2)]
        dataSource.append(customCategories)
        
        //section 2
        let defaultCategories: [CategoryDefaultTag] = [
            CategoryDefaultTag(categoryType: .locked, hasSeparator: false),
            CategoryDefaultTag(categoryType: .deleted, hasSeparator: true)]
        dataSource.append(defaultCategories)
        
        //section 3
        let communityCategories: [CategoryNotification] = [
            CategoryNotification(title: "평소에 메모앱에 무엇을 적으시나요?",
                         subTitle: "가계부, 일정, 과제 등",
                         link: .facebook, subType: "분류",
                         image: Image(named: "test1")),
            CategoryNotification(title: "피아노의 새로운 기능",
                                 subTitle: "피아노 효과, 사용자 서식, 자동 완성",
                                 link: .usage, subType: "분류",
                                 image: Image(named: "test2"))
        ]
        dataSource.append(communityCategories)

        //section 4
        let linkCategories: [CategoryLink] = [
            CategoryLink(link: .pianist, sectionTitle: "바로가기", sectionIdentifier: CategoryTitleReusableView.identifier, hasSeparator: true),
            CategoryLink(link: .homepage, sectionTitle: "바로가기", sectionIdentifier: CategoryTitleReusableView.identifier, hasSeparator: true),
            CategoryLink(link: .appStore, sectionTitle: "바로가기", sectionIdentifier: CategoryTitleReusableView.identifier, hasSeparator: false)]
        dataSource.append(linkCategories)
        
        //section 5
        let extraCategory: [CategoryExtra] = [
            CategoryExtra(versionStr: "버전: 1.0", licenceStr: "라이센스", sendMailStr: "문의하기", presentLicenseVC: { [weak self] in
                self?.performSegue(withIdentifier: LicenseViewController.identifier, sender: nil)
            }, presentMailVC: { [weak self] in
                self?.sendEmail(withTitle: "문의드립니다.")
            })]
        dataSource.append(extraCategory)
        
        return dataSource
        
    }()

    @IBOutlet weak var collectionView: UICollectionView!
    lazy var viewWidth: CGFloat = {
        return self.view.bounds.width
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCollectionViewInset()
    }
    
    private func updateCollectionViewInset() {
        collectionView.contentInset = UIEdgeInsetsMake(0, collectionView.marginLeft, 0, collectionView.marginRight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { [weak self] (context) in
            guard let strongSelf = self else { return }
            strongSelf.updateCollectionViewInset()
            strongSelf.collectionView.performBatchUpdates({
                strongSelf.collectionView
                    .setCollectionViewLayout(
                        strongSelf.collectionView.collectionViewLayout,
                        animated: true)
            }, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let type = sender as? NoteListViewController.CategoryType {
            let destinationVC = segue.destination as? NoteListViewController
            destinationVC?.type = type
        }
    }


}

extension CategoryListViewController: MFMailComposeViewControllerDelegate {
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendEmail(withTitle: String) {
        let mailComposeViewController = configuredMailComposeViewController(withTitle: withTitle)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showBasicAlertController(title: "EmailErrorTitle".localized(withComment: "메일을 보낼 수 없습니다."), message: "CheckDeviceOrInternet".localized(withComment: "디바이스 혹은 인터넷 상태를 확인해주세요"))
        }
    }
    
    private func configuredMailComposeViewController(withTitle: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["OurLovePiano@gmail.com"])
        mailComposerVC.setSubject(withTitle)
        mailComposerVC.setMessageBody("hi. i like piano app.", isHTML: false)
        
        return mailComposerVC
    }
    
    private func showBasicAlertController(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK".localized(withComment: "확인"), style: .cancel, handler: nil)
        alertViewController.addAction(cancel)
        present(alertViewController, animated: true, completion: nil)
    }
}
