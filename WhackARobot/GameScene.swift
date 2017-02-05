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
import AVFoundation

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
//    var slots = [WhackSlot]()
    var currentSlot = WhackSlot()
    var screensaver = ScreenSaver()
    var screensaverTimeout = Timer()
    var screensaverEnabled = false
    var screensaverBG = SKShapeNode()
    
    var ref: FIRDatabaseReference!
    var moleIndex = "000" // Firebase index
    var molePresent = false
    

    var gameScore: SKLabelNode!
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    func startTimer(){
        self.screensaverTimeout = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.enableScreensaver), userInfo: nil, repeats: true);

    }
    
    
    override func didMove(to view: SKView) {
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
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
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
        
        /*
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        */
        
        
//        addScreenSaver()
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
        self.currentSlot.descend()
        self.molePresent = false
        run(SKAction.playSoundFileNamed("successful.mp3", waitForCompletion: false))
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position, moleIndex: self.moleIndex)
        addChild(slot)
        self.currentSlot = slot
        self.currentSlot.ascend()
        //play sound
        run(SKAction.playSoundFileNamed("gotItem.mp3", waitForCompletion: false))
        /*
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: successful)
            audioPlayer.prepareToPlay()
        }
        catch let error {
            // handle error
        }
        */
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
            self.screensaverBG.fillColor = SKColor.black
            self.screensaverBG.alpha = 0.5
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
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if molePresent {
            self.hideMoleIfPresent()
        }
        self.disableScreensaver()
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
