//
//  GameScene.swift
//  SwiftSpriteKitGameStarter
//
//  Created by MacBook on 1/23/19.
//  Copyright © 2019 Ahil. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var scoreLabel : SKLabelNode?
    private var yourScoreLabel : SKLabelNode?
    private var finalScoreLabel : SKLabelNode?
    private var playerA : SKSpriteNode?
    private var ground : SKSpriteNode?
    private var ceil : SKSpriteNode?
    
    private var heartTimer : Timer?
    private var brokenHeartTimer : Timer?
    
    
    let playerCategory : UInt32 = 0x1 << 1
    let heartCategory : UInt32 = 0x1 << 2
    let brokenHeartCategory : UInt32 = 0x1 << 3
    
    let groundAndCeilCategory : UInt32 = 0x1 << 4
    
    private var score = 0
    
    override func didMove(to view: SKView) {
        
        //called when physics bodies come in contact with each other.
        physicsWorld.contactDelegate = self
        
        self.scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode
        if let label = self.scoreLabel {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        self.playerA = self.childNode(withName: "playerA") as? SKSpriteNode
        playerA?.physicsBody?.categoryBitMask = playerCategory
        playerA?.physicsBody?.contactTestBitMask = heartCategory
        playerA?.physicsBody?.collisionBitMask = groundAndCeilCategory
        
        var playerRun : [SKTexture] = []
        for num in 0...14 {
            print("running_\(num)")
            playerRun.append(SKTexture(imageNamed: "running_\(num)"))
        }
        playerA?.run(SKAction.repeatForever(SKAction.animate(with: playerRun, timePerFrame: 0.05)))
        
        ground = childNode(withName: "ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ground?.physicsBody?.collisionBitMask = playerCategory
        
        ceil = childNode(withName: "ceil") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        
        startTimers()
        
        
    }
    
    func startTimers(){
        heartTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createHeart()
        })
        
        brokenHeartTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createBrokenHeart()
        })
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.scoreLabel {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        //Applies a force to the center of gravity of a physics body.
        if(scene?.isPaused == false){
            playerA?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
        }
        
        
        let touch = touches.first
        if let location = touch?.location(in: self){
            let theNodes = nodes(at: location)
            
            for node in theNodes{
                if node.name == "play" {
                    score = 0
                    node.removeFromParent()
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Score: \(score)"
                    startTimers()
                }
            }
        }
    }
    
    func createHeart(){
        let heart = SKSpriteNode(imageNamed: "love")
        //Create heart physic body
        heart.physicsBody = SKPhysicsBody(rectangleOf: heart.size)
        
        heart.physicsBody?.affectedByGravity = false
        
        heart.physicsBody?.categoryBitMask = heartCategory
        heart.physicsBody?.contactTestBitMask = playerCategory
        //Stop heart colliding with anything
        heart.physicsBody?.collisionBitMask = 0
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
    
    func createBrokenHeart(){
        let brokenHeart = SKSpriteNode(imageNamed: "broken")
        //Create heart physic body
        brokenHeart.physicsBody = SKPhysicsBody(rectangleOf: brokenHeart.size)
        
        brokenHeart.physicsBody?.affectedByGravity = false
        
        brokenHeart.physicsBody?.categoryBitMask = brokenHeartCategory
        brokenHeart.physicsBody?.contactTestBitMask = playerCategory
        //Stop heart colliding with anything
        brokenHeart.physicsBody?.collisionBitMask = 0
        addChild(brokenHeart)
        
        let maxY = size.width/2 - brokenHeart.size.width/2
        let minY = -size.width/2 + brokenHeart.size.width/2
        let range = maxY - minY
        let rand = arc4random_uniform(UInt32(range))
        let brokenHeartY = maxY - CGFloat(rand)
        brokenHeart.position = CGPoint(x: self.size.width/2 + brokenHeart.size.width/2, y: brokenHeartY)
        let moveLeft = SKAction.moveBy(x: -size.width - brokenHeart.size.width, y: 0, duration: 2)
        let actions = SKAction.sequence([moveLeft,SKAction.removeFromParent()])
        
        brokenHeart.run(actions)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        if contact.bodyA.categoryBitMask == heartCategory{
            score += 1
            scoreLabel?.text = "Score: \(score)"
            contact.bodyA.node?.removeFromParent()
        }
        
        if contact.bodyB.categoryBitMask == heartCategory{
            score += 1
            scoreLabel?.text = "Score: \(score)"
            contact.bodyB.node?.removeFromParent()
        }
        
        if contact.bodyA.categoryBitMask == brokenHeartCategory{
            contact.bodyA.node?.removeFromParent()
            gameOver()
        }
        
        if contact.bodyB.categoryBitMask == brokenHeartCategory{
            contact.bodyB.node?.removeFromParent()
            gameOver()
        }
        
        
    }
    
    func gameOver(){
        scene?.isPaused = true
        
        heartTimer?.invalidate()
        brokenHeartTimer?.invalidate()
        
        yourScoreLabel = SKLabelNode(text: "Your Score: ")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 100
        yourScoreLabel?.zPosition = 1
        if(yourScoreLabel != nil){
            addChild(yourScoreLabel!)
        }
        
        
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.fontSize = 200
        finalScoreLabel?.zPosition = 1
        if(finalScoreLabel != nil){
            addChild(finalScoreLabel!)
        }
        
        
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.name = "play"
        playButton.zPosition = 1
        addChild(playButton)
        
    }
    
}
