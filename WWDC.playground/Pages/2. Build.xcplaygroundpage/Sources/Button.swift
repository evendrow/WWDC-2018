import Foundation
import SpriteKit

class TextButton: SKShapeNode {
    
    var text: String!
    var color: SKColor!
    var textColor: SKColor!
    var size: CGSize!
    
    var textLabel: SKLabelNode!
    
    var selected = false
    
    init(origin: CGPoint, size: CGSize, text: String, color: SKColor, textColor: SKColor, fontSize: CGFloat = 14, roundedCorners: Bool = true) {
        super.init()
        
        //remove border
        self.lineWidth = 0
        
        self.text = text
        self.color = color
        self.textColor = textColor
        self.size = size
        
        let cornerRadius = roundedCorners ? size.height/2 : 0
        self.path = CGPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: 0), size: size), cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        self.position = CGPoint(x: origin.x - size.width/2, y: origin.y - size.height/2)
        self.fillColor = color
        
        self.textLabel = SKLabelNode(fontNamed: "Arial-Bold")
        self.textLabel.fontSize = fontSize
        self.textLabel.text = text
        self.textLabel.fontColor = textColor
        self.textLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        self.textLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        self.textLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        
        addChild(textLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginSelect() {
        selected = true
        
        self.removeAction(forKey: "drop")
        self.run(SKAction.fadeAlpha(to: 0.7, duration: 0.15), withKey: "pickup")
    }
    
    func endSelect() {
        selected = false
        
        self.removeAction(forKey: "pickup")
        self.run(SKAction.fadeAlpha(to: 1.0, duration: 0.15), withKey: "drop")
    }
}
