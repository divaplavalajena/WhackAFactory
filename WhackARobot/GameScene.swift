//
//  GameScene.swift
//  WhackARobot
//
//  Created by Jena Grafton on 2/4/17.
//  Copyright © 2017 Bella Voce Productions. All rights reserved.
//

import SpriteKit
import GameplayKit
import Firebase


class GameScene: SKScene {
    
    
    var currentSlot = WhackSlot()
    var screensaver = ScreenSaver()
    var screensaverTimeout = Timer()
    var screensaverEnabled = false
    var screensaverBG = SKShapeNode()
    
    var ref: FIRDatabaseReference!
    var moleIndex = "000" // Firebase index
    var molePresent = false
    
    /*
    var gameScore: SKLabelNode!
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    */
    //var button: SKLabelNode! //reset the score and start a new game
    
    func startTimer(){
        self.screensaverTimeout = Timer.scheduledTimer(timeInterval: 5 * 60, target: self, selector: #selector(self.enableScreensaver), userInfo: nil, repeats: true);

    }
    
    
    override func didMove(to view: SKView) {
        UIApplication.shared.isIdleTimerDisabled = true
        self.startTimer()
        
        ref = FIRDatabase.database().reference()
        let iPadsRef = ref.child("ipads")

        
        let background = SKSpriteNode(imageNamed: "Background_Horizontal.png")
        background.setToLandscapeViewBounds(scene: self, view: view)
        if UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
            background.setToPortraitViewBounds(scene: self, view: view)
        }
        // background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        /*
        //Game score label
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: \(score)"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        */
        
        /*
        // Create a RESET BUTTON for the game score
            // It was... a simple red rectangle that's 100x44
            //button = SKLabelNode(color: SKColor.red, size: CGSize(width: 100, height: 44))
        button = SKLabelNode(fontNamed: "Chalkduster")
        button = SKLabelNode(text: "Reset Game")
        button.fontColor = SKColor.red
        button.fontSize = 65
        
        // Put it in the upper right corner
        //button.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        button.verticalAlignmentMode = .top
        button.horizontalAlignmentMode = .right
        button.position = CGPoint(x:self.size.width, y:self.size.height)
        self.addChild(button)
        */
        
        iPadsRef.observe(FIRDataEventType.value, with: { (snapshot) in
            for child in (snapshot.children) {
                let snap = child as! FIRDataSnapshot //each child is a snapshot
                if snap.value != nil {
                    self.disableScreensaver()
                    let dict = snap.value as! [String: Any] // the value is a dictionary
                    if (dict["id"]! as! Int == gameiPadID) {
                        if self.moleIndex == "000"{
                            self.moleIndex = snap.key
                        }
                        switch (dict["mole"] as! Bool) {
                        case false:
                            self.hideMoleIfPresent()
                        case true:
                            self.showMole()
                        }
                    }
                }
                
            }
        
        })
        
    }
    
    func showMole(){
        if UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
            createSlot(at: CGPoint(x: (self.view?.bounds.width)!/2 , y: (self.view?.bounds.height)!/2))
        } else {
            createSlot(at: CGPoint(x: (self.view?.bounds.width)!/2 , y: (self.view?.bounds.height)!/2))
        }
        self.molePresent = true
    }
    
    func hideMoleIfPresent(){
        if self.molePresent == true {
            self.currentSlot.descend()
            self.molePresent = false
            run(SKAction.playSoundFileNamed("successful.mp3", waitForCompletion: false))
            //run(SKAction.playSoundFileNamed("MetalClang.mp3", waitForCompletion: false))
            run(SKAction.playSoundFileNamed("MetalGearRattling.mp3", waitForCompletion: false))
            //score = score + 1
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position, moleIndex: self.moleIndex)
        addChild(slot)
        self.currentSlot = slot
        self.currentSlot.ascend()
        //play sound
        run(SKAction.playSoundFileNamed("gotItem.mp3", waitForCompletion: false))
        //run(SKAction.playSoundFileNamed("MetalClang.mp3", waitForCompletion: false))
        run(SKAction.playSoundFileNamed("MetalGearRattling.mp3", waitForCompletion: false))
    }
    
    func enableScreensaver(){
        if screensaverEnabled == false {
            print("enabling screensaver")
            screensaverEnabled = true
            screensaverTimeout.invalidate()
            if molePresent{
                currentSlot.isHidden = true
            }
            
            let size = self.view!.bounds.size
            self.screensaverBG = SKShapeNode(rectOf: size)
            self.screensaverBG.position = CGPoint(x: size.width/2, y: size.height/2)
            self.screensaverBG.isAntialiased = false
            self.screensaverBG.fillColor = SKColor.black
            self.screensaverBG.alpha = 0.65
            addChild(self.screensaverBG)

            self.screensaver = ScreenSaver(imageNamed: "screensaver")
            self.screensaver.bounds = (self.view?.bounds.size)!
            self.screensaver.config()
            addChild(self.screensaver)
        }
    }
    
    func disableScreensaver(){
        if screensaverEnabled == true{
            print("disabling screensaver")
            screensaverEnabled = false
            screensaverTimeout.invalidate()
            startTimer()
            if molePresent{
                currentSlot.isHidden = false
            }
            self.screensaverBG.removeFromParent()
            self.screensaver.removeFromParent()
            
        }
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*
        // Loop over all the touches in this event
        // If SCORE is added to Firebase at some point
        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
            let location = touch.location(in: self)
            // Check if the location of the touch is within the button's bounds
            if button.contains(location) {
                print("tapped!")
                score = 0
            }
            if molePresent {
                self.hideMoleIfPresent()
            }
        }
        */
        if molePresent {
            self.hideMoleIfPresent()
        }
        self.disableScreensaver()
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
