//
//  AnchorMaker.swift
//  Anchor
//
//  Created by JangDoRi on 2018. 5. 30..
//  Copyright © 2018년 piano. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif

public class AnchorMaker: NSObject {
    
    private let view: AnchorView
    private var descriptions = [AnchorDescription]()
    
    init(view: AnchorView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view = view
    }
    
    static func make(_ view: AnchorView, closure: (AnchorMaker) -> ()) {
        let anchorMaker = AnchorMaker(view: view)
        closure(anchorMaker)
        
        // AnchorConverter를 통해 만들어진 constraint들을 active 한다.
        let converter = AnchorConverter()
        for description in anchorMaker.descriptions {
            converter.anchorDescription = description
            converter.constraint {$0.isActive = true}
        }
    }
    
    private func relate(with description: AnchorDescription) -> AnchorRelatable {
        descriptions.append(description)
        return AnchorRelatable(description)
    }
    
    /// leadingAnchor.
    public var leading: AnchorRelatable {
        let anchorX = AnchorX(s: view.superview!.leadingAnchor, t: view.leadingAnchor)
        return relate(with: AnchorDescription(AnchorLayout(anchorX), attribute: .leading))
    }
    
    /// trailingAnchor.
    public var trailing: AnchorRelatable {
        let anchorX = AnchorX(s: view.superview!.trailingAnchor, t: view.trailingAnchor)
        return relate(with: AnchorDescription(AnchorLayout(anchorX), attribute: .trailing))
    }
    
    /// topAnchor.
    public var top: AnchorRelatable {
        let anchorY = AnchorY(s: view.superview!.topAnchor, t: view.topAnchor)
        return relate(with: AnchorDescription(AnchorLayout(anchorY), attribute: .top))
    }
    
    /// bottomAnchor.
    public var bottom: AnchorRelatable {
        let anchorY = AnchorY(s: view.superview!.bottomAnchor, t: view.bottomAnchor)
        return relate(with: AnchorDescription(AnchorLayout(anchorY), attribute: .bottom))
    }
    
    /// widthAnchor.
    public var width: AnchorRelatable {
        let anchorDimension = AnchorDimension(s: view.superview!.widthAnchor, t: view.widthAnchor)
        return relate(with: AnchorDescription(AnchorLayout(anchorDimension), attribute: .width))
    }
    
    /// heightAnchor.
    public var height: AnchorRelatable {
        let anchorDimension = AnchorDimension(s: view.superview!.heightAnchor, t: view.heightAnchor)
        return relate(with: AnchorDescription(AnchorLayout(anchorDimension), attribute: .height))
    }
    
    /// centerXAnchor.
    public var centerX: AnchorRelatable {
        let anchorX = AnchorX(s: view.superview!.centerXAnchor, t: view.centerXAnchor)
        return relate(with: AnchorDescription(AnchorLayout(anchorX), attribute: .centerX))
    }
    
    /// centerYAnchor.
    public var centerY: AnchorRelatable {
        let anchorY = AnchorY(s: view.superview!.centerYAnchor, t: view.centerYAnchor)
        return relate(with: AnchorDescription(AnchorLayout(anchorY), attribute: .centerY))
    }
    
}

