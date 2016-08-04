//
//  StartScene.swift
//  BugHunt
//
//  Created by Eddie Lee on 03/03/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {

    override func didMove(to view: SKView) {
        animateScene()
    }

    func animateScene() {
        animateSpider()
        animateBugs()
        animatePlayButton()
    }

    func animatePlayButton() {
        let growAndShrink = SKAction.sequence([
            SKAction.scale(by: 1.2, duration: 0.4),
            SKAction.scale(by: 0.8333, duration: 0.4)
        ])

        let playButton = childNode(withName: "play-button")
        playButton?.run(SKAction.repeatForever(growAndShrink))
    }

    func animateBugs() {
        enumerateChildNodes(withName: "fly") { (placeholderNode, _) -> Void in
            self.animateBug(BugType.fly, inPlaceOf: placeholderNode)
        }

        enumerateChildNodes(withName: "ladybird") { (placeholderNode, _) -> Void in
            self.animateBug(BugType.ladybird, inPlaceOf: placeholderNode)
        }

        enumerateChildNodes(withName: "wasp") { (placeholderNode, _) -> Void in
            self.animateBug(BugType.wasp, inPlaceOf: placeholderNode)
        }
    }

    func animateBug(_ bugType: BugType, inPlaceOf: SKNode) {
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

        var moveAction = SKAction.follow(movePath, asOffset: false, orientToPath: true, speed: bugType.speed())

        if bugType == BugType.ladybird {
            moveAction = moveAction.reversed()
        }

        bug.run(SKAction.repeatForever(moveAction))
    }

    func degToRad(_ deg: CGFloat) -> CGFloat {
        return CGFloat(deg * CGFloat(M_PI/180.0))
    }

    func animateSpider() {
        if let spider = childNode(withName: "spider") as? SKSpriteNode {
            spider.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.wait(forDuration: 1),
                SKAction.rotate(toAngle: degToRad(90), duration: 0.5),
                SKAction.wait(forDuration: 1),
                SKAction.rotate(toAngle: degToRad(300), duration: 0.5),
                SKAction.wait(forDuration: 1),
                SKAction.rotate(toAngle: degToRad(180), duration: 0.5),
                SKAction.wait(forDuration: 1),
                SKAction.rotate(toAngle: degToRad(240), duration: 0.5)
            ])))
        }
    }

    func getPath(_ position: CGPoint) -> CGPath {
        let pathWidth:CGFloat = 250
        let pathHeight:CGFloat = 250

        let rect = CGRect(x: (position.x - (pathWidth/2)), y: (position.y - (pathHeight/2)), width: pathWidth, height: pathHeight)
        let path = UIBezierPath(ovalIn: rect)
        return path.cgPath
    }

    func startNewGame() {
        let scene = GameScene()
        scene.size = self.size
        scene.scaleMode = self.scaleMode
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let touchLocation = touch.location(in: self)

        nodes(at: touchLocation).forEach { (node) -> () in
            if node.name == "play-button" {
                startNewGame()
            }
        }
    }
}
