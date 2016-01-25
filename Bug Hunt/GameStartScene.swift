//
//  GameStartScreen.swift
//  SpriteKitSimpleGame
//
//  Created by Eddie Lee on 15/01/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import SpriteKit

class GameStartScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        let startLabel = SKLabelNode(fontNamed: "SanFrancisco")
        startLabel.text = "Tap to Start"
        startLabel.fontSize = 50
        startLabel.verticalAlignmentMode = .Center
        startLabel.fontColor = SKColor.whiteColor()
        startLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(startLabel)
        

        startLabel.runAction(SKAction.repeatActionForever(SKAction(named: "Pulsate")!))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        runAction(SKAction.runBlock() {
            let reveal = SKTransition.doorwayWithDuration(0.5)
            let scene = GameScene(size: self.size)
            self.view?.presentScene(scene, transition:reveal)
        })
    }
}