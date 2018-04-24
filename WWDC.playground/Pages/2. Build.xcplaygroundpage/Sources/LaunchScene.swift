import Foundation
import SpriteKit

class LaunchScene: SKScene {
    
    let ground = SKSpriteNode(imageNamed: "ground.png")
    
    var backButton: TextButton!
    var backEvent: (() -> ())?
    
    var cam: SKCameraNode!
    
    //Returns rounded altitude
    var altitude: Double {
        let rocketPosition = launchRocket?.position.y ?? 0
        let rocketHeightShift = (launchRocket?.size.height ?? 0)/2
        let unscaledAlt = rocketPosition - rocketHeightShift - 10
        
        return Double(round(unscaledAlt - 21))
    }
    
    //Returns altitude in either meters or km depending on size
    var altitudeString: String {
        let alt = altitude
        if alt < 1000 {
            return "\(Int(alt)) m"
        } else {
            return "\(round(alt/100)/10) km"
        }
    }
    
    var maxAltitude: Double = 0
    var maxAltitudeString = ""
    var maxAltitudeCooldown = 0
    
    var altitudeLabel: SKLabelNode!
    var maxAltitudeLabel: SKLabelNode!
    
    var zoomed = false
    var zoomedBig = false
    
    var thrusting = false
    
    let world = SKNode()
    let staticControls = SKNode()
    
    var launchRocket: Rocket?
    
    var gradientBackground: SKSpriteNode!
    var starBackground: SKSpriteNode!
    var cloudEmitter: SKEmitterNode?
    var planesEmitter: SKEmitterNode?
    var alienEmitter: SKEmitterNode?
    
    var launchButton: TextButton!
    var fuelBar: ProgressBar!
    
