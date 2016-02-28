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
    case Ladybird, Fly, Wasp
    
    func typeName() -> String {
        switch self {
        case .Ladybird:
            return "ladybird"
        case .Fly:
            return "fly"
        case .Wasp:
            return "wasp"
        }
    }
    
    func speed() -> Double {
        switch self {
        case .Ladybird:
            return 5
        case .Fly:
            return 4
        case .Wasp:
            return 3
        }
    }
    
    private static let _count: BugType.RawValue = {
        var maxValue: Int = 0
        while let _ = BugType(rawValue: ++maxValue) { }
        return maxValue
    }()
    
    static func random(randomSource: GKRandomSource) -> BugType {
        let random = GKRandomDistribution(randomSource: randomSource, lowestValue: 0, highestValue: _count - 1)
        let index = random.nextInt()
        return BugType(rawValue: index)!
    }
}
