//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Eddie Lee on 15/01/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let Spider:  UInt32 = 0
    static let Bug:     UInt32 = 0b1
    static let Web:     UInt32 = 0b10
    static let None:    UInt32 = UInt32.max
}

struct GameStats {
    var bugsKilled = 0
    var shotsFired = 0
    
    let pointPerKill = 5;
    let pointsPerShot = -1
    
    func calculateScore() -> Int {
        var score = 0
        
        score += bugsKilled * pointPerKill
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

    var obstacleGraph: GKObstacleGraph!

    let bugSpeedRandom = GKRandomDistribution(lowestValue: 3, highestValue: 5)
    var bugPositionRandom: GKRandomDistribution!


    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self

        print(size)

        let screenPadding = 25
        bugPositionRandom = GKRandomDistribution(lowestValue: 0 + screenPadding, highestValue: Int(size.height) - screenPadding)
        
        setupLayout()

        obstacleGraph = GKObstacleGraph()

        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addBug),
                SKAction.waitForDuration(1)
            ])
        ), withKey: "spawn")
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
        player.zPosition = 10

        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
        player.physicsBody?.categoryBitMask = PhysicsCategory.Spider
        player.physicsBody?.contactTestBitMask = PhysicsCategory.None
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.dynamic = false
        player.physicsBody?.pinned = true

        addChild(player)
    }

    func addScoreLabel() {
        scoreLabel = SKLabelNode()
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPoint(x: 10, y: size.height - 35)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
    }

    func addBug() {
        var bugSprite: SKSpriteNode!

        let selectedSpeed = bugSpeedRandom.nextInt()

        var frames: [SKTexture]!

        if selectedSpeed == 3 {
            bugSprite = SKSpriteNode(imageNamed: "wasp-move-1")
            bugSprite.name = "wasp"
            frames = [
                SKTexture(imageNamed: "wasp-move-1"),
                SKTexture(imageNamed: "wasp-move-2"),
                SKTexture(imageNamed: "wasp-move-3"),
                SKTexture(imageNamed: "wasp-move-4"),
                SKTexture(imageNamed: "wasp-move-3"),
                SKTexture(imageNamed: "wasp-move-2")
            ]
        }

        if selectedSpeed == 4 {
            bugSprite = SKSpriteNode(imageNamed: "fly-move-1")
            bugSprite.name = "fly"
            frames = [
                SKTexture(imageNamed: "fly-move-1"),
                SKTexture(imageNamed: "fly-move-2"),
                SKTexture(imageNamed: "fly-move-3"),
                SKTexture(imageNamed: "fly-move-4"),
                SKTexture(imageNamed: "fly-move-3"),
                SKTexture(imageNamed: "fly-move-2")
            ]
        }

        if selectedSpeed == 5 {
            bugSprite = SKSpriteNode(imageNamed: "ladybird-move-1")
            bugSprite.name = "ladybird"
            frames = [
                SKTexture(imageNamed: "ladybird-move-1"),
                SKTexture(imageNamed: "ladybird-move-2"),
                SKTexture(imageNamed: "ladybird-move-3"),
                SKTexture(imageNamed: "ladybird-move-4"),
                SKTexture(imageNamed: "ladybird-move-3"),
                SKTexture(imageNamed: "ladybird-move-2")
            ]
        }

        bugSprite.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(frames, timePerFrame: 0.1)), withKey: "animate")

        bugSprite.zPosition = 20

        // Physics
        bugSprite.physicsBody = SKPhysicsBody(rectangleOfSize: bugSprite.size)
        bugSprite.physicsBody?.dynamic = true
        bugSprite.physicsBody?.categoryBitMask = PhysicsCategory.Bug
        bugSprite.physicsBody?.contactTestBitMask = PhysicsCategory.Web


        // Position
        let yPosition = CGFloat(bugPositionRandom.nextInt())

        let startXPosition = size.width + bugSprite.size.width / 2;
        let startPosition = CGPoint(x: startXPosition, y: yPosition)

        let endXPosition = 0 - bugSprite.size.width / 2
        let endPosition = CGPoint(x: endXPosition, y: yPosition)



        bugSprite.position = CGPoint(x: startXPosition, y: yPosition)


        bugSprite.constraints = [SKConstraint.orientToPoint(endPosition, offset: SKRange(constantValue: 0))]

        let startNode = GKGraphNode2D(point: float2(Float(startPosition.x), Float(startPosition.y)))
        let endNode = GKGraphNode2D(point: float2(Float(endPosition.x), Float(endPosition.y)))
        
        obstacleGraph.connectNodeUsingObstacles(startNode)
        obstacleGraph.connectNodeUsingObstacles(endNode)

        let path:[GKGraphNode] = obstacleGraph.findPathFromNode(startNode, toNode: endNode)

        // create an array of actions for player movement
        var actions = [SKAction]()

        let transitionsInPath = path.count - 1

        for node:GKGraphNode in path {
            if let point2d = node as? GKGraphNode2D {
                let point = CGPoint(x: CGFloat(point2d.position.x), y: CGFloat(point2d.position.y))
                let action = SKAction.moveTo(point, duration: Double(selectedSpeed / transitionsInPath))
                actions.append(action)
            }
        }

        actions.append(SKAction.runBlock({
            self.obstacleGraph.removeNodes([startNode, endNode])
            bugSprite.removeFromParent()

            //self.removeActionForKey("spawn")
            //self.gameOver()
        }))

        bugSprite.runAction(SKAction.sequence(actions), withKey: "move")
        addChild(bugSprite)
    }
    
