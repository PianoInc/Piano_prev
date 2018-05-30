//
//  Date_extension.swift
//  Piano
//
//  Created by Kevin Kim on 29/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import Foundation

extension Date {
    
    // Date값을 주어진 Time format에 맞춰 반환한다.
    var timeFormat: String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        
        var todayComponents = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        todayComponents.hour = 0
        todayComponents.minute = 0
        let today = calendar.date(from: todayComponents)!
        
        let interval = calendar.dateComponents([.year, .month, .day, .hour], from: self, to: today)
        if interval.year! > 0 {
            return String(format: "dateYearPast".locale, components.year!, components.month!)
        } else if interval.month! > 0 {
            return String(format: "dateYear".locale, interval.month!)
        } else if interval.day! > 6 {
            return "dateMonth".locale
        } else if interval.day! > 0 {
            return "dateWeek".locale
        } else if interval.hour! > 0 {
            return "dateYesterday".locale
        } else {
            return "dateToday".locale
        }
    }
    
//    var startDay: Date {
//        let calendar = Calendar(identifier: .gregorian)
//        calendar.isDateInToday(<#T##date: Date##Date#>)
//        calendar.is
//
//
//        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
//        let unitFlags: NSCalendarUnit = [.Minute, .Hour, .Day, .Month, .Year]
//        let todayComponents = gregorian!.components(unitFlags, fromDate: day)
//        todayComponents.hour = 0
//        todayComponents.minute = 0
//        return (gregorian?.dateFromComponents(todayComponents))!
//    }
    
}
