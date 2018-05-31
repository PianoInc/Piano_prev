//
//  PianoAssistTableViewCell.swift
//  PianoNote
//
//  Created by Kevin Kim on 01/05/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

class AutoCompleteTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setSelectedBackgroundView()
        
    }
    
    private func setSelectedBackgroundView() {
        let view = UIView()
        view.backgroundColor = Color.point
        selectedBackgroundView = view
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        titleLabel.textColor = isSelected ? .white : .black
        
    }

}
