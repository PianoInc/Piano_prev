//
//  TextEventCell.swift
//  Piano
//
//  Created by Kevin Kim on 07/06/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import DynamicTextEngine_iOS
import UIKit
import RealmSwift
import EventKitUI

class TextEventCell: DynamicAttachmentCell, AttributeModelConfigurable {
   
    @IBOutlet private var month: UILabel!
    @IBOutlet private var day: UILabel!
    @IBOutlet private var dday: UILabel!
    @IBOutlet private var title: UILabel!
    @IBOutlet weak var button: UIButton!
    
    private var event: EKEvent!
    private var eventID = ""
    
    func configure(with id: String) {
        guard let realm = try? Realm(),
            let eventModel = realm.object(ofType: RealmEventModel.self, forPrimaryKey: id)
            else {return}
        eventID = eventModel.event
        
        let eventStore = EKEventStore()
        guard let event = eventStore.event(withIdentifier: eventModel.event) else {return}
        self.event = event
        
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
        let formatStr = formatter.string(from: event.startDate, to: today) ?? ""
        
        do {
            let regex = try NSRegularExpression(pattern: "[0-9]", options: [])
            guard let regexRange = regex.firstMatch(in: formatStr, options: [], range: NSMakeRange(0, formatStr.count))?.range else {return}
            
            let start = regexRange.location
            let end = start + regexRange.length
            let dayComponents = formatStr.sub(start...end)
            dday.text = (dayComponents == "0") ? "D-Day" : String(format: "D-%@", dayComponents)
        } catch {
            dday.text = formatStr
        }
        
        title.text = event.title
    }
    
    @IBAction private func action(select: UIButton) {
        let eventStore = EKEventStore()
        var event = eventStore.event(withIdentifier: eventID)
        if event == nil {
            do {
                try eventStore.save(self.event, span: .thisEvent)
                event = eventStore.event(withIdentifier: eventID)
            } catch {
                event = EKEvent(eventStore: eventStore)
            }
        }
        
        guard let noteViewCtrl = AppNavigator.currentViewController as? NoteViewController else {return}
        let eventController = EKEventEditViewController()
        eventController.eventStore = eventStore
        eventController.event = event
        eventController.editViewDelegate = noteViewCtrl
        noteViewCtrl.present(eventController, animated: true)
    }
    
}
