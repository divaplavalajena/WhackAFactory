//
//  SKSpriteNodeExtension.swift
//  WhackARobot
//
//  Created by Erin Bleiweiss on 2/4/17.
//  Copyright © 2017 Bella Voce Productions. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    func setToLandscapeViewBounds(scene: SKScene,
                         view: SKView){
        self.position = CGPoint(x: (view.bounds.width) / 2, y: (view.bounds.height) / 2)
        self.size = scene.size
    }
    
    func setToPortraitViewBounds(scene: SKScene,
                                 view: SKView){
        self.position = CGPoint(x: (view.bounds.width) / 2, y: (view.bounds.height) / 2)
        self.size = CGSize(width: scene.size.height * 4/3, height: scene.size.width * 4/3)
    }


}