    override public init(size: CGSize) {
        super.init(size: size)
        
        //Set up the camera
        cam = SKCameraNode()
        self.camera = cam
        
        //Set up static controls
        staticControls.position = CGPoint(x: 0, y: 0)
        
        //Set up the altitude label
        altitudeLabel = SKLabelNode(fontNamed: "Arial-Bold")
        altitudeLabel.text = "Altitude: 0"
        altitudeLabel.color = UIColor.white
        altitudeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        altitudeLabel.position = CGPoint(x: -self.size.width/2 + 30, y: self.size.height/2 - 100)
        staticControls.addChild(altitudeLabel)
        
        maxAltitudeLabel = SKLabelNode(fontNamed: "Arial-Bold")
        maxAltitudeLabel.text = "Max Altitude: 0"
        maxAltitudeLabel.color = UIColor.white
        maxAltitudeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        maxAltitudeLabel.position = CGPoint(x: -self.size.width/2 + 30, y: self.size.height/2 - 50)
        staticControls.addChild(maxAltitudeLabel)
        
        //Set up world
        world.position = CGPoint(x: 0, y: 0)
        
        //Set up the starry backgorund (for when you're in space)
        starBackground = SKSpriteNode(imageNamed: "stars")
        starBackground.setScale(3)
        starBackground.position = CGPoint(x: 0, y: 0)
        
        world.addChild(starBackground)
        
        //Set up the gradient background
        gradientBackground = SKSpriteNode(imageNamed: "longgradient1.png")
        gradientBackground.position = CGPoint(x: self.size.width/2, y: gradientBackground.size.height/2)
        
        //There's a second part to the gradient background because it's too big for one image file
        let gb2 = SKSpriteNode(imageNamed: "longgradient2.png")
        gb2.position = CGPoint(x: self.size.width/2, y: gradientBackground.size.height + gb2.size.height/2)
        
        world.addChild(gradientBackground)
        world.addChild(gb2)
        
        //Set ground properties
        ground.position = CGPoint(x: self.size.width/2, y: -690)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ground.size.width, height: ground.size.height))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.restitution = 0.3
        
        world.addChild(ground)
        
        //Set up the clouds, planes, aliens, etc.
        if let emitter = SKEmitterNode(fileNamed: "Clouds.sks") {
            cloudEmitter = emitter
            cloudEmitter!.position = CGPoint(x: -self.size.width*2, y: 1300)
            world.addChild(cloudEmitter!)
        }
        
        if let emitter = SKEmitterNode(fileNamed: "Planes.sks") {
            planesEmitter = emitter
            planesEmitter!.position = CGPoint(x: -self.size.width*2, y: 3600)
            world.addChild(planesEmitter!)
        }
        
        if let emitter = SKEmitterNode(fileNamed: "Aliens.sks") {
            alienEmitter = emitter
            alienEmitter!.position = CGPoint(x: -self.size.width*2, y: 8000)
            world.addChild(alienEmitter!)
        }
        
        
        //Set up the fuel bar and accompanying label
        fuelBar = ProgressBar(size: CGSize(width: 15, height: 200))
        fuelBar.position = CGPoint(x: -self.size.width/2 + 40, y: -10)
        fuelBar.setProgress(progress: 1.0)
        staticControls.addChild(fuelBar)
        
        let fuelLabel = SKLabelNode(fontNamed: "Arial-Bold")
        fuelLabel.text = "Fuel"
        fuelLabel.fontColor = UIColor.white
        fuelLabel.fontSize = 16
        fuelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        fuelLabel.position = CGPoint(x: fuelBar.position.x, y: fuelBar.position.y - fuelBar.size.height/2 - 20)
        staticControls.addChild(fuelLabel)
        
        //Set up buttons
        backButton = TextButton(origin: CGPoint(x: -self.size.width/2 + 50, y: -self.size.height/2 + 60), size: CGSize(width: 80, height: 40), text: "BACK", color: SKColor.darkGray, textColor: SKColor.white, fontSize: 22)
        staticControls.addChild(backButton)
        
        launchButton = TextButton(origin: CGPoint(x: self.size.width/2 - 70, y: -self.size.height/2 + 60), size: CGSize(width: 120, height: 40), text: "LAUNCH", color: SKColor.darkGray, textColor: SKColor.white, fontSize: 22)
        staticControls.addChild(launchButton)
        
        self.addChild(world)
        
        cam.addChild(staticControls)
        self.addChild(cam)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -1)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        //Add a zoom effect when you load up the scene
        self.camera!.run(SKAction.scale(to: 2.0, duration: 0))
        self.camera!.run(SKAction.scale(to: 1.0, duration: 2))
        
        thrusting = false
        
        zoomed = false
        zoomedBig = false
        
        //Reset the various emitters
        cloudEmitter?.resetSimulation()
        cloudEmitter?.advanceSimulationTime(100)
        
        planesEmitter?.resetSimulation()
        planesEmitter?.advanceSimulationTime(100)
        
        alienEmitter?.resetSimulation()
        alienEmitter?.advanceSimulationTime(100)
        
        fuelBar.setProgress(progress: 1.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Handle the button presses for the buttons in the scene
        if let touchPoint = touches.first?.location(in: cam) {
            if backButton.frame.contains(touchPoint) {
                backButton.beginSelect()
            } else if launchButton.frame.contains(touchPoint) {
                launchButton.beginSelect()
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchPoint = touches.first?.location(in: cam) {
            
            //Deselct buttons once the touch has ended
            if backButton.selected {
                backButton.endSelect()
                //Only activate the back button action if you started AND ended on it
                if backButton.frame.contains(touchPoint) {
                    backEvent?()
                }
            }
            
            if launchButton.selected {
                launchButton.endSelect()
                //Only activate the back button action if you started AND ended on it
                if launchButton.frame.contains(touchPoint) {
                    //Begin launch
                    thrusting = true
                    launchRocket?.beginThrusting()
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            if backButton.selected {
                backButton.endSelect()
            }
            if launchButton.selected {
                launchButton.endSelect()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        //Update altitude to reflect the current correct one
        altitudeLabel.text = "Altitude: \(altitudeString)"
        
        if altitude > 100 && !zoomed {
            zoomIn()
            zoomed = true
        }
        
        if altitude > 1000 && !zoomedBig {
            zoomInBig()
            zoomedBig = true
        }
        
        if altitude > maxAltitude {
            maxAltitude = altitude
            maxAltitudeString = altitudeString
            maxAltitudeLabel.fontColor = UIColor.red
            maxAltitudeCooldown = 30
        } else {
            //For a specified period of time after reaching a new max, color is red
            maxAltitudeCooldown -= 1
            if maxAltitudeCooldown <= 0 {
                maxAltitudeCooldown = 0
                maxAltitudeLabel.fontColor = UIColor.white
            }
        }
        maxAltitudeLabel.text = "Max altitude: \(maxAltitudeString)"
        
        if thrusting, launchRocket != nil {
            
            //Apply the force and update fuel meter
            launchRocket!.applyThrustForce()
            fuelBar.setProgress(progress: launchRocket!.fuel / launchRocket!.maxFuel)
            
            //If you're out of fuel, thrusting ends and coasting beings
            if launchRocket!.fuel <= 0 {
                thrusting = false
                launchRocket!.endThrusting()
            }
        }
    }
    
    func zoomIn() {
        let zoomInAction = SKAction.scale(to: 2.0, duration: 1)
        self.camera!.run(zoomInAction)
    }
    
    func zoomInBig() {
        let zoomInAction = SKAction.scale(to: 4.0, duration: 1)
        self.camera!.run(zoomInAction)
    }
    
    class Rocket: SKNode {
        
        var fuelConsumption: CGFloat = 0
        
        var parts: [RocketPart]!
        
        var engines: [RocketPart] = []
        var thrust: CGFloat = 0
        var flameEffects: [SKEmitterNode] = []
        
        var size: CGSize!
        
        var mass: CGFloat!
        var fuel: CGFloat!
        var maxFuel: CGFloat!
        
        init(parts: [RocketPart]) {
            super.init()
            
            self.parts = parts
            
            var bodies: [SKPhysicsBody] = []
            
            
            //For use in calculating the box around the objects
            let minX: CGFloat = (parts.map() { $0.position.x - $0.size.width/2  }).min() ?? 0
            let maxX: CGFloat = (parts.map() { $0.position.x + $0.size.width/2  }).max() ?? 0
            let minY: CGFloat = (parts.map() { $0.position.y - $0.size.height/2 }).min() ?? 0
            let maxY: CGFloat = (parts.map() { $0.position.y + $0.size.height/2 }).max() ?? 0
            
            let midX = (minX + maxX)/2
            let midY = (minY + maxY)/2
            
            size = CGSize(width: maxX - minX, height: maxY - minY)
            
            //First add all of the nodes to the rocket so that you can accurately calculate its size
            for part in parts {
                self.addChild(part)
            }
            
            self.mass = parts.reduce(0) { $0 + $1.mass }
            self.fuel = CGFloat((parts.filter() { $0.partTitle == "fuel" }).count)
            self.maxFuel = self.fuel
            
            for part in parts {
                //Since the capsule is on the center of the shape, shift all parts up using
                //the newly calculated rocket size so that it's centerd on the center of the rocket
                part.position = part.position - CGPoint(x: midX, y: midY)
                
                
                //Create a phsyics object for the part
                let path = CGPath(rect: CGRect.init(origin: CGPoint(x: -part.size.width/2 + part.position.x, y: -part.size.height/2 + part.position.y), size: part.size), transform: nil)
                
                let partPhysicsBody = SKPhysicsBody(polygonFrom: path)
                part.physicsBody = nil
                
                bodies.append(partPhysicsBody)
            }
            
            let rocketPhysicsBody = SKPhysicsBody(bodies: bodies)
            rocketPhysicsBody.mass = mass
            rocketPhysicsBody.friction = 0.5
            rocketPhysicsBody.restitution = 0.3
            self.physicsBody = rocketPhysicsBody
            
            //Add engine exhaust effect to all of the engine parts
            for part in parts {
                if part.partTitle == "engine" || part.partTitle == "enginebig" {
                    self.engines.append(part)
                    
                    let multiplier: CGFloat = part.partTitle == "engine" ? 1.0 : 2.0
                    
                    if let emitter = SKEmitterNode(fileNamed: "Flames.sks") {
                        emitter.position = CGPoint(x: 0, y: -part.size.height/2 - 26)
                        emitter.particleBirthRate = 250.0 * multiplier
                        emitter.particleScaleSpeed = -1.0 / multiplier
                        emitter.isHidden = true
                        self.flameEffects.append(emitter)
                        part.addChild(emitter)
                    }
                    
                    thrust += 1400.0 * multiplier
                    fuelConsumption += 0.008 * multiplier
                    
                }
            }
            
            //Set a generic position that the scene will determine later
            self.position = CGPoint(x: 0, y: size.height)
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func beginThrusting() {
            flameEffects.forEach() {
                $0.isHidden = false
            }
        }
        
        func endThrusting() {
            flameEffects.forEach() {
                $0.isHidden = true
            }
        }
        
        func applyThrustForce() {
            if fuel > 0 {
                //Apply a thrust proportional to the number of engines
                self.physicsBody?.applyForce(CGVector(dx: 0, dy: thrust))
                
                //Subtract fuel used and make sure fuel isn't negative
                fuel = fuel - fuelConsumption
                if fuel < 0 {
                    fuel = 0
                }
                
                self.physicsBody!.mass -= fuelConsumption * 1.2
            }
        }
    }
    
    func buildRocket(parts: [RocketPart]) {
        
        //If there is already an existing rocket, delete it
        launchRocket?.removeFromParent()
        
        //Create a new rocket using given data
        launchRocket = Rocket(parts: parts)
        self.addChild(launchRocket!)
        
        launchRocket!.position.x = self.size.width/2
        launchRocket!.position.y = launchRocket!.size.height/2 + 35
        
        //Center the camera on the rocket
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: launchRocket!)
        cam.constraints = [constraint]
        
        //Center the starry background on the rocket
        let starConstraints = SKConstraint.distance(SKRange(constantValue: 0), to: launchRocket!)
        starBackground.constraints = [starConstraints]
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -1)
        
        
    }
    
}

class ProgressBar: SKSpriteNode {
    
    var progressNode: SKSpriteNode!
    var progress: CGFloat = 1
    
    init(size: CGSize) {
        super.init(texture: nil, color: UIColor.red, size: size)
        
        progressNode = SKSpriteNode(color: UIColor.green, size: CGSize(width: self.size.width, height: 0))
        progressNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        progressNode.position = CGPoint(x: 0, y: -self.size.height/2)
        self.addChild(progressNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(progress: CGFloat) {
        self.progress = progress
        progressNode.size.height = progress * self.size.height
    }
    
}
