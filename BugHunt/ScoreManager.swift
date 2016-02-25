//
//  ScoreManager.swift
//  BugHunt
//
//  Created by Eddie Lee on 22/02/2016.
//  Copyright © 2016 Eddie Lee. All rights reserved.
//

import UIKit
import GameKit

public protocol ScoreManagerFocusDelegate {
    func scoreManagerWillTakeFocus()
    func scoreManagerDidResignFocus()
}

public class ScoreManager {
    public static let sharedInstance = ScoreManager()
    
    public var focusDelegate: ScoreManagerFocusDelegate?
    
    private var leaderboardIdentifier: String?
    private var gameCentreEnabled: Bool = false
    
    
    // MARK: Authentication
    
    public func authenticateLocalPlayer(viewController: UIViewController) {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        var scoreManagerDidTakeFocus: Bool = false
        
        localPlayer.authenticateHandler = { (GameCentreLoginViewController, error) -> Void in
            if GameCentreLoginViewController != nil {
                
                if let focusDelegate = self.focusDelegate {
                    focusDelegate.scoreManagerWillTakeFocus()
                    scoreManagerDidTakeFocus = true
                }
                
                viewController.presentViewController(GameCentreLoginViewController!, animated: true, completion: nil)
                
            } else {
                if scoreManagerDidTakeFocus {
                    if let focusDelegate = self.focusDelegate {
                        focusDelegate.scoreManagerDidResignFocus()
                    }
                }
                
                if localPlayer.authenticated {
                    self.gameCentreEnabled = true
                    self.loadLeaderboardIdentifier(localPlayer)
                } else {
                    self.gameCentreEnabled = false
                }
            }
        }
    }

    private func loadLeaderboardIdentifier(player: GKLocalPlayer) {
        player.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier, error) -> Void in
            if error != nil {
                print("Failed to load default leaderboard \(leaderboardIdentifier) with error \(error)")
                self.gameCentreEnabled = false
            } else {
                self.leaderboardIdentifier = leaderboardIdentifier
                self.updateLocalHighScore()
            }
        })
    }
    
    private func updateLocalHighScore() {
        let localPlayer = GKLocalPlayer.localPlayer()
        let localPlayerLeaderBoard = GKLeaderboard(players: [localPlayer])
        
        localPlayerLeaderBoard.identifier = self.leaderboardIdentifier
        
        localPlayerLeaderBoard.loadScoresWithCompletionHandler { (scores, error) -> Void in
            if let localPlayerGameCentreHighScore = localPlayerLeaderBoard.localPlayerScore {
                if localPlayerGameCentreHighScore.value != self.getLocalHighScore() {
                    self.setLocalHighScore(localPlayerGameCentreHighScore.value)
                }
            }
        }
    }

    
    
    // MARK: Score Recording
    
    public func recordNewScore(score: Int64) {
        self.updateLocalHighScore(score)
        
        if self.gameCentreEnabled == true {
            submitScoreToGameCentre(score)
        }
    }
    
    private func updateLocalHighScore(score: Int64) {
        if score > self.getLocalHighScore() {
            self.setLocalHighScore(score)
        }
    }
    
    private func submitScoreToGameCentre(score: Int64) {
        if let leaderboardIdentifier = self.leaderboardIdentifier {
            let scoreToSubmit = GKScore(leaderboardIdentifier: leaderboardIdentifier)
            scoreToSubmit.value = Int64(score)
            
            GKScore.reportScores([scoreToSubmit], withCompletionHandler: { (error: NSError?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    
    
    // MARK: Get High Score
    
    public func getHighScore() -> Int64 {
        return self.getLocalHighScore()
    }
    
    
    
    // MARK: Local Cache
    
    private func setLocalHighScore(score: Int64) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(NSNumber(longLong: score), forKey: "highScore")
        defaults.synchronize()
    }
    
    private func getLocalHighScore() -> Int64 {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if let highScore = defaults.objectForKey("highScore") as? NSNumber {
            return highScore.longLongValue
        }
        
        return 0
    }
}