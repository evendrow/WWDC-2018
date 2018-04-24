import Foundation
import SpriteKit

func -(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
}
func +(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
}

let rocketDim = 40

public class RocketPart: SKSpriteNode {
    
    class AttachmentNode: SKShapeNode {
        
        enum AttachTypes: Int {
            case Up = 0, Down = 3, Left = 1, Right = 2
            
            //We math together up/down and left/right by comparing the sums
            //If they match, should be equal to 3
            func matches(with: AttachTypes) -> Bool {
                return (self.rawValue + with.rawValue) == 3
            }
        }
        
        static let snapNodeSize: CGFloat = 3
        let snapPointSize = CGSize(width: snapNodeSize, height: snapNodeSize)
        
        weak var part: RocketPart!
        var attachType: AttachTypes!
        
        var attached = false
        weak var attachedPart: RocketPart?
        
        init(origin: CGPoint, part: RocketPart, attachType: AttachTypes) {
            super.init()
            self.part = part
            self.attachType = attachType
            
            self.path = CGPath(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: snapPointSize), transform: nil)
            self.position = origin
            self.fillColor = SKColor.yellow
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func getAbsoluteLocation() -> CGPoint {
            return self.position + part.position
        }
        
        func attach(to: RocketPart?) {
            self.attachedPart = to
            self.fillColor = SKColor.red
            attached = true
        }
        
        func unattach() {
            self.attachedPart = nil
            self.fillColor = SKColor.yellow
            attached = false
        }
    }
    
    let snapNodeSize: CGFloat = 4
    var snapNodes: [AttachmentNode] = []
    
    var isMaster: Bool = false
    var attachedTo: AttachmentNode?
    var attachedAt: AttachmentNode?
    
    var blockWidth: Int!
    var blockHeight: Int!
    var imageName: String!
    var snapPoints: [(point: CGPoint, attachType: AttachmentNode.AttachTypes)]!
    var mass: CGFloat!
    var partTitle: String!
    var labelTitle: String!
    
    /**
     RocketPart creates a generic part from given information
     - parameters:
         - blockWidth: How wide the part is in generic block units (specified by rocketDim)
         - blockHeight: How tall the part is in generic block units
         - imageName: A string representing the image the block will take on
         - snapPoints: A set of points other parts can snap on to, given relative to the anchor point (center) from -0.5 to 0.5
         - mass: The mass of the object which will be applied to the physcis body
         - partTitle: The name of the part to be used in identifying it
         - isMaster: Whether or not this part is the master attachment point
     
     */
    init(blockWidth: Int, blockHeight: Int, imageName: String, snapPoints: [(point: CGPoint, attachType: AttachmentNode.AttachTypes)], mass: CGFloat, partTitle: String, labelTitle: String, isMaster: Bool = false) {
        super.init(texture: SKTexture.init(imageNamed: imageName), color: UIColor.green, size: CGSize(width: rocketDim*blockWidth, height: rocketDim*blockHeight))
        
        self.isMaster = isMaster
        self.blockWidth = blockWidth
        self.blockHeight = blockHeight
        self.imageName = imageName
        self.snapPoints = snapPoints
        self.mass = mass
        self.partTitle = partTitle
        self.labelTitle = labelTitle
        
        
        
        //Creates snap points as small yellow boxes
        snapPoints.forEach() {
            
            let point = $0.point
            let attachType = $0.attachType
            
            //Create yellow snap node with specified x & y relative to the center
            let snapPointOrigin = CGPoint(x: self.size.width * point.x - snapNodeSize/2, y: self.size.height * point.y - snapNodeSize/2)
            let node = AttachmentNode(origin: snapPointOrigin, part: self, attachType: attachType)
            snapNodes.append(node)
            
            self.addChild(node)
        }
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Shows the snap points specified in the initializer
     */
    func showSnapPoints() {
        snapNodes.forEach() { $0.isHidden = false }
    }
    
    /**
     Hides the snap points
     */
    func hideSnapPoints() {
        snapNodes.forEach() { $0.isHidden = true }
    }
    
    func getSnapPoints() -> [AttachmentNode] {
        return snapNodes
    }
    
    func getClone() -> RocketPart {
        let cloneNode = RocketPart(blockWidth: self.blockWidth, blockHeight: self.blockHeight, imageName: self.imageName, snapPoints: self.snapPoints, mass: self.mass, partTitle: self.partTitle, labelTitle: self.labelTitle)
        cloneNode.position = self.position
        return cloneNode
    }
    
    //return a cloned, physics-complete version of the node with all of the attached parts
    func getClonedWithPhysics() -> [RocketPart] {
        let clonePart = self.getClone()
        clonePart.hideSnapPoints()
        
        var rocketParts = [clonePart]
        
        //Make a generic physics body to add to the clone
        let masterPhysicsBody = SKPhysicsBody(edgeLoopFrom: clonePart.frame)
        masterPhysicsBody.mass = clonePart.mass
        masterPhysicsBody.friction = 0.5
        masterPhysicsBody.restitution = 0.3
        clonePart.physicsBody = masterPhysicsBody
        
        for node in snapNodes {
            if node.attached, let parts = node.attachedPart?.getClonedWithPhysics() {
                rocketParts.append(contentsOf: parts)
            }
        }
        
        
        return rocketParts
    }
    
}


//Menu on the side of the screen which has all the rocket pieces
class PartMenu: SKShapeNode {
    
