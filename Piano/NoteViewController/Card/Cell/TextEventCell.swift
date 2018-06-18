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
        
        let calendar = Calendar.current
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        let startStr = formatter.string(from: calendar.startOfDay(for: Date()),
                                        to: calendar.startOfDay(for: event.startDate)) ?? ""
        
        do {
            let sRegex = try NSRegularExpression(pattern: "[-0-9]+", options: [])
            guard let sRegexRange = sRegex.firstMatch(in: startStr, options: [], range: NSMakeRange(0, startStr.count))?.range else {return}
            let sStart = sRegexRange.location
            let sEnd = sStart + sRegexRange.length
            let sComponents = startStr.sub(sStart...sEnd)
            
            let endStr = formatter.string(from: event.startDate, to: event.endDate) ?? ""
            let eRegex = try NSRegularExpression(pattern: "[0-9]+", options: [])
            guard let eRegexRange = eRegex.firstMatch(in: endStr, options: [], range: NSMakeRange(0, endStr.count))?.range else {return}
            let eStart = eRegexRange.location
            let eEnd = sStart + eRegexRange.length
            let eComponents = endStr.sub(eStart...eEnd)
            
            let isDue = (event.startDate <= Date() && Date() <= event.endDate) || event.endDate <= Date()
            guard let start = Int(sComponents), let duration = Int(eComponents) else {return}
            afterEffect(with: isDue, start, duration)
        } catch {
            dday.text = startStr
        }
        
        title.text = event.title
    }
    
    private func afterEffect(with isDue: Bool, _ start: Int, _ duration: Int) {
        if !isDue {
            if start > 7 {
                dday.textColor = UIColor(hex6: "9aa4af")
            } else if start > 0 {
                dday.textColor = UIColor(hex6: "ff3b30")
            }
            dday.text = "D-\(start)"
        } else {
            if duration != 0 {
                if abs(start) <= duration {
                    dday.text = "D-Day" + " (\(abs(start))/\(duration))"
                } else {
                    endState(with: abs(start))
                }
            } else {
                if start == 0 {
                    dday.textColor = UIColor(hex6: "007dfb")
                    dday.text = "D-Day"
                } else {
                    endState(with: abs(start))
                }
            }
        }
    }
    
    private func endState(with count: Int) {
        backgroundColor = UIColor(hex6: "f5f5f5")
        month.textColor = UIColor(hex6: "9d9d9d")
        day.textColor = UIColor(hex6: "9d9d9d")
        dday.textColor = UIColor(hex6: "9d9d9d")
        dday.text = "D+\(count)"
        title.textColor = UIColor(hex6: "9d9d9d")
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
