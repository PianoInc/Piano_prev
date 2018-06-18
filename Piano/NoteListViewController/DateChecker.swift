//
//  NoteGroup.swift
//  Piano
//
//  Created by Kevin Kim on 2018. 6. 7..
//  Copyright © 2018년 Piano. All rights reserved.
//

import Foundation

typealias DateCheck = (predict: NSPredicate, title: String)

class DateChecker {
    
    var checker: [DateCheck] {
        return [(todayPredicate, "오늘"), (yesterdayPredicate, "어제"), (recentOneWeek, "최근 일주일"),
                (recentOneMonth, "최근 한달"), (recentOneYear, "최근 일년")]
    }
    
    private lazy var calendar: Calendar = {
        return Calendar.current
    }()
    
    private var todayPredicate: NSPredicate {
        let to = Date()
        
        let from = calendar.startOfDay(for: to)
        
        return NSPredicate(format: "(%@ <= isModified) AND (isModified < %@) AND isPinned == false",
                           from as CVarArg, to as CVarArg)
    }
    
    private var yesterdayPredicate: NSPredicate {
        let to = calendar.startOfDay(for: Date())
        
        var components = calendar.dateComponents([.year, .month, .day], from: to)
        components.day! -= 1
        let from = calendar.date(from: components)!
        
        return NSPredicate(format: "(%@ <= isModified) AND (isModified < %@) AND isPinned == false",
                           from as CVarArg, to as CVarArg)
    }
    
    private var recentOneWeek: NSPredicate {
        let today = calendar.startOfDay(for: Date())
        
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.day! -= 1
        let to = calendar.date(from: components)!
        
        components = calendar.dateComponents([.year, .month, .day], from: today)
        components.day! -= 7
        let from = calendar.date(from: components)!
        
        return NSPredicate(format: "(%@ <= isModified) AND (isModified < %@) AND isPinned == false",
                           from as CVarArg, to as CVarArg)
    }
    
    private var recentOneMonth: NSPredicate {
        let today = calendar.startOfDay(for: Date())
        
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.day! -= 7
        let to = calendar.date(from: components)!
        
        components = calendar.dateComponents([.year, .month, .day], from: today)
        components.month! -= 1
        let from = calendar.date(from: components)!
        
        return NSPredicate(format: "(%@ <= isModified) AND (isModified < %@) AND isPinned == false",
                           from as CVarArg, to as CVarArg)
    }
    
    private var recentOneYear: NSPredicate {
        let today = calendar.startOfDay(for: Date())
        
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.month! -= 1
        let to = calendar.date(from: components)!
        
        components = calendar.dateComponents([.year, .month, .day], from: today)
        components.year! -= 1
        let from = calendar.date(from: components)!
        
        return NSPredicate(format: "(%@ <= isModified) AND (isModified < %@) AND isPinned == false",
                           from as CVarArg, to as CVarArg)
    }

    //성능 이슈
    //오늘
    //어제
    //최근 일주일
    //최근 한달
    //최근 n년
    
}