    var parts: [RocketPart] = []
    var size: CGSize!
    
    init(rect: CGRect, parts: [RocketPart]) {
        super.init()
        
        self.size = rect.size
        self.parts = parts
        parts.forEach() {
            $0.setScale(1.4)
            self.addChild($0)
            
            let partLabel = SKLabelNode(fontNamed: "Arial-Bold")
            partLabel.text = $0.labelTitle
            partLabel.fontColor = UIColor.black
            partLabel.fontSize = 14
            partLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            partLabel.position = CGPoint(x: $0.position.x, y: $0.position.y - $0.size.height/2 - 20)
            self.addChild(partLabel)
        }
        
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: rect.size), transform: nil)
        self.position = rect.origin
        self.fillColor = SKColor(white: 0.9, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getRocketPartAt(point: CGPoint) -> RocketPart! {
        for part in parts {
            if part.contains(point) {
                //return a copy of the rocket part
                return part.getClone()
            }
        }
        return nil
    }
    
}


//Scene Class
class RocketScene: SKScene {
    
    let menuWidth: CGFloat = 200
    
    var draggedNode: RocketPart?
    var snapped = false
    
    var rocketNodes: [RocketPart] = []
    var activeNodes: [RocketPart] {
        return rocketNodes.filter() { $0.isMaster || $0.attachedTo != nil }
    }
    
    var menu: PartMenu!
    
    var backButton: TextButton!
    var launchButton: TextButton!
    
    public var backEvent: (() -> ())?
    public var launchEvent: ((_ parts: [RocketPart]) -> ())?
    
