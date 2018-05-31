//
//  NoteViewController_TableViewDataSource.swift
//  PianoNote
//
//  Created by Kevin Kim on 01/05/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

extension PianoTextView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AutoCompleteTableViewCell.identifier) as! AutoCompleteTableViewCell
        configure(cell, indexPath: indexPath)
        return cell
    }

    private func configure(_ cell: AutoCompleteTableViewCell, indexPath: IndexPath) {
        
        cell.titleLabel.text = dataSource[indexPath.row].keyword
//
//        let normalAttributes = cell.titleLabel.attributedText?.attributes(at: 0, effectiveRange: nil)
//        var highlightAttributes = normalAttributes
//        highlightAttributes?[NSAttributedStringKey.backgroundColor] = UIColor.yellow.withAlphaComponent(0.5)
//
//        cell.highlight(text: dataSource[indexPath.row].input, normal: normalAttributes, highlight: highlightAttributes)

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

extension PianoTextView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        replaceProcess()
    }
}
