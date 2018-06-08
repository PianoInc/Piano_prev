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
            return String(format: "recentYear".loc, components.year!)
        } else if interval.month! > 0 {
            return String(format: "recentYear".loc, 1)
        } else if interval.day! > 6 {
            return "recentMonth".loc
        } else if interval.day! > 0 {
            return "recentWeek".loc
        } else if interval.hour! > 0 {
            return "yesterday".loc
        } else {
            return "today".loc
        }
    }
    
}

