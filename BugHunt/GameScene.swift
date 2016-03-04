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
    static let None:    UInt32 = 0
    static let Spider:  UInt32 = 0b1
    static let Bug:     UInt32 = 0b10
    static let Web:     UInt32 = 0b100    
}

enum Layer: CGFloat {
    case Background
    case BackgroundDetail
    case DeadBug
    case Web
    case Player
    case Bug
    case HudBackground
    case Hud
}

struct GameStats {
    var bugsKilled = 0    
    var shotsFired = 0
    
    let pointPerKill = 5;
    let pointsPerShot = -1
    
    func calculateScore() -> Int64 {
        var score: Int64 = 0
        
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
    var levelLabel: SKLabelNode!
    
    var gameStats = GameStats()

    var pathSegmentsRandom = GKRandomDistribution(lowestValue: 3, highestValue: 5)
    var arcRandom = GKRandomDistribution(lowestValue: -100, highestValue: 100)
    var bugPositionRandom = GKRandomDistribution(lowestValue: 0, highestValue: 100)
    var bugTypeRandomSource = GKRandomSource()
    
    var lifeSprites = [SKSpriteNode]()
    let MaxNumberOfLives = 3
    var currentNumberOfLives = 0
    
    let hudBackgroundHeight: CGFloat = 30
    
    var isPlaying: Bool = false
    var lastUpdateTime: NSTimeInterval = 0
    
    var timeBetweenBugs: NSTimeInterval = 0
    var timeSinceLastBug: NSTimeInterval = 0

    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        setupLayout()
        startGame()
    }
    
    
    
    // MARK: Setup
    
    func setupLayout() {
        addBackground()
        addBackgroundDetail()
        addPlayer()
        addHud()
    }
    
    func addBackground() {
        let backgroundNode = SKNode()
        
        let grassSprite = SKSpriteNode(imageNamed: "grass")
        grassSprite.anchorPoint = CGPoint.zero
        grassSprite.zPosition = Layer.Background.rawValue
                
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
    
    func addBackgroundDetail() {
        let xPositionRandom = GKShuffledDistribution(lowestValue: 0, highestValue: Int(size.width))
        let yPositionRandom = GKShuffledDistribution(lowestValue: 0, highestValue: Int(size.height))
        
        for _ in 1...20 {
            let flower = SKSpriteNode(imageNamed: "flower")
            flower.zPosition = Layer.BackgroundDetail.rawValue
            flower.position = CGPoint(x: xPositionRandom.nextInt(), y: yPositionRandom.nextInt())
            addChild(flower)
            
            let daisy = SKSpriteNode(imageNamed: "daisy")
            daisy.zPosition = Layer.BackgroundDetail.rawValue
            daisy.position = CGPoint(x: xPositionRandom.nextInt(), y: yPositionRandom.nextInt())
            addChild(daisy)
        }
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "spider")
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.anchorPoint = CGPoint(x: 0.5, y: 0.375)
        player.zPosition = Layer.Player.rawValue
        player.zRotation = degToRad(-90)

        addChild(player)
    }
    
    func addHud() {
        addHudBackground()
        addScoreLabel()
        addLevelLabel()
        addLivesNode()
    }
    
    func addHudBackground() {
        let hudBackground = SKShapeNode(rectOfSize: CGSize(width: size.width, height: hudBackgroundHeight))
        hudBackground.position = CGPoint(x: size.width/2, y: size.height - (hudBackgroundHeight / 2))
        hudBackground.lineWidth = 0
        hudBackground.fillColor = SKColor(red: 79/255, green: 59/255, blue: 39/255, alpha: 0.95)
        hudBackground.zPosition = Layer.HudBackground.rawValue
        
        addChild(hudBackground)
    }

