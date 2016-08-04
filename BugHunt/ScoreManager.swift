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
    
    public func authenticateLocalPlayer(_ viewController: UIViewController) {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        var scoreManagerDidTakeFocus: Bool = false
        
        localPlayer.authenticateHandler = { (GameCentreLoginViewController, error) -> Void in
            if GameCentreLoginViewController != nil {
                
                if let focusDelegate = self.focusDelegate {
                    focusDelegate.scoreManagerWillTakeFocus()
                    scoreManagerDidTakeFocus = true
                }
                
                viewController.present(GameCentreLoginViewController!, animated: true, completion: nil)
                
            } else {
                if scoreManagerDidTakeFocus {
                    if let focusDelegate = self.focusDelegate {
                        focusDelegate.scoreManagerDidResignFocus()
                    }
                }
                
                if localPlayer.isAuthenticated {
                    self.gameCentreEnabled = true
                    self.loadLeaderboardIdentifier(localPlayer)
                } else {
                    self.gameCentreEnabled = false
                }
            }
        }
    }

    private func loadLeaderboardIdentifier(_ player: GKLocalPlayer) {
        player.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifier, error) -> Void in
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
        
        localPlayerLeaderBoard.loadScores { (scores, error) -> Void in
            if let localPlayerGameCentreHighScore = localPlayerLeaderBoard.localPlayerScore {
                if localPlayerGameCentreHighScore.value != self.getLocalHighScore() {
                    self.setLocalHighScore(localPlayerGameCentreHighScore.value)
                }
            }
        }
    }

    
    
    // MARK: Score Recording
    
    public func recordNewScore(_ score: Int64) {
        self.updateLocalHighScore(score)
        
        if self.gameCentreEnabled == true {
            submitScoreToGameCentre(score)
        }
    }
    
    private func updateLocalHighScore(_ score: Int64) {
        if score > self.getLocalHighScore() {
            self.setLocalHighScore(score)
        }
    }
    
    private func submitScoreToGameCentre(_ score: Int64) {
        if let leaderboardIdentifier = self.leaderboardIdentifier {
            let scoreToSubmit = GKScore(leaderboardIdentifier: leaderboardIdentifier)
            scoreToSubmit.value = Int64(score)
            
            GKScore.report([scoreToSubmit], withCompletionHandler: { (error: NSError?) -> Void in
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
    
    private func setLocalHighScore(_ score: Int64) {
        let defaults: UserDefaults = UserDefaults.standard
        
        defaults.set(NSNumber(value: score), forKey: "highScore")
        defaults.synchronize()
    }
    
    private func getLocalHighScore() -> Int64 {
        let defaults: UserDefaults = UserDefaults.standard
        
        if let highScore = defaults.object(forKey: "highScore") as? NSNumber {
            return highScore.int64Value
        }
        
        return 0
    }
}
