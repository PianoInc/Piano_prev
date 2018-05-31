//
//  NoteCell.swift
//  Piano
//
//  Created by Kevin Kim on 24/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

struct Note: CollectionDatable {
    
    let type: NoteViewController.NoteType
    let content: String
    let footnote: String
   
    var sectionTitle: String?
    var sectionIdentifier: String?
    
    init(type: NoteViewController.NoteType, content: String, footnote: String, sectionTitle: String? = nil, sectionIdentifier: String? = nil) {
        self.type = type
        self.content = content
        self.footnote = footnote
        self.sectionTitle = sectionTitle
        self.sectionIdentifier = sectionIdentifier
    }
    
    //뷰의 가로가 320 * 2개 + interItemSpacing * 1개 + 양 옆 margin
    func size(maximumWidth: CGFloat) -> CGSize {
        var cellCount = 1
        while true {
            if maximumWidth < minimumCellWidth * CGFloat(cellCount + 1) + minimumInteritemSpacing * CGFloat(cellCount) + sectionInset.left + sectionInset.right {
                let cellWidth = (maximumWidth - (minimumInteritemSpacing * CGFloat(cellCount - 1) + sectionInset.left + sectionInset.right))/CGFloat(cellCount)
                return CGSize(width: cellWidth - 3, height: 120)
            }
            cellCount += 1
        }
    }
    
    var headerSize: CGSize {
        return CGSize(width: 100, height: 56)
    }
    
    var minimumInteritemSpacing: CGFloat {
        return 12
    }

    var minimumLineSpacing: CGFloat {
        return 11
    }
    
    func didSelectItem(fromVC viewController: ViewController) {
//        viewController.performSegue(withIdentifier: NoteViewController.identifier, sender: type)
    }
    
}

class NoteCell: UICollectionViewCell, CollectionDataAcceptable {
    
    @IBOutlet weak var footnoteLabel: UILabel!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var innerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerViewTrailingConstraint: NSLayoutConstraint!
    
    var data: CollectionDatable? {
        didSet {
            guard let data = self.data as? Note else { return }     
            footnoteLabel.text = data.footnote
            shareImageView.isHidden = !data.type.isShared
            let firstLineText = data.content.firstLineText(font: titleLabel.font, width: titleLabel.bounds.width)
            titleLabel.text = firstLineText
            subTitleLabel.text = data.content.sub(firstLineText.count...)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
    }
    

    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
    }
    
    
    
    @IBAction func tapPin(_ sender: Any) {
        guard let data = self.data as? Note else { return }
        let id = data.type.id
        //TODO: id값으로 해당 메모 고정시키기

    }
    
    @IBAction func tapLock(_ sender: Any) {
        guard let data = self.data as? Note else { return }
        let id = data.type.id
        //TODO: id값으로 해당 메모 잠금시키기
    }
    
    @IBAction func tapChangeCategory(_ sender: Any) {
        guard let data = self.data as? Note else { return }
        let id = data.type.id
        //TODO: id값으로 해당 메모 카테고리 바꾸기(AppNavigator 활용하여 화면 띄우기)
    }
    
    @IBAction func tapTrash(_ sender: Any) {
        guard let data = self.data as? Note else { return }
        let id = data.type.id
        //TODO: id값으로 해당 메모 휴지통으로 보내기
    }
}

extension NoteCell {
    private var animationDuration: Double {
        return 0.2
    }
    
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
//            let superView = superview {
//            let translation = panGestureRecognizer.translation(in: superView)
//            if fabs(translation.x) > fabs(translation.y) {
//                return true
//            }
//            return false
//        }
//        return false
//    }
    
//    @objc func didPan(sender: NoteGestureRecognizer) {
//
//        if sender.isActivated {
//            if startConstant == nil {
//                startConstant = innerViewLeadingConstraint.constant
//            }
//
//            var distance = startConstant! + sender.distance
//
//            if distance > 78 {
//                distance = (distance - 78)/10 + 78
//            } else if distance < -150 {
//                distance = (150 + distance)/10 - 150
//            }
//            print(distance)
//            innerViewLeadingConstraint.constant = distance
//            self.layoutIfNeeded()
//        }
//        if sender.state == .ended {
//            startConstant = nil
//
//            if innerViewLeadingConstraint.constant >= -75 && innerViewLeadingConstraint.constant <= 39 {
//                animateToDefault()
//            } else if innerViewLeadingConstraint.constant > 0 {
//                animateLeftOpen()
//            } else {
//                animateRightOpen()
//            }
//        }
//
//    }
    
    func animateToDefault() {
        UIView.animate(withDuration: animationDuration) {
            self.innerViewLeadingConstraint.constant = 7.0
            self.innerViewTrailingConstraint.constant = 7.0
            self.layoutIfNeeded()
        }
    }
    
    func animateLeftOpen() {
        UIView.animate(withDuration: animationDuration) {
            self.innerViewLeadingConstraint.constant = 78.0
            self.innerViewTrailingConstraint.constant = -78.0
            self.layoutIfNeeded()
        }
    }
    
    func animateRightOpen() {
        UIView.animate(withDuration: animationDuration) {
            self.innerViewLeadingConstraint.constant = -150
            self.innerViewTrailingConstraint.constant = 150
            self.layoutIfNeeded()
        }
    }
}
