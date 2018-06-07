//
//  NoteGroup.swift
//  Piano
//
//  Created by Kevin Kim on 2018. 6. 7..
//  Copyright © 2018년 Piano. All rights reserved.
//

import Foundation

class DateChecker {
    
    private lazy var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        return calendar
    }()
    /*
    var todayPredicate: NSPredicate {
        let todayDate = Date()
        let dateFrom = self.calendar.startOfDay(for: todayDate)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)!
        return NSPredicate(format: "(%@ <= isModified) AND (isModified < %@) AND isPinned == false", [dateFrom, dateTo])
    }
    
    var yesterdayPredicate: NSPredicate {
        let yesterdayDate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 1)
        let dateFrom = self.calendar.startOfDay(for: yesterdayDate)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)!
        return NSPredicate(format: "(%@ <= isModified) AND (isModified < %@) AND isPinned == false", [dateFrom, dateTo])
    }
    
    var recentOneWeek: NSPredicate {
        let recentOneWeek = Date(timeIntervalSinceNow: -60 * 60 * 24 * 7)
        let dateFrom = self.calendar.startOfDay(for: recentOneWeek)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dateFrom)
        components.day! += 6
        let dateTo = calendar.date(from: components)!
        return NSPredicate(format: "(%@ <= isModified) AND (isModified < %@) AND isPinned == false", [dateFrom, dateTo])
    }
    
    var recentOneMonth: NSPredicate {
        let previousOneMonth = Date(timeIntervalSinceNow: -60 * 60 * 24 * 30)
        let dateFrom = self.calendar.startOfDay(for: previousOneMonth)
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dateFrom)
        components.day! += 23
        let dateTo = calendar.date(from: components)!
        return NSPredicate(format: "(%@ <= isModified) AND (isModified < %@) AND isPinned == false", [dateFrom, dateTo])
    }
    
    */
    
    //성능 이슈
    //오늘
    //어제
    //최근 일주일
    //최근 한달
    //최근 n년
    
    
}
