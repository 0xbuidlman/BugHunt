//
//  StartScene.swift
//  BugHunt
//
//  Created by Eddie Lee on 03/03/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {

    override func didMoveToView(view: SKView) {
        animateScene()
    }

    func animateScene() {
        animateSpider()
        animateBugs()
        animatePlayButton()
    }

    func animatePlayButton() {
        let growAndShrink = SKAction.sequence([
            SKAction.scaleBy(1.2, duration: 0.4),
            SKAction.scaleBy(0.8333, duration: 0.4)
        ])

        let playButton = childNodeWithName("play-button")
        playButton?.runAction(SKAction.repeatActionForever(growAndShrink))
    }

    func animateBugs() {
        enumerateChildNodesWithName("fly") { (placeholderNode, _) -> Void in
            self.animateBug(BugType.Fly, inPlaceOf: placeholderNode)
        }

        enumerateChildNodesWithName("ladybird") { (placeholderNode, _) -> Void in
            self.animateBug(BugType.Ladybird, inPlaceOf: placeholderNode)
        }

        enumerateChildNodesWithName("wasp") { (placeholderNode, _) -> Void in
            self.animateBug(BugType.Wasp, inPlaceOf: placeholderNode)
        }
    }

    func animateBug(bugType: BugType, inPlaceOf: SKNode) {
        let bug = BugSprite(bugType: bugType, lives: 1)
        bug.position = inPlaceOf.position
        bug.zRotation = inPlaceOf.zRotation
        bug.zPosition = inPlaceOf.zPosition
        self.addChild(bug)
        inPlaceOf.removeFromParent()

        let movePath = self.getPath(bug.position)

//        let drawPath = SKShapeNode(path: movePath)
//        drawPath.strokeColor = SKColor.redColor()
//        self.addChild(drawPath)

        var moveAction = SKAction.followPath(movePath, asOffset: false, orientToPath: true, speed: bugType.speed())

        if bugType == BugType.Ladybird {
            moveAction = moveAction.reversedAction()
        }

        bug.runAction(SKAction.repeatActionForever(moveAction))
    }

    func degToRad(deg: CGFloat) -> CGFloat {
        return CGFloat(deg * CGFloat(M_PI/180.0))
    }

    func animateSpider() {
        if let spider = childNodeWithName("spider") as? SKSpriteNode {
            spider.runAction(SKAction.repeatActionForever(SKAction.sequence([
                SKAction.waitForDuration(1),
                SKAction.rotateToAngle(degToRad(90), duration: 0.5),
                SKAction.waitForDuration(1),
                SKAction.rotateToAngle(degToRad(300), duration: 0.5),
                SKAction.waitForDuration(1),
                SKAction.rotateToAngle(degToRad(180), duration: 0.5),
                SKAction.waitForDuration(1),
                SKAction.rotateToAngle(degToRad(240), duration: 0.5)
            ])))
        }
    }

    func getPath(position: CGPoint) -> CGPath {
        let pathWidth:CGFloat = 250
        let pathHeight:CGFloat = 250

        let rect = CGRect(x: (position.x - (pathWidth/2)), y: (position.y - (pathHeight/2)), width: pathWidth, height: pathHeight)
        let path = UIBezierPath(ovalInRect: rect)
        return path.CGPath
    }

    func startNewGame() {
        let scene = GameScene()
        scene.size = self.size
        scene.scaleMode = self.scaleMode
        self.view?.presentScene(scene, transition: SKTransition.fadeWithDuration(0.5))
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let touchLocation = touch.locationInNode(self)

        nodesAtPoint(touchLocation).forEach { (node) -> () in
            if node.name == "play-button" {
                startNewGame()
            }
        }
    }
}