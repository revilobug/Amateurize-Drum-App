//
//  Nodes.swift
//  Drum App
//
//  Created by Oliver Li on 5/16/24.
//

import SpriteKit

class InstrumentNode: SKNode 
{
    
    private let shapeNode: SKShapeNode
    private let nameLabel: SKLabelNode

    init(instrument: String, position: CGPoint) 
    {
        self.shapeNode = SKShapeNode(circleOfRadius: 15)
        self.nameLabel = SKLabelNode(text: instrument)
        
        super.init()
        
        self.shapeNode.fillColor = SKColor.clear
        self.shapeNode.strokeColor = SKColor.black
        self.shapeNode.lineWidth = 3
        self.shapeNode.position = CGPoint(x: 0, y: 0) // Local position within the parent node
        
        self.nameLabel.position = CGPoint(x: 0, y: 20) // Adjust relative position to the shape node
        
        self.addChild(shapeNode)
        self.addChild(nameLabel)
        
        // Set the position of the entire node
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }
}

final class NoteNode: SKNode
{
    private let shapeNode: SKShapeNode

    init(instrument: String, position: CGPoint)
    {
        self.shapeNode = SKShapeNode(circleOfRadius: 12)
        
        super.init()
        
        self.shapeNode.fillColor = SKColor.black
        self.shapeNode.position = CGPoint(x: 0, y: 0) // Local position within the parent node
        self.addChild(shapeNode)

        self.name = instrument
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

