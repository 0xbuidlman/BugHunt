//
//  GameViewController.swift
//  SpriteKitSimpleGame
//
//  Created by Eddie Lee on 15/01/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let skView = self.view as? SKView {
            if skView.scene == nil {
                
                // Create the scene
                let scene = GameScene(size: view.bounds.size)
                
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.showsPhysics = true
                skView.ignoresSiblingOrder = true
                
                scene.scaleMode = .AspectFill
                
                skView.presentScene(scene)
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}