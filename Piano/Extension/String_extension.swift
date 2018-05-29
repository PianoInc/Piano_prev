//
//  String_extension.swift
//  Piano
//
//  Created by Kevin Kim on 29/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import Foundation

extension String {
    
    func localized(withComment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var nsString: NSString {
        return NSString(string: self)
    }
}
