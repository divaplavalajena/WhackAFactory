//
//  ScreenSaver.swift
//  WhackARobot
//
//  Created by Erin Bleiweiss on 2/5/17.
//  Copyright © 2017 Bella Voce Productions. All rights reserved.
//

import UIKit
import SpriteKit

class ScreenSaver: SKSpriteNode {
    
    var L_R = "left"
    var bounds = CGSize()
    var animation_speed = 5.0
    
    func config(){
        self.size = CGSize(width: 400, height: 400)
        
        self.run(SKAction.repeatForever(
            SKAction.sequence([
                    SKAction.run {self.changeDirection()},
                    SKAction.wait(forDuration: animation_speed)
                ])
            )
        )
    }
    
    func changeDirection(){
        if self.L_R == "left"{
            let x = self.bounds.width - (self.size.width / 2)
            let usable_height = self.bounds.height - (self.size.height / 2) + 100  // 100 is arbitrary
            
            let y = CGFloat(arc4random_uniform(UInt32(usable_height)))
            let right_point = CGPoint(x: x, y: y)
            
            self.run(
                SKAction.move(
                to: right_point,
                duration: TimeInterval(animation_speed)
                )
            )
            
            self.L_R = "right"
        } else {
            let x = self.bounds.width/4
            let usable_height = self.bounds.height - (self.size.height / 2) + 100
            
            let y = CGFloat(arc4random_uniform(UInt32(usable_height)))
            let left_point = CGPoint(x: x, y: y)
            
            self.run(
                SKAction.move(
                    to: left_point,
                    duration: TimeInterval(animation_speed)
                )
            )
            
            self.L_R = "left"
        }
    }
    
    
}
