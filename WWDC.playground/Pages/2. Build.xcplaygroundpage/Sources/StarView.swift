import Foundation
import SpriteKit


class StarScene: SKScene {
    
    var starEmitter: SKEmitterNode!
    var startButton: TextButton!
    
    public var buttonPressedEvent: (() -> ())?
    
    override public init(size: CGSize) {
        super.init(size: size)
        
        if let emitter = SKEmitterNode(fileNamed: "Stars.sks") {
            starEmitter = emitter
            starEmitter.position = CGPoint(x: 0, y: self.size.height/2)
            addChild(starEmitter)
        }
        
        self.backgroundColor = SKColor.black
        
        
        self.startButton = TextButton(origin: CGPoint(x: self.size.width/2, y: self.size.height/2), size: CGSize(width: 300, height: 80), text: "BUILD", color: SKColor.init(white: 0.8, alpha: 0.85), textColor: SKColor.black, fontSize: 50)
        addChild(startButton)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        starEmitter?.resetSimulation()
        starEmitter?.advanceSimulationTime(40)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            if startButton.contains(location) {
                startButton.beginSelect()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            startButton.endSelect()
            if startButton.contains(location), let pressedEvent = buttonPressedEvent {
                pressedEvent()
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            startButton.endSelect()
        }
    }
}



public class StarView: SKView {
    
    let viewFrame = CGRect(x:0 , y:0, width: 640, height: 480)
    
    var starScene: StarScene!
    var rocketBuilderScene: RocketScene!
    var launchScene: LaunchScene!
    
    public init() {
        super.init(frame: viewFrame)
        
        //Create the scenes for the program and present it
        starScene = StarScene(size: frame.size)
        rocketBuilderScene = RocketScene(size: frame.size)
        launchScene = LaunchScene(size: frame.size)
        
        starScene.scaleMode = .aspectFill
        rocketBuilderScene.scaleMode = .aspectFill
        launchScene.scaleMode = .aspectFill
        
        //Each scene has events for when certain buttons are pressed
        //Handle each one by changing scenes, passing data, etc.
        starScene.buttonPressedEvent = {
            [unowned self] in
            self.presentScene(self.rocketBuilderScene, transition: SKTransition.fade(withDuration: 0.5))
        }
        
        rocketBuilderScene.backEvent = {
            [unowned self] in
            self.presentScene(self.starScene, transition: SKTransition.fade(withDuration: 0.5))
        }
        
        rocketBuilderScene.launchEvent = {
            [unowned self] (parts: [RocketPart]) in
            self.launchScene.buildRocket(parts: parts)
            self.presentScene(self.launchScene, transition: SKTransition.fade(withDuration: 0.5))
        }
        
        launchScene.backEvent = {
            [unowned self] in
            self.presentScene(self.rocketBuilderScene, transition: SKTransition.fade(withDuration: 0.5))
        }
        
        self.presentScene(starScene)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



