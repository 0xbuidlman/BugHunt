//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Eddie Lee on 15/01/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    let scoreManager = ScoreManager.sharedInstance
    
    var newScore: Int!
    
    let growAndShrink = SKAction.sequence([
        SKAction.scaleBy(1.2, duration: 0.4),
        SKAction.scaleBy(0.8333, duration: 0.4)
    ])
    
    override func didMoveToView(view: SKView) {
        setGameOverState()
        showNewGameButton()
    }
    
    func setGameOverState() {
        backgroundColor = SKColor.blackColor()
        
        let currentHighScore = scoreManager.getLocalHighScore()
        
        scoreManager.recordNewScore(newScore)
        
        let scoreLabel = SKLabelNode()
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.horizontalAlignmentMode = .Center
        scoreLabel.fontSize = 30
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 60)
        addChild(scoreLabel)
        
        if newScore > currentHighScore {
            scoreLabel.text = "New High Score \(newScore)!!"
            let blinkAction = SKAction.sequence([
                SKAction.fadeAlphaTo(0.4, duration: 0.4),
                SKAction.fadeAlphaTo(1, duration: 0.4)
            ])
            scoreLabel.runAction(SKAction.repeatActionForever(blinkAction))
        } else {
            scoreLabel.text = "Score \(newScore)"
        }
    }
    
    func showNewGameButton() {
        runAction(SKAction.sequence([
            SKAction.waitForDuration(NSTimeInterval(0.3)),
            SKAction.runBlock({
                let playAgainLabel = SKLabelNode()
                playAgainLabel.fontColor = SKColor.whiteColor()
                playAgainLabel.text = "Tap to Play Again"
                playAgainLabel.fontSize = 35
                playAgainLabel.verticalAlignmentMode = .Center
                playAgainLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
                self.addChild(playAgainLabel)
                
                playAgainLabel.runAction(SKAction.repeatActionForever(self.growAndShrink))
            })
        ]))
    }
    
    func startNewGame() {
        let reveal = SKTransition.doorwayWithDuration(0.5)
        let scene = GameScene(size: self.size)
        self.view?.presentScene(scene, transition:reveal)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        runAction(SKAction.runBlock() {
            let reveal = SKTransition.doorwayWithDuration(0.5)
            let scene = GameScene(size: self.size)
            self.view?.presentScene(scene, transition:reveal)
        })
    }
}