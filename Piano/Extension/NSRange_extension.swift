//
//  NSRange_extension.swift
//  Piano
//
//  Created by Kevin Kim on 30/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import Foundation

extension Range where Bound == String.Index {
    func toNSRange() -> NSRange {
        return NSMakeRange(lowerBound.encodedOffset, upperBound.encodedOffset - lowerBound.encodedOffset)
    }
}
