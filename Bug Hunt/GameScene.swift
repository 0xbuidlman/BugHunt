//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Eddie Lee on 15/01/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import SpriteKit
import GameplayKit

struct SpriteType {
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Monster: UInt32 = 1
    static let Projectile: UInt32 = 2
}

enum MonsterType: UInt32 {
    case Slow
    case Medium
    case Fast
    
    private static let _count: MonsterType.RawValue = {
        var maxValue: UInt32 = 0
        while let _ = MonsterType(rawValue: ++maxValue) { }
        return maxValue
    }()
    
    static func randomType() -> MonsterType {
        let rand = arc4random_uniform(_count)
        return MonsterType(rawValue: rand)!
    }
}

struct GameStats {
    var monstersKilled = 0
    var shotsFired = 0
    
    let pointPerKill = 5;
    let pointsPerShot = -1
    
    func calculateScore() -> Int {
        var score = 0
        
        score += monstersKilled * pointPerKill
        score += shotsFired * pointsPerShot
        
        if (score < 0) {
            score = 0
        }
        
        return score
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var gameStats = GameStats()
    
    
    
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        
        setupLayout()
        
//        runAction(SKAction.repeatActionForever(
//            SKAction.sequence([
//                SKAction.runBlock(addMonster),
//                SKAction.waitForDuration(1)
//            ])
//        ))
    }
    
    func setupLayout() {
        addBackground()
        addPlayer()
        addScoreLabel()
    }
    
    func addBackground() {
        let backgroundNode = SKNode()
        
        let grassSprite = SKSpriteNode(imageNamed: "grass")
        grassSprite.anchorPoint = CGPoint.zero
        grassSprite.zPosition = 0
                
        let xBlocks = Int(size.width / grassSprite.size.width)
        let yBlocks = Int(size.height / grassSprite.size.height)
        
        for xBlock in 0...xBlocks {
            for yBlock in 0...yBlocks {
                let tileNode = grassSprite.copy() as! SKSpriteNode
                let xPos = grassSprite.size.width * CGFloat(xBlock)
                let yPos = grassSprite.size.height * CGFloat(yBlock)
                tileNode.position = CGPoint(x: xPos, y: yPos)
                backgroundNode.addChild(tileNode)
            }
        }
        
        addChild(backgroundNode)
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "spider")
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.anchorPoint = CGPoint(x: 0.34, y: 0.5)
        player.zPosition = 5
        addChild(player)
    }
    
    func addScoreLabel() {
        scoreLabel = SKLabelNode()
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPoint(x: 10, y: size.height - 35)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
    }
    
    func addMonster() {
        let bugSprite: SKSpriteNode
        let bugTimeToRun: CGFloat
        
        // Pick a bug type
        switch MonsterType.randomType() {
        case .Fast:
            bugSprite = SKSpriteNode(imageNamed: "Wasp")
            bugTimeToRun = 2
        case .Medium:
            bugSprite = SKSpriteNode(imageNamed: "Fly")
            bugTimeToRun = 3
        case .Slow:
            bugSprite = SKSpriteNode(imageNamed: "LadyBird")
            bugTimeToRun = 4
        }
        
        // Physics
        bugSprite.physicsBody = SKPhysicsBody(rectangleOfSize: bugSprite.size)
        bugSprite.physicsBody?.dynamic = true
        bugSprite.physicsBody?.categoryBitMask = SpriteType.Monster
        bugSprite.physicsBody?.contactTestBitMask = SpriteType.Projectile
        bugSprite.physicsBody?.collisionBitMask = SpriteType.None
        
        // Position
        let yPosition = random(min: bugSprite.size.height/2, max: size.height - bugSprite.size.height/2)
        let startXPosition = size.width + bugSprite.size.width / 2;
        let endXPosition = 0 - bugSprite.size.width / 2
        bugSprite.position = CGPoint(x: startXPosition, y: yPosition)
        bugSprite.zPosition = 5
        
        // Add and animate
        addChild(bugSprite)
        bugSprite.runAction(SKAction.sequence([
            SKAction.moveTo(CGPoint(x: endXPosition, y: yPosition), duration: NSTimeInterval(bugTimeToRun)),
            SKAction.runBlock() { self.gameOver() }
        ]))
    }
    
    func gameOver() {
        let transition = SKTransition.fadeWithColor(UIColor.blackColor(), duration: 0.5)
        let gameOverScene = GameOverScene(size: self.size)
        gameOverScene.gameScore = gameStats.calculateScore()
        self.view?.presentScene(gameOverScene, transition: transition)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        
        let rotateConstraint = SKConstraint.orientToPoint(touchLocation, offset: SKRange(constantValue: 0))
        player.constraints = [rotateConstraint]
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        
        let rotateConstraint = SKConstraint.orientToPoint(touchLocation, offset: SKRange(constantValue: 0))
        player.constraints = [rotateConstraint]
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        let touchOffset = touchLocation - player.position
        
        let rotateConstraint = SKConstraint.orientToPoint(touchLocation, offset: SKRange(constantValue: 0))
        player.constraints = [rotateConstraint]
        
        let projectile = SKSpriteNode(imageNamed: "web-shoot")
        projectile.position = player.position
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = SpriteType.Projectile
        projectile.physicsBody?.contactTestBitMask = SpriteType.Monster
        projectile.physicsBody?.collisionBitMask = SpriteType.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        projectile.zPosition = 4
        projectile.setScale(0)
        projectile.runAction(SKAction.sequence([
            SKAction.runBlock({
                projectile.constraints = [rotateConstraint]
            }),
            SKAction.waitForDuration(0.01),
            SKAction.runBlock({
                projectile.constraints = []
            }),
            SKAction.scaleTo(1, duration: 0.1)
        ]))
        
        addChild(projectile)
        
        gameStats.shotsFired++
        updateScore()
        
        let shootDirection = touchOffset.normalized()
        let shootDistance = shootDirection * 1000
        let projectileDestination = shootDistance + projectile.position
        
        let actionMove = SKAction.moveTo(projectileDestination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        projectile.removeFromParent()
        monster.removeFromParent()
        
        gameStats.monstersKilled++
        updateScore()
    }
    
    func updateScore() {
        scoreLabel.text = "Score: \(gameStats.calculateScore())"
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & SpriteType.Monster != 0) &&
            (secondBody.categoryBitMask & SpriteType.Projectile != 0)) {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}