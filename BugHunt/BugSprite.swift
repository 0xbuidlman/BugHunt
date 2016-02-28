//
//  BugSprite.swift
//  BugHunt
//
//  Created by Eddie Lee on 28/02/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import SpriteKit
import GameplayKit

class BugSprite: SKSpriteNode {
    
    var bugType: BugType!
    private var maxLives: Int!
    private var currentLives: Int! {
        didSet {
            if self.currentLives > 0 {
                self.updateHealthBar()
            } else {
                self.die()
            }
        }
    }
    
    private var healthBarNode: SKSpriteNode?
    
    convenience init(bugType: BugType, lives: Int) {
        self.init()
        
        self.bugType = bugType
        self.maxLives = lives
        self.currentLives = self.maxLives
        
        self.initialSetup()
    }
    
    private func initialSetup() {
        // Default texture
        let textureName = self.bugType.typeName()
        let defaultTexture = SKTexture(imageNamed: "\(textureName)-move-1")
        self.texture = defaultTexture
        self.size = defaultTexture.size()

        // Animation Sequence
        let animationSequence = SKAction.animateWithTextures([
            SKTexture(imageNamed: "\(textureName)-move-1"),
            SKTexture(imageNamed: "\(textureName)-move-2"),
            SKTexture(imageNamed: "\(textureName)-move-3"),
            SKTexture(imageNamed: "\(textureName)-move-4"),
            SKTexture(imageNamed: "\(textureName)-move-3"),
            SKTexture(imageNamed: "\(textureName)-move-2")
        ], timePerFrame: 0.1)
        
        self.runAction(SKAction.repeatActionForever(animationSequence), withKey: "animate")

        // Physics Body
        self.physicsBody = SKPhysicsBody(circleOfRadius: defaultTexture.size().height/2)
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Bug
        self.physicsBody?.collisionBitMask = PhysicsCategory.Bug
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Web
        
        let sizeModifier: CGFloat = CGFloat(self.maxLives) / 10.0
        self.setScale(1.0 + sizeModifier)
        
        if self.maxLives > 1 {
            updateHealthBar()
        }
    }
    
    private func updateHealthBar() {
        if let healthBarNode = self.healthBarNode {
            healthBarNode.texture = getHealthBarTexture()
        } else {
            let healthBarTexture = getHealthBarTexture()
            let healthBar = SKSpriteNode(texture: healthBarTexture)
            healthBar.position.y -= 20
            
            self.addChild(healthBar)
            
            self.healthBarNode = healthBar
        }
    }
    
    private func getHealthBarTexture() -> SKTexture {
        
        let healthBarRect = CGRect(x: 0, y: 0, width: 40, height: 4)
        
        // create drawing context
        UIGraphicsBeginImageContextWithOptions(healthBarRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Draw red background
        let backgroundColour = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha:1)
        CGContextSetFillColorWithColor(context, backgroundColour.CGColor)
        CGContextFillRect(context, healthBarRect)
        
        // Draw health bar outline
        let borderColor = UIColor(red: 35.0/255, green: 28.0/255, blue: 40.0/255, alpha:1)
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
        CGContextStrokeRectWithWidth(context, healthBarRect, 1)
        
        // Draw green for remaining health
        let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        let maxHealthWidth = healthBarRect.width - 1
        let healthwidth = (maxHealthWidth / CGFloat(self.maxLives)) * CGFloat(self.currentLives)
        let filledHealthBarRect = CGRect(x: 0.5 + (maxHealthWidth - healthwidth), y: 0.5, width: healthwidth, height: healthBarRect.height - 1)
        CGContextFillRect(context, filledHealthBarRect)
        
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: spriteImage)
    }
    
    func hit() {
        self.currentLives = self.currentLives - 1
    }
    
    private func die() {
        healthBarNode?.removeFromParent()
        
        self.removeActionForKey("animate")
        self.removeActionForKey("move")
        self.zPosition = Layer.DeadBug.rawValue
        self.texture = SKTexture(imageNamed: "\(self.bugType.typeName())-web")
        self.physicsBody = nil
        
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(3),
            SKAction.fadeAlphaTo(0, duration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
}