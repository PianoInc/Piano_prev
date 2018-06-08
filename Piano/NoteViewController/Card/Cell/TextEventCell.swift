//
//  TextEventCell.swift
//  Piano
//
//  Created by Kevin Kim on 07/06/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import DynamicTextEngine_iOS
import UIKit
import EventKit
import RealmSwift

class TextEventCell: DynamicAttachmentCell, AttributeModelConfigurable {
   
    @IBOutlet private var month: UILabel!
    @IBOutlet private var day: UILabel!
    @IBOutlet private var dday: UILabel!
    @IBOutlet private var title: UILabel!

    func configure(with id: String) {
        guard let realm = try? Realm(),
            let eventModel = realm.object(ofType: RealmEventModel.self, forPrimaryKey: id)
            else {return}
        
        let eventStore = EKEventStore()
        guard let event = eventStore.event(withIdentifier: eventModel.event) else {return}
        
        let format = DateFormatter()
        
        format.dateFormat = "MM"
        month.text = format.string(from: event.startDate) + "월"
        
        format.dateFormat = "dd"
        day.text = format.string(from: event.startDate)
        
        let calendar = Calendar(identifier: .gregorian)
        var todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        todayComponents.hour = 0
        todayComponents.minute = 0
        todayComponents.second = 0
        let today = calendar.date(from: todayComponents)!
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        dday.text = formatter.string(from: event.startDate, to: today) ?? ""
        
        title.text = event.title
    }
    
}