    override public init(size: CGSize) {
        super.init(size: size)
        
        //Set up the menu with relavant rocket parts
        //The fuel tank item
        let fuelNode = RocketPart(blockWidth: 1, blockHeight: 2, imageName: "fuel3.png", snapPoints: [
            (CGPoint(x: 0, y: 0.5), RocketPart.AttachmentNode.AttachTypes.Up),
            (CGPoint(x: 0, y: -0.5), RocketPart.AttachmentNode.AttachTypes.Down),
            (CGPoint(x: 0.5, y: 0), RocketPart.AttachmentNode.AttachTypes.Right),
            (CGPoint(x: -0.5, y: 0), RocketPart.AttachmentNode.AttachTypes.Left)
            ], mass: 2, partTitle: "fuel", labelTitle: "Fuel Tank")
        
        fuelNode.position = CGPoint(x: 100, y: 120)
        fuelNode.showSnapPoints()
        
        //Engine item which attaches to the bottom of the rocket
        let engineNode = RocketPart(blockWidth: 1, blockHeight: 1, imageName: "engine3.png", snapPoints: [
            (CGPoint(x: 0, y: 0.5), RocketPart.AttachmentNode.AttachTypes.Up)
            ], mass: 2, partTitle: "engine", labelTitle: "Engine")
        
        engineNode.position = CGPoint(x: 60, y: 270)
        engineNode.showSnapPoints()
        
        let engineBig = RocketPart(blockWidth: 1, blockHeight: 2, imageName: "bigrocket.png", snapPoints: [
            (CGPoint(x: 0, y: 0.5), RocketPart.AttachmentNode.AttachTypes.Up)
            ], mass: 2, partTitle: "enginebig", labelTitle: "Big Engine")
        
        engineBig.position = CGPoint(x: 140, y: 270)
        engineBig.showSnapPoints()
        
        menu = PartMenu(rect: CGRect(x: 0, y: 0, width: menuWidth, height: self.size.height), parts: [fuelNode, engineNode, engineBig])
        addChild(menu)
        
        //Now create a capsule (the master attachment point) and add it to the scene
        let capsule = RocketPart(blockWidth: 1, blockHeight: 1, imageName: "capsule3", snapPoints: [
            (CGPoint(x: 0, y: -0.5), RocketPart.AttachmentNode.AttachTypes.Down)
            ], mass: 1, partTitle: "capsule", labelTitle: "Capsule", isMaster: true)
        
        capsule.position = CGPoint(x: 400, y: 200)
        capsule.constraints = [
            SKConstraint.positionX(SKRange(
                lowerLimit: menuWidth + capsule.size.width/2,
                upperLimit: self.size.width - capsule.size.width/2),
                                   y: SKRange(
                                    lowerLimit: capsule.size.height/2,
                                    upperLimit: self.size.height))
        ]
        rocketNodes.append(capsule)
        
        capsule.hideSnapPoints()
        addChild(capsule)
        
        //Set up buttons
        let buttonColor = SKColor(red: 0.3255, green: 0.7255, blue: 0.9373, alpha: 1.0)
        backButton = TextButton(origin: CGPoint(x: menu.size.width/2, y: self.size.height-40), size: CGSize(width: 160, height: 40), text: "BACK", color: buttonColor, textColor: SKColor.white, fontSize: 26)
        launchButton = TextButton(origin: CGPoint(x: menu.size.width/2, y: self.size.height-100), size: CGSize(width: 160, height: 40), text: "LAUNCH", color: buttonColor, textColor: SKColor.white, fontSize: 26)
        
        //Add buttons to the view
        addChild(backButton)
        addChild(launchButton)
        
        let instructionsLabel = SKLabelNode(fontNamed: "Arial-Bold")
        instructionsLabel.text = "Build your own rocket and see how high it flies!"
        instructionsLabel.color = UIColor.white
        instructionsLabel.fontSize = 14
        instructionsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        instructionsLabel.position = CGPoint(x: self.size.width/2 + 100, y: self.size.height - 20)
        self.addChild(instructionsLabel)
        
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            if backButton.contains(location) {
                backButton.beginSelect()
            } else if launchButton.contains(location) {
                launchButton.beginSelect()
            } else {
                
                //Check if the touch begins on an item in the menu
                if let newNode = menu.getRocketPartAt(point: touch.location(in: menu)) {
                    
                    //If there is a new node, add it to the scene and set it as the dragged object
                    newNode.position = location
                    rocketNodes.append(newNode)
                    self.addChild(newNode)
                    startDragging(part: newNode)
                    
                } else {
                    //Otherwise, check if it's on any of the nodes in the drag area
                    for part in rocketNodes {
                        if part.contains(location) {
                            part.position = location
                            
                            startDragging(part: part)
                            break
                        }
                    }
                }
                
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, draggedNode != nil, !snapped {
            draggedNode!.position = touch.location(in: self)
            
            //If you're snapped to a node, check that the part is within the correct
            //distance to maintain being snapped; otherwise disconnect
            if let parentAttachment = draggedNode!.attachedTo,
                let nodeAttachemnt = draggedNode!.attachedAt {
                if dist(p1: parentAttachment.getAbsoluteLocation(), p2: nodeAttachemnt.getAbsoluteLocation()) < 20 {
                    draggedNode?.position = parentAttachment.getAbsoluteLocation() - nodeAttachemnt.position
                } else {
                    parentAttachment.unattach()
                    nodeAttachemnt.unattach()
                    draggedNode!.constraints = []
                    draggedNode!.attachedAt = nil
                    draggedNode!.attachedTo = nil
                }
                
            } else if !draggedNode!.isMaster {
                
                
                //Only make 1 attachment, after which should return
                var attachmentMade = false
                
                //Go through all of the active parts (active means attached to master)
                for part in activeNodes {
                    if attachmentMade { break }
                    if part.isEqual(to: draggedNode!) { continue }
                    
                    for snapNodeMatch in part.getSnapPoints() {
                        if attachmentMade { break }
                        if snapNodeMatch.attached { continue }
                        
                        //Get the absolute position of the snap node in the scene to compare with other nodes
                        let absoluteLocation = snapNodeMatch.getAbsoluteLocation()
                        
                        //Compare the distance of the attachment point to the dragged object's attachment points
                        for dragAttachment in draggedNode!.getSnapPoints() {
                            //If the attaattachment point is incompatible, skip
                            if !dragAttachment.attachType.matches(with: snapNodeMatch.attachType) { continue }
                            
                            //If the distance is small enough, make an attachment
                            if dist(p1: dragAttachment.getAbsoluteLocation(), p2: absoluteLocation) < 20 {
                                draggedNode!.attachedTo = snapNodeMatch
                                draggedNode!.attachedAt = dragAttachment
                                //We only give attached item data to the higher-level node
                                snapNodeMatch.attach(to: draggedNode!)
                                dragAttachment.attach(to: nil)
                                
                                //Attach it to the node
                                let dragConstraint = SKConstraint.distance(SKRange(constantValue: 0), to: snapNodeMatch.position-dragAttachment.position, in: part)
                                draggedNode!.constraints = [ dragConstraint ]
                                
                                attachmentMade = true
                                break
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first{
            endDrag()
            if backButton.selected {
                backButton.endSelect()
                back()
            } else if launchButton.selected {
                launchButton.endSelect()
                launch()
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first{
            endDrag()
            backButton.endSelect()
            launchButton.endSelect()
        }
        
    }
    
    func startDragging(part: RocketPart) {
        draggedNode = part
        
        // When you start dragging, display the attachment points for the
        // current node and on active nodes you can snap to
        draggedNode!.showSnapPoints()
        activeNodes.forEach() { $0.showSnapPoints() }
        
        //Add a fade effect for picking up the node
        draggedNode!.removeAction(forKey: "drop")
        draggedNode!.run(SKAction.fadeAlpha(to: 0.5, duration: 0.25), withKey: "pickup")
    }
    
    func endDrag() {
        //Just in case, make sure there is actually a node to stop dragging
        if draggedNode != nil {
            rocketNodes.forEach() { $0.hideSnapPoints() }
            draggedNode!.removeAction(forKey: "pickup")
            draggedNode!.run(SKAction.fadeAlpha(to: 1.0, duration: 0.25), withKey: "drop")
            
            if draggedNode!.intersects(menu) && !draggedNode!.isMaster {
                deleteNode(node: draggedNode!)
            }
            draggedNode = nil
        }
    }
    
    func deleteNode(node: RocketPart) {
        node.removeFromParent()
        rocketNodes = rocketNodes.filter() { $0 !== node }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    
    /**
     Calculates distance between two points
     - parameters:
     - p1: The first point
     - p2: The second point
     - returns: A CGFloat representing the distance calculated using the distance formula
     */
    func dist(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt(pow(p2.x-p1.x, 2) + pow(p2.y-p1.y, 2))
    }
    
    func back() {
        backEvent?()
    }
    
    class Rocket: SKSpriteNode {
        var fuel: CGFloat = 0
    }
    
    func launch() {
        //Find master node
        if let masterNodeOriginal = (rocketNodes.filter() { $0.isMaster }).first {
            let parts = masterNodeOriginal.getClonedWithPhysics()
            launchEvent?(parts)
        }
    }
    
}

let viewFrame = CGRect(x:0 , y:0, width: 640, height: 480)

public class RocketView: SKView {
    
    public init() {
        super.init(frame: viewFrame)
        
        //Create the rocket builder scene and present it
        let scene = RocketScene(size: frame.size)
        scene.scaleMode = .aspectFill
        self.presentScene(scene)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