    func addScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Light")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: 10, y: size.height - 23)
        scoreLabel.zPosition = Layer.Hud.rawValue
        addChild(scoreLabel)
    }

    func addLevelLabel() {
        levelLabel = SKLabelNode(fontNamed: "ChalkboardSE-Light")
        levelLabel.text = "Level: 1"
        levelLabel.fontSize = 20
        levelLabel.fontColor = SKColor.whiteColor()
        levelLabel.position = CGPoint(x: size.width/2, y: size.height - 23)
        levelLabel.zPosition = Layer.Hud.rawValue
        addChild(levelLabel)
    }
    
    func addLivesNode() {
        let livesLayer = SKNode()
        livesLayer.zPosition = Layer.Hud.rawValue
        
        for lifeNumber in 1...MaxNumberOfLives {
            let lifeSprite = SKSpriteNode(imageNamed: "heart")
            
            let xPosition = size.width - ((lifeSprite.size.width + 5) * CGFloat(lifeNumber))
            let yPosition = size.height - (lifeSprite.size.height / 2)
            lifeSprite.position = CGPoint(x: xPosition, y: yPosition)
            
            lifeSprite.runAction(SKAction.repeatActionForever(SKAction.sequence([
                SKAction.scaleTo(0.8, duration: 0.5),
                SKAction.scaleTo(1.0, duration: 0.5)
            ])), withKey: "animate")
            
            lifeSprites.append(lifeSprite)
            
            livesLayer.addChild(lifeSprite)
        }
        
        lifeSprites = lifeSprites.reverse()
        
        addChild(livesLayer)
    }
    
    
    
    // MARK: Game life cycle
    
    func startGame() {
        currentNumberOfLives = MaxNumberOfLives
        isPlaying = true
        timeBetweenBugs = 2
    }
    
    func bugDidReachTarget() {
        currentNumberOfLives--;
        
        if currentNumberOfLives < 1 {
            self.gameOver()
        } else {
            updateRemainingLives()
        }
    }
    
    func gameOver() {
        // Stop new bugs from spawning
        isPlaying = false
        //self.removeActionForKey("spawn")
        
        // Transition to Game Over Scene
        let gameOverScene = GameOverScene(size: self.size)
        gameOverScene.newScore = gameStats.calculateScore()
        let transition = SKTransition.fadeWithColor(UIColor.blackColor(), duration: 0.5)
        self.view?.presentScene(gameOverScene, transition: transition)
    }
    
    func updateScore() {
        scoreLabel.text = "Score: \(gameStats.calculateScore())"
    }
    
    func updateRemainingLives() {
        for (index, lifeSprite) in lifeSprites.enumerate() {
            let lifeNumber = index + 1
            
            if lifeNumber > currentNumberOfLives {
                lifeSprite.texture = SKTexture(imageNamed: "heart-dead")
                lifeSprite.removeActionForKey("animate")
                lifeSprite.setScale(0.8)
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        let deltaTime = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime
        
        if !isPlaying {
            return;
        }
        
        timeSinceLastBug += deltaTime
        
        if timeSinceLastBug > timeBetweenBugs {
            addNextBug()
            timeSinceLastBug -= timeBetweenBugs
        }
    }
    
    
    // MARK: Game actions
    
    var bugsAdded:Int = 0
    
    func addNextBug() {
        var bugType: BugType!
        
        var lives: Int = 1
        switch bugsAdded / 10 {
        case let x where x < 1:
            lives = 1
            bugType = BugType.Fly
        case let x where x < 2:
            lives = 2
            bugType = BugType.Ladybird
        case let x where x < 3:
            lives = 3
            bugType = BugType.Wasp
        default:
            lives = 4
            bugType = BugType.random(bugTypeRandomSource)
        }
        
        let yLocationPercentage = bugPositionRandom.nextInt()
        addBug(bugType, yLocationPercentage: CGFloat(yLocationPercentage), lives: lives)
    }
    
    func getScreenYPosition(yLocationPercentage: CGFloat) -> CGFloat {
        let screenPadding:CGFloat = 25
        let minValue:CGFloat = screenPadding
        let maxValue:CGFloat = size.height - screenPadding - hudBackgroundHeight
        
        let yPosition = yLocationPercentage * (maxValue - minValue) / 100.0 + minValue
        
        return yPosition
    }
    
    func addBug(bugType: BugType, yLocationPercentage: CGFloat, lives: Int) {
        let bug = BugSprite(bugType: bugType, lives: lives)
        bug.zPosition = Layer.Bug.rawValue
        
        let yPosition = getScreenYPosition(yLocationPercentage)
        let startPosition = CGPoint(x: size.width + bug.size.width / 2, y: yPosition)
        let endPosition = CGPoint(x: -bug.size.width / 2, y: yPosition)
        bug.position = startPosition

        let movePath = getPath(startPosition, toPoint: endPosition)
        
        let drawPath = SKShapeNode(path: movePath)
        drawPath.zPosition = Layer.Hud.rawValue
        drawPath.strokeColor = SKColor.redColor()
        self.addChild(drawPath)
        
        bug.runAction(SKAction.sequence([
            SKAction.followPath(movePath, asOffset: false, orientToPath: true, speed: bugType.speed()),
            SKAction.runBlock({
                //self.bugDidReachTarget()
                drawPath.removeFromParent()
            }),
            SKAction.removeFromParent()
        ]), withKey: "move")
        
        addChild(bug)
        
        bugsAdded++
    }
    
    func getPath(fromPoint: CGPoint, toPoint: CGPoint) -> CGPath {
        
        let screenPadding:CGFloat = 25
        let minValue:CGFloat = screenPadding
        let maxValue:CGFloat = size.height - screenPadding - hudBackgroundHeight
        
        
        let path = UIBezierPath()
        path.lineJoinStyle = .Bevel
        
        path.moveToPoint(fromPoint)
        
        let pathWidth = fromPoint.x - toPoint.x
        
        let numberOfPoints: Int = pathSegmentsRandom.nextInt()
        let distancePerPoint: CGFloat = pathWidth / CGFloat(numberOfPoints)
        
        for i in 1...numberOfPoints {
            let pointOffset = CGFloat(arcRandom.nextInt())
            var stopPoint: CGPoint = CGPoint(x: fromPoint.x - (distancePerPoint * CGFloat(i)), y: fromPoint.y + pointOffset)
            
            if stopPoint.y < minValue {
                stopPoint.y = minValue
            } else if stopPoint.y > maxValue {
                stopPoint.y = maxValue
            }
            
            //let controlPoint = CGPoint(x: stopPoint.x, y: stopPoint.y + curveOffset)
            //path.addQuadCurveToPoint(stopPoint, controlPoint: controlPoint)
            
            path.addLineToPoint(stopPoint)
        }
        
        
        
        return path.CGPath
    }
    
    func shootWebAtPoint(point: CGPoint) {
        gameStats.shotsFired++
        updateScore()
        
        
        let web = SKSpriteNode(imageNamed: "web-shoot")
        web.position = player.position
        
        web.physicsBody = SKPhysicsBody(circleOfRadius: web.size.height/2)
        web.physicsBody?.dynamic = false
        web.physicsBody?.categoryBitMask = PhysicsCategory.Web
        web.physicsBody?.contactTestBitMask = PhysicsCategory.Bug
        
        web.zPosition = Layer.Web.rawValue
        web.setScale(0)
        
        let webDestination = getTargetDestination(web.position, destinationPoint: point)
        
        web.constraints = [SKConstraint.orientToPoint(webDestination, offset: SKRange(constantValue: 0))]
        
        let animateWebAction = SKAction.scaleTo(1, duration: 0.1)
        let moveWebAction = SKAction.sequence([
            SKAction.moveTo(webDestination, duration: 2.0),
            SKAction.removeFromParent()
        ])
        
        web.runAction(SKAction.group([
            animateWebAction,
            moveWebAction
        ]))
        
        addChild(web)
    }
    
    func webDidCollideWithBug(web: SKSpriteNode, bug: BugSprite) {
        gameStats.bugsKilled++
        updateScore()
        
        web.removeFromParent()
        
        bug.hit()
    }

    func degToRad(deg: CGFloat) -> CGFloat {
        return CGFloat(deg * CGFloat(M_PI/180.0))
    }
    
    
    // MARK: Player input
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        player.constraints = [SKConstraint.orientToPoint(touchLocation, offset: SKRange(constantValue: degToRad(-90)))]
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        player.constraints = [SKConstraint.orientToPoint(touchLocation, offset: SKRange(constantValue: degToRad(-90)))]
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        player.constraints = [SKConstraint.orientToPoint(touchLocation, offset: SKRange(constantValue: degToRad(-90)))]
        shootWebAtPoint(touchLocation)
    }

    func didBeginContact(contact: SKPhysicsContact) {
        guard let web  = get(PhysicsCategory.Web, fromContact: contact) else {
            return
        }
        
        guard let bug = get(PhysicsCategory.Bug, fromContact: contact) else {
            return
        }
        
        if let bugSprite = bug as? BugSprite {
            webDidCollideWithBug(web, bug: bugSprite)
        }
    }
    
    
    
    // MARK: Helper methods
    
    func get(type: UInt32, fromContact: SKPhysicsContact) -> SKSpriteNode? {
        if fromContact.bodyA.categoryBitMask == type {
            return getSpriteNode(fromContact.bodyA)
        }
        if fromContact.bodyB.categoryBitMask == type {
            return getSpriteNode(fromContact.bodyB)
        }
        
        return nil
    }
    
    func getSpriteNode(physicsBody: SKPhysicsBody) -> SKSpriteNode? {
        if let spriteNode = physicsBody.node as? SKSpriteNode {
            return spriteNode
        }
        
        return nil
    }
    
    func getTargetDestination(startPoint: CGPoint, destinationPoint: CGPoint) -> CGPoint {
        let pointOffset = destinationPoint - startPoint
        let shootDirection = pointOffset.normalized()
        let shootDistance = shootDirection * 1000
        let destination = shootDistance + startPoint
        
        return destination
    }
}