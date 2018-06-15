//
//  Typealiases.swift
//  Anchor
//
//  Created by JangDoRi on 2018. 5. 30..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
public typealias AnchorView = UIView
public typealias AnchorPriority = UILayoutPriority
#else
import AppKit
public typealias AnchorView = NSView
public typealias AnchorPriority = NSLayoutConstraint.Priority
#endif

