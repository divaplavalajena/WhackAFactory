//
//  WhackSlot.swift
//  WhackARobot
//
//  Created by Jena Grafton on 2/4/17.
//  Copyright © 2017 Bella Voce Productions. All rights reserved.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    
    var charNode: SKSpriteNode!
    
    func configure(at position: CGPoint) {
        self.position = CGPoint(x: position.x, y: position.y)

//        let spriteBot = SKSpriteNode(imageNamed: "Bot_CFLogoWhite")
//        addChild(spriteBot)
//        
//        let spriteHole = SKSpriteNode(imageNamed: "TopLayer_Horizontal")
//        addChild(spriteHole)
        
        let cropNode = SKCropNode()
        charNode = SKSpriteNode(imageNamed: "Bot_CFLogoWhite.png")
        if UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
            cropNode.xScale = 4/3
            cropNode.yScale = 4/3
        }
        cropNode.position = CGPoint(x: 0, y: 4)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "mask_horizontal")
        
        charNode = SKSpriteNode(imageNamed: "Bot_CFLogoWhite.png")
        charNode.xScale = 1/3
        charNode.yScale = 1/3
        charNode.position = CGPoint(x: 0, y: -charNode.size.height)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)

    }
    
    func ascend(){
        if charNode != nil {
            charNode.run(SKAction.move(
                to: CGPoint(x:0, y: 95),
                duration: TimeInterval(0.5)
            ))
        }
    }
    
    func descend(){
        if charNode != nil {
            let descendAction = (SKAction.move(
                to: CGPoint(x:0, y: -charNode.size.height),
                duration: TimeInterval(0.5)
            ))
            
            let removeFromParent = SKAction.run {
                self.removeFromParent()
            }
            
            charNode.run(SKAction.sequence([
                descendAction,
                removeFromParent
            ]))
        }
    }
    

}
