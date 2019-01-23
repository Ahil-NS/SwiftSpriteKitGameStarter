//
//  GameScene.swift
//  SwiftSpriteKitGameStarter
//
//  Created by MacBook on 1/23/19.
//  Copyright © 2019 Ahil. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var playerA : SKSpriteNode?
    
    private var heartTimer : Timer?
    
    override func didMove(to view: SKView) {
        
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        self.playerA = self.childNode(withName: "playerA") as? SKSpriteNode
        
        heartTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createHeart()
        })
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        playerA?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
        
        
    }
    
    func createHeart(){
        let heart = SKSpriteNode(imageNamed: "love")
        addChild(heart)
        
        let maxY = size.width/2 - heart.size.width/2
        let minY = -size.width/2 + heart.size.width/2
        let range = maxY - minY
        let rand = arc4random_uniform(UInt32(range))
        let coinY = maxY - CGFloat(rand)
        heart.position = CGPoint(x: self.size.width/2 + heart.size.width/2, y: coinY)
        let moveLeft = SKAction.moveBy(x: -size.width - heart.size.width, y: 0, duration: 2)
        let actions = SKAction.sequence([moveLeft,SKAction.removeFromParent()])
        
        heart.run(actions)
    }
    
}
