//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Eddie Lee on 15/01/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var screenSize: CGSize
    
    init(size: CGSize, gameStats: GameStats) {
        screenSize = size
        
        super.init(size: screenSize)
        
        let previousHighScore = getHighScore()
        
        storeHighScore(gameStats.calculateScore())
        let currentHighScore = getHighScore()
        
        backgroundColor = SKColor.blackColor()
        
        let scoreLabel = SKLabelNode(fontNamed: "SanFrancisco")
        
        if (currentHighScore > previousHighScore) {
            scoreLabel.text = "New High Score: \(gameStats.calculateScore())!!"
        } else {
            scoreLabel.text = "Score: \(gameStats.calculateScore()) High Score: \(currentHighScore)"
        }
        
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 80)
        addChild(scoreLabel)
        
        let playAgainLabel = SKLabelNode(fontNamed: "SanFrancisco")
        playAgainLabel.text = "Tap to Play Again"
        playAgainLabel.fontSize = 50
        playAgainLabel.verticalAlignmentMode = .Center
        playAgainLabel.fontColor = SKColor.whiteColor()
        playAgainLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(playAgainLabel)
        
        let growAction = SKAction.scaleBy(1.2, duration: 0.4)
        let shrinkAction = SKAction.scaleBy(0.8333, duration: 0.4)
        let growAndShrink = SKAction.sequence([growAction, shrinkAction])
        playAgainLabel.runAction(SKAction.repeatActionForever(growAndShrink))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        runAction(SKAction.runBlock() {
            let reveal = SKTransition.doorwayWithDuration(0.5)
            let scene = GameScene(size: self.screenSize)
            self.view?.presentScene(scene, transition:reveal)
        })
    }
    
    func storeHighScore(score: Int) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if (score > getHighScore()) {
            defaults.setObject(score, forKey: "highScore")
            defaults.synchronize()
        }
    }
    
    func getHighScore() -> Int {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

        if let highScore = defaults.objectForKey("highScore") as? Int {
            return highScore
        }
        
        return 0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}