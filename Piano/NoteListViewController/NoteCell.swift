//
//  NoteCell.swift
//  Piano
//
//  Created by Kevin Kim on 24/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

struct Note: CollectionDatable {
    
    let noteType: NoteViewController.NoteType
    let content: String
    let footnote: String
   
    var sectionTitle: String?
    var sectionIdentifier: String?
    
    init(noteType: NoteViewController.NoteType, content: String, footnote: String, sectionTitle: String? = nil, sectionIdentifier: String? = nil) {
        self.noteType = noteType
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
    @IBOutlet weak var leftStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    
    private let originInnerViewLeading: CGFloat = 7
    private let originInnerViewTrailing: CGFloat = 7
    private var startInnerViewLeading: CGFloat = 0
    private var startInnerViewTrailing: CGFloat = 0
    let buttonWidth: CGFloat = 65
    let buttonMargin: CGFloat = 5
    var isAnimating: Bool = false
    
    
    
    var data: CollectionDatable? {
        didSet {
            guard let data = self.data as? Note else { return }
            footnoteLabel.text = data.footnote
            shareImageView.isHidden = !data.noteType.isShared
            let firstLineText = data.content.firstLineText(font: titleLabel.font, width: titleLabel.bounds.width)
            titleLabel.text = firstLineText
            subTitleLabel.text = data.content.sub(firstLineText.count...)
            
            //TODO: 버튼 세팅하기
            leftButtons.forEach { leftButton in
                leftStackView.addArrangedSubview(leftButton)
            }
            
            rightButtons.forEach { rightButton in
                rightStackView.addArrangedSubview(rightButton)
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(NoteCell.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
}

//MARK: Dynamic Buttons
extension NoteCell {
    var leftButtons: [UIButton] {
        
        var buttons: [UIButton] = []
        guard let data = self.data as? Note else { return buttons }
        
        switch data.noteType {
        case .open(let noteInfo):
            if noteInfo.isPinned {
                let unPinButton = self.createSubviewIfNeeded(identifier: UnPinButton.identifier) as! UIButton
                unPinButton.addTarget(self, action: #selector(NoteCell.tapUnPin(_:)), for: .touchUpInside)
                buttons.append(unPinButton)
            } else {
                let pinButton = self.createSubviewIfNeeded(identifier: PinButton.identifier) as! UIButton
                pinButton.addTarget(self, action: #selector(NoteCell.tapPin(_:)), for: .touchUpInside)
                buttons.append(pinButton)
            }
            
            let lockButton = self.createSubviewIfNeeded(identifier: LockButton.identifier) as! UIButton
            lockButton.addTarget(self, action: #selector(NoteCell.tapLock(_:)), for: .touchUpInside)
            buttons.append(lockButton)
            
            
        case .lock(let noteInfo):
            if noteInfo.isPinned {
                let unPinButton = self.createSubviewIfNeeded(identifier: UnPinButton.identifier) as! UIButton
                unPinButton.addTarget(self, action: #selector(NoteCell.tapUnPin(_:)), for: .touchUpInside)
                buttons.append(unPinButton)
            } else {
                let pinButton = self.createSubviewIfNeeded(identifier: PinButton.identifier) as! UIButton
                pinButton.addTarget(self, action: #selector(NoteCell.tapPin(_:)), for: .touchUpInside)
                buttons.append(pinButton)
            }
            
            let unLockButton = self.createSubviewIfNeeded(identifier: UnlockButton.identifier) as! UIButton
            unLockButton.addTarget(self, action: #selector(NoteCell.tapUnlock(_:)), for: .touchUpInside)
            buttons.append(unLockButton)
            
        case .trash, .create:
            ()
        }
        return buttons
    }
    
    var rightButtons: [UIButton] {
        var buttons: [UIButton] = []
        guard let data = self.data as? Note else { return buttons }
        
        switch data.noteType {
        case .open, .lock:
            let categoryButton = self.createSubviewIfNeeded(identifier: CategoryButton.identifier) as! UIButton
            categoryButton.addTarget(self, action: #selector(NoteCell.tapCategory(_:)), for: .touchUpInside)
            buttons.append(categoryButton)
            
            let trashButton = self.createSubviewIfNeeded(identifier: TrashButton.identifier) as! UIButton
            trashButton.addTarget(self, action: #selector(NoteCell.tapTrash(_:)), for: .touchUpInside)
            buttons.append(trashButton)
            
        case .trash:
            
            let deleteButton = self.createSubviewIfNeeded(identifier: DeleteButton.identifier) as! UIButton
            deleteButton.addTarget(self, action: #selector(NoteCell.tapDelete(_:)), for: .touchUpInside)
            buttons.append(deleteButton)
            
            let restoreButton = self.createSubviewIfNeeded(identifier: RestoreButton.identifier) as! UIButton
            restoreButton.addTarget(self, action: #selector(NoteCell.tapRestore(_:)), for: .touchUpInside)
            buttons.append(restoreButton)
            
        case .create:
            ()
        }
        return buttons
    }
    
    @objc func tapDelete(_ sender: Any) {
        
    }
    
    @objc func tapLock(_ sender: Any) {
        print("tapLock")
        guard let data = self.data as? Note else { return }
        let id = data.noteType.id
        //TODO: id값으로 해당 메모 잠금시키기
    }
    
    @objc func tapUnPin(_ sender: Any) {
        
    }
    
    @objc func tapPin(_ sender: Any) {
        print("tapPin")
        guard let data = self.data as? Note else { return }
        let id = data.noteType.id
        //TODO: id값으로 해당 메모 고정시키기
    }
    
    @objc func tapUnlock(_ sender: Any) {
    }
    
    @objc func tapCategory(_ sender: Any) {
        print("tapChangeCategory")
        guard let data = self.data as? Note else { return }
        let id = data.noteType.id
        //TODO: id값으로 해당 메모 카테고리 바꾸기(AppNavigator 활용하여 화면 띄우기)
    }
    
    
    
    @IBAction func tapRestore(_ sender: Any) {
    }
    
    @IBAction func tapTrash(_ sender: Any) {
        print("tapTrash")
        guard let data = self.data as? Note else { return }
        let id = data.noteType.id
        //TODO: id값으로 해당 메모 휴지통으로 보내기
    }
    
    
}

//MARK: UIGestureRecognizerDelegate
extension NoteCell: UIGestureRecognizerDelegate {
    private var animationDuration: Double {
        return 0.2
    }
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard !isAnimating else { return false }
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
    
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            startInnerViewLeading = innerViewLeadingConstraint.constant
            startInnerViewTrailing = innerViewTrailingConstraint.constant
        case .changed:
            let translationX = recognizer.translation(in: self).x
            //음수는 왼쪽으로 이동, 양수는 오른쪽으로 이동
            
            if translationX < 0 {
                if innerViewLeadingConstraint.constant > originInnerViewLeading {
                    innerViewLeadingConstraint.constant = startInnerViewLeading + translationX
                    return
                } else {
                    innerViewLeadingConstraint.constant = originInnerViewLeading
                }
                
                let relativeTranslationX = translationX + startInnerViewLeading

                let maximumWidth = rightStackView.bounds.width + buttonMargin + originInnerViewTrailing
                if innerViewTrailingConstraint.constant >= maximumWidth {
                    //더이상 pan안되게 함
                    innerViewTrailingConstraint.constant = maximumWidth
                } else if innerViewTrailingConstraint.constant >= originInnerViewTrailing {
                    innerViewTrailingConstraint.constant = startInnerViewTrailing - relativeTranslationX
                } else {
                    innerViewTrailingConstraint.constant = originInnerViewTrailing
                }
            }
            
            if translationX > 0 {
                
                if innerViewTrailingConstraint.constant > originInnerViewTrailing {
                    innerViewTrailingConstraint.constant = startInnerViewTrailing - translationX
                    return
                } else {
                    innerViewTrailingConstraint.constant = originInnerViewTrailing
                }
                
                let relativeTranslationX = translationX - startInnerViewTrailing
                
                let maximumWidth = leftStackView.bounds.width + buttonMargin + originInnerViewLeading
                if innerViewLeadingConstraint.constant >= maximumWidth {
                    //더이상 pan안되게 함
                    innerViewLeadingConstraint.constant = maximumWidth
                } else if innerViewLeadingConstraint.constant >= originInnerViewTrailing {
                    innerViewLeadingConstraint.constant = startInnerViewLeading + relativeTranslationX
                } else {
                    innerViewLeadingConstraint.constant = originInnerViewLeading
                }
            }

        case .ended, .cancelled:
            
            
            let rightWidth: CGFloat = (buttonMargin + buttonWidth) * CGFloat(rightButtons.count) + originInnerViewTrailing
            let leftWidth: CGFloat = (buttonMargin + buttonWidth) * CGFloat(leftButtons.count) + originInnerViewLeading
            
            if innerViewTrailingConstraint.constant >= rightWidth {
                animateRightOpen()
            } else if innerViewLeadingConstraint.constant >= leftWidth {
                animateLeftOpen()
            } else {
                animateToDefault()
            }
            
            
            startInnerViewLeading = originInnerViewLeading
            startInnerViewTrailing = originInnerViewTrailing
        default:
            ()
        }
        
    }
    

    
    func animateToDefault() {
        
        isAnimating = true
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            guard let `self` = self else { return }
            self.innerViewLeadingConstraint.constant = self.originInnerViewLeading
            self.innerViewTrailingConstraint.constant = self.originInnerViewTrailing
            self.layoutIfNeeded()
        }) { [weak self](bool) in
            if bool {
                self?.isAnimating = false
            }
        }
        
        
    }
    
    func animateLeftOpen() {
        
        isAnimating = true
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            guard let `self` = self else { return }
            self.innerViewLeadingConstraint.constant = self.originInnerViewLeading + self.leftStackView.bounds.width + self.buttonMargin
            self.layoutIfNeeded()
        }) { [weak self](bool) in
            if bool {
                self?.isAnimating = false
            }
        }
        
    }
    
    func animateRightOpen() {
        
        isAnimating = true
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            guard let `self` = self else { return }
            self.innerViewTrailingConstraint.constant = self.originInnerViewTrailing + self.rightStackView.bounds.width + self.buttonMargin
            self.layoutIfNeeded()
            
        }) { [weak self](bool) in
            if bool {
                self?.isAnimating = false
            }
        }

    }
}