//    func gameOver() {
//        let transition = SKTransition.fadeWithColor(UIColor.blackColor(), duration: 0.5)
//        let gameOverScene = GameOverScene(size: self.size)
//        gameOverScene.gameScore = gameStats.calculateScore()
//        self.view?.presentScene(gameOverScene, transition: transition)
//    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)

        facePlayerToPoint(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)

        facePlayerToPoint(touchLocation)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)

        facePlayerToPoint(touchLocation)
        shootWebAtPoint(touchLocation)
    }

    func facePlayerToPoint(point: CGPoint) {
        let rotateConstraint = SKConstraint.orientToPoint(point, offset: SKRange(constantValue: 0))
        player.constraints = [rotateConstraint]
    }
    
    func shootWebAtPoint(point: CGPoint) {
        let web = SKSpriteNode(imageNamed: "web-shoot")
        web.position = player.position
        web.physicsBody = SKPhysicsBody(rectangleOfSize: web.size)
        web.physicsBody?.dynamic = false
        web.physicsBody?.categoryBitMask = PhysicsCategory.Web
        web.physicsBody?.contactTestBitMask = PhysicsCategory.Bug
        web.physicsBody?.usesPreciseCollisionDetection = true
        web.zPosition = 5
        web.setScale(0)
        web.runAction(SKAction.sequence([
            SKAction.runBlock({
                let rotateConstraint = SKConstraint.orientToPoint(point, offset: SKRange(constantValue: 0))
                web.constraints = [rotateConstraint]
            }),
            SKAction.waitForDuration(0.01),
            SKAction.runBlock({
                web.constraints = []
            }),
            SKAction.scaleTo(1, duration: 0.1),
            SKAction.runBlock({
                web.zPosition = 30
            })
        ]))
        
        addChild(web)
        
        gameStats.shotsFired++
        updateScore()

        let touchOffset = point - player.position
        let shootDirection = touchOffset.normalized()
        let shootDistance = shootDirection * 1000
        let destination = shootDistance + web.position
        
        let actionMove = SKAction.moveTo(destination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        web.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func updateScore() {
        scoreLabel.text = "Score: \(gameStats.calculateScore())"
    }

    func didBeginContact(contact: SKPhysicsContact) {
        if let web  = get(PhysicsCategory.Web, fromContact: contact) {
            web.removeFromParent()
        }

        if let bug = get(PhysicsCategory.Bug, fromContact: contact) {

            gameStats.bugsKilled++
            updateScore()

            bug.removeActionForKey("animate")
            bug.removeActionForKey("move")
            bug.zPosition = 15
            bug.texture = SKTexture(imageNamed: "\(bug.name!)-web")
            bug.physicsBody = nil

            bug.runAction(SKAction.sequence([
                SKAction.waitForDuration(4),
                SKAction.fadeAlphaTo(0, duration: 1),
                SKAction.runBlock({
                    bug.removeFromParent()
                })
            ]))
        }
    }

    func get(type: UInt32, fromContact: SKPhysicsContact) -> SKSpriteNode? {
        if fromContact.bodyA.categoryBitMask == type {
            return getSprideNode(fromContact.bodyA)
        }
        if fromContact.bodyB.categoryBitMask == type {
            return getSprideNode(fromContact.bodyB)
        }

        return nil
    }

    func getSprideNode(physicsBody: SKPhysicsBody) -> SKSpriteNode? {
        if let spriteNode = physicsBody.node as? SKSpriteNode {
            return spriteNode
        }

        return nil
    }
}