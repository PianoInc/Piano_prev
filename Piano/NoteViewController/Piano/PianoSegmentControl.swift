//
//  PianoSegmentControl.swift
//  Piano
//
//  Created by Kevin Kim on 26/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

class PianoSegmentControl: UIView {
    static let height: CGFloat = 120
    @IBOutlet weak var textColorImageView: UIImageView!
    @IBOutlet weak var textColorLabel: UILabel!
    @IBOutlet weak var highlighterImageView: UIImageView!
    @IBOutlet weak var highlighterLabel: UILabel!
    @IBOutlet weak var boldImageView: UIImageView!
    @IBOutlet weak var boldLabel: UILabel!
    @IBOutlet weak var italicImageView: UIImageView!
    @IBOutlet weak var italicLabel: UILabel!
    @IBOutlet weak var strikethroughImageView: UIImageView!
    @IBOutlet weak var strikethroughLabel: UILabel!
    @IBOutlet weak var underlineImageView: UIImageView!
    @IBOutlet weak var underlineLabel: UILabel!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    let notification = UINotificationFeedbackGenerator()
    
    weak var pianoView: PianoView?
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        textColorLabel.text = NSLocalizedString("TextColor", comment: "글자색")
        highlighterLabel.text = NSLocalizedString("Highlighter", comment: "형광펜")
        boldLabel.text = NSLocalizedString("Bold", comment: "강조")
        italicLabel.text = NSLocalizedString("Italic", comment: "기울기")
        strikethroughLabel.text = NSLocalizedString("Strikethrough", comment: "취소선")
        underlineLabel.text = NSLocalizedString("Underline", comment: "밑줄")
        headerLabel.text = NSLocalizedString("header", comment: "머리말") + "1"
    }
    
    func changeState(selectedImageView: UIImageView, selectedLabel: UILabel) {
        
        textColorImageView.image?.withRenderingMode(.alwaysTemplate)
        textColorImageView.tintColor = textColorImageView != selectedImageView ? Color.lightGray : Color.point
        textColorLabel.textColor = textColorLabel != selectedLabel ? Color.lightGray : Color.point
        textColorLabel.font = textColorLabel != selectedLabel ? Font.systemFont(ofSize: 11) : Font.boldSystemFont(ofSize: 11)
        
        highlighterImageView.image?.withRenderingMode(.alwaysTemplate)
        highlighterImageView.tintColor = highlighterImageView != selectedImageView ? Color.lightGray : Color.point
        highlighterLabel.textColor = highlighterLabel != selectedLabel ? Color.lightGray : Color.point
        highlighterLabel.font = highlighterLabel != selectedLabel ? Font.systemFont(ofSize: 11) : Font.boldSystemFont(ofSize: 11)
        
        boldImageView.image?.withRenderingMode(.alwaysTemplate)
        boldImageView.tintColor = boldImageView != selectedImageView ? Color.lightGray : Color.point
        boldLabel.textColor = boldLabel != selectedLabel ? Color.lightGray : Color.point
        boldLabel.font = boldLabel != selectedLabel ? Font.systemFont(ofSize: 11) : Font.boldSystemFont(ofSize: 11)
        
        italicImageView.image?.withRenderingMode(.alwaysTemplate)
        italicImageView.tintColor = italicImageView != selectedImageView ? Color.lightGray : Color.point
        italicLabel.textColor = italicLabel != selectedLabel ? Color.lightGray : Color.point
        italicLabel.font = italicLabel != selectedLabel ? Font.systemFont(ofSize: 11) : Font.boldSystemFont(ofSize: 11)
        
        strikethroughImageView.image?.withRenderingMode(.alwaysTemplate)
        strikethroughImageView.tintColor = strikethroughImageView != selectedImageView ? Color.lightGray : Color.point
        strikethroughLabel.textColor = strikethroughLabel != selectedLabel ? Color.lightGray : Color.point
        strikethroughLabel.font = strikethroughLabel != selectedLabel ? Font.systemFont(ofSize: 11) : Font.boldSystemFont(ofSize: 11)
        
        underlineImageView.image?.withRenderingMode(.alwaysTemplate)
        underlineImageView.tintColor = underlineImageView != selectedImageView ? Color.lightGray : Color.point
        underlineLabel.textColor = underlineLabel != selectedLabel ? Color.lightGray : Color.point
        underlineLabel.font = underlineLabel != selectedLabel ? Font.systemFont(ofSize: 11) : Font.boldSystemFont(ofSize: 11)
        
        headerImageView.image?.withRenderingMode(.alwaysTemplate)
        headerImageView.tintColor = headerImageView != selectedImageView ? Color.lightGray : Color.point
        headerLabel.textColor = headerLabel != selectedLabel ? Color.lightGray : Color.point
        headerLabel.font = headerLabel != selectedLabel ? Font.systemFont(ofSize: 11) : Font.boldSystemFont(ofSize: 11)
        
        notification.notificationOccurred(.success)
        
    }
    
    @IBAction func tapColor(_ sender: Any) {
        changeState(selectedImageView: textColorImageView, selectedLabel: textColorLabel)
        pianoView?.attributes = .foregroundColor
    }
    
    @IBAction func tapHighlighter(_ sender: Any) {
        changeState(selectedImageView: highlighterImageView, selectedLabel: highlighterLabel)
        pianoView?.attributes = .backgroundColor
    }
    
    @IBAction func tapBold(_ sender: Any) {
        changeState(selectedImageView: boldImageView, selectedLabel: boldLabel)
        pianoView?.attributes = .bold
    }
    
    @IBAction func tapItalic(_ sender: Any) {
        changeState(selectedImageView: italicImageView, selectedLabel: italicLabel)
        pianoView?.attributes = .italic
    }
    
    @IBAction func tapStrikethrough(_ sender: Any) {
        changeState(selectedImageView: strikethroughImageView, selectedLabel: strikethroughLabel)
        pianoView?.attributes = .strikeThrough
    }
    
    @IBAction func tapUnderline(_ sender: Any) {
        changeState(selectedImageView: underlineImageView, selectedLabel: underlineLabel)
        pianoView?.attributes = .underline
        
    }
    
    @IBAction func tapHeader(_ sender: Any) {

        //이미 선택한 걸 또 선택했다면
        if headerLabel.textColor == Color.point {
            if let str = headerLabel.text?.replacingOccurrences(of: NSLocalizedString("header", comment: "머리말"), with: ""),
                let num = Int(str) {
                let nextNum = (num) % 3 + 1
                let titleStr = NSLocalizedString("header", comment: "머리말") + "\(nextNum)"
                let imageStr = "header" + "\(nextNum)"
                headerImageView.image = UIImage(named: imageStr)
                headerLabel.text = titleStr
            }
        }
        
        changeState(selectedImageView: headerImageView, selectedLabel: headerLabel)
        if let str = headerLabel.text?.replacingOccurrences(of: NSLocalizedString("header", comment: "머리말"), with: ""), let num = Int(str) {
            switch num {
            case 1:
                pianoView?.attributes = .header1
            case 2:
                pianoView?.attributes = .header2
            case 3:
                pianoView?.attributes = .header3
            default:
                ()
            }
        }
        
    }
    
}
