import Foundation
import SpriteKit

class StarScene: SKScene {
    
    var starEmitter: SKEmitterNode!
    
    override public init(size: CGSize) {
        super.init(size: size)
        
        if let emitter = SKEmitterNode(fileNamed: "StarSlow.sks") {
            starEmitter = emitter
            starEmitter.position = CGPoint(x: 0, y: self.size.height/2)
            addChild(starEmitter)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        starEmitter?.resetSimulation()
        starEmitter?.advanceSimulationTime(40)
        
        let sun = SKSpriteNode(imageNamed:"sun")
        sun.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        sun.size = CGSize(width: 80, height: 80)
        
        self.addChild(sun)
        
        let earth = SKSpriteNode(imageNamed:"earth")
        earth.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        earth.size = CGSize(width: 30, height: 30)
        
        
        let circle = UIBezierPath(roundedRect: CGRect(x: self.size.width/2 - 150, y: self.size.height/2 - 150, width: 300, height: 300), cornerRadius: 200)
        let circularMove = SKAction.follow(circle.cgPath, asOffset: false, orientToPath: true, duration: 15)
        
        earth.run(SKAction.repeatForever(circularMove))
        
        self.addChild(earth)
        
        let moon = SKSpriteNode(imageNamed:"moon")
        moon.position = CGPoint(x: 77, y: 77)
        moon.size = CGSize(width: 10, height: 10)
        
        
        let moonOrbit = UIBezierPath(roundedRect: CGRect(x: -30, y: -30, width: 60, height: 60), cornerRadius: 30)
        let moonAction = SKAction.follow(moonOrbit.cgPath, asOffset: false, orientToPath: true, duration: 3)
        
        moon.run(SKAction.repeatForever(moonAction))
        
        earth.addChild(moon)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        if let touch = touches.first {
        ////            let location = touch.location(in: self)
        //        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        if let touch = touches.first {
        //            let location = touch.location(in: self)
        //        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            
        }
    }
}



public class PlanetView: SKView {
    
    let viewFrame = CGRect(x:0 , y:0, width: 640, height: 480)
    
    var starScene: StarScene!
    
    public init() {
        super.init(frame: viewFrame)
        
        //Create the scenes for the program and present it
        starScene = StarScene(size: frame.size)
        starScene.scaleMode = .aspectFill
        self.presentScene(starScene)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
