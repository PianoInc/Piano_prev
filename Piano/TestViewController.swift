//
//  TestViewController.swift
//  Piano
//
//  Created by Kevin Kim on 26/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.centerVertically()
        
        let segmentControl = view.createSubviewIfNeeded(identifier: PianoSegmentControl.identifier)
        view.addSubview(segmentControl)
        
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        let topAnchor = segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        let leadingAnchor = segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        let trailingAnchor = segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        let heightAnchor = segmentControl.heightAnchor.constraint(equalToConstant: 80)
        NSLayoutConstraint.activate([topAnchor, leadingAnchor, trailingAnchor, heightAnchor])
        
    }

}
