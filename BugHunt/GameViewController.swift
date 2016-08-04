//
//  GameViewController.swift
//  SpriteKitSimpleGame
//
//  Created by Eddie Lee on 15/01/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, ScoreManagerFocusDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView = self.view as? SKView {
            
            ScoreManager.sharedInstance.focusDelegate = self
            ScoreManager.sharedInstance.authenticateLocalPlayer(self)
            
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            //skView.showsPhysics = true
            skView.ignoresSiblingOrder = true
            
            
            let scene = getInitialScene()
            skView.presentScene(scene)
        }
    }
    
    func getInitialScene() -> SKScene {
        let startScene = StartScene(fileNamed: "StartScene")!
        startScene.size = getSceneSize()
        startScene.scaleMode = .aspectFit
        return startScene
    }
    
    func getSceneSize() -> CGSize {
        let sceneFixedHeight:CGFloat = 375
        
        let screenAspectRatio = self.view.bounds.size.width / self.view.bounds.size.height
        let sceneSize = CGSize(width: sceneFixedHeight * screenAspectRatio, height: sceneFixedHeight)
        return sceneSize
    }
    
    func scoreManagerWillTakeFocus() {
        if let skView = self.view as? SKView {
            skView.isPaused = true
        }
    }
    
    func scoreManagerDidResignFocus() {
        if let skView = self.view as? SKView {
            skView.isPaused = false
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
