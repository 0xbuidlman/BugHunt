//
//  BugType.swift
//  BugHunt
//
//  Created by Eddie Lee on 28/02/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import SpriteKit
import GameplayKit

enum BugType: Int {
    case ladybird, fly, wasp
    
    func typeName() -> String {
        switch self {
        case .ladybird:
            return "ladybird"
        case .fly:
            return "fly"
        case .wasp:
            return "wasp"
        }
    }
    
    func speed() -> CGFloat {
        switch self {
        case .ladybird:
            return 150
        case .fly:
            return 100
        case .wasp:
            return 200
        }
    }
    
    private static let _count: BugType.RawValue = {
        var maxValue: Int = 0
        while let _ = BugType(rawValue: maxValue) { maxValue += 1 }
        return maxValue
    }()
    
    static func random(_ randomSource: GKRandomSource) -> BugType {
        let random = GKRandomDistribution(randomSource: randomSource, lowestValue: 0, highestValue: _count - 1)
        let index = random.nextInt()
        return BugType(rawValue: index)!
    }
}
