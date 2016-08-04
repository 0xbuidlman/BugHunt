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
    
    var newScore: Int64!
    
    let growAndShrink = SKAction.sequence([
        SKAction.scale(by: 1.2, duration: 0.4),
        SKAction.scale(by: 0.8333, duration: 0.4)
    ])
    
    override func didMove(to view: SKView) {
        setGameOverState()
        showNewGameButton()
    }
    
    func setGameOverState() {
        backgroundColor = SKColor.black()
        
        let currentHighScore = scoreManager.getHighScore()
        
        scoreManager.recordNewScore(newScore)
        
        let scoreLabel = SKLabelNode()
        scoreLabel.fontColor = SKColor.white()
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.fontSize = 30
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 60)
        addChild(scoreLabel)
        
        if newScore > currentHighScore {
            scoreLabel.text = "New High Score \(newScore)!!"
            let blinkAction = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.4),
                SKAction.fadeAlpha(to: 1, duration: 0.4)
            ])
            scoreLabel.run(SKAction.repeatForever(blinkAction))
        } else {
            scoreLabel.text = "Score \(newScore). High Score is:  \(currentHighScore)"
        }
    }
    
    func showNewGameButton() {
        run(SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval(0.3)),
            SKAction.run({
                let playAgainLabel = SKLabelNode()
                playAgainLabel.fontColor = SKColor.white()
                playAgainLabel.text = "Tap to Play Again"
                playAgainLabel.fontSize = 35
                playAgainLabel.verticalAlignmentMode = .center
                playAgainLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
                self.addChild(playAgainLabel)
                
                playAgainLabel.run(SKAction.repeatForever(self.growAndShrink))
            })
        ]))
    }
    
    func startNewGame() {
        let reveal = SKTransition.doorway(withDuration: 0.5)
        let scene = GameScene(size: self.size)
        self.view?.presentScene(scene, transition:reveal)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.run() {
            let reveal = SKTransition.doorway(withDuration: 0.5)
            let scene = GameScene(size: self.size)
            self.view?.presentScene(scene, transition:reveal)
        })
    }
}
