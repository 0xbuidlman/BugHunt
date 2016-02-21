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
    
    let sceneFixedHeight:CGFloat = 375
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let skView = self.view as? SKView {
            if skView.scene == nil {
                
                // Create the scene
                let screenAspectRatio = skView.bounds.size.width / skView.bounds.size.height
                let sceneSize = CGSize(width: sceneFixedHeight * screenAspectRatio, height: sceneFixedHeight)
//                let sceneAspectRatio = sceneSize.width / sceneSize.height
                
//                print("Screen Size: \(skView.bounds.size)")
//                print("Screen Aspect Ratio: \(screenAspectRatio)")
//                print("Scene Size: \(sceneSize)")
//                print("Scene Aspect Ratio: \(sceneAspectRatio)")
                
                let scene = GameScene(size: sceneSize)
                
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.showsPhysics = true
                skView.ignoresSiblingOrder = true
                
                scene.scaleMode = .AspectFit
                
                skView.presentScene(scene)
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}