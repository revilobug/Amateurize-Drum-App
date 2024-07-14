//
//  Nodes.swift
//  Drum App
//
//  Created by Oliver Li on 5/16/24.
//

import SpriteKit

class LetterNode: SKSpriteNode 
{
    
    private let character: Character
    
    init(character: Character, font: String)
    {
        self.character = character
        
        // Check if the character is uppercase, if not, convert it to uppercase
        let processedCharacter = character.isUppercase ? character : Character(character.uppercased())
        let texture = SKTexture(imageNamed: "\(font)_\(processedCharacter)")
        
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = String(processedCharacter)
    }
    
    required init?(coder aDecoder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }
}

class TextNode: SKNode
{
    init(text: String, font: String = "game")
    {
        super.init()
        
        // Iterate over each character in the text
        for (index, character) in text.enumerated() {
            let letterNode = LetterNode(character: character, font: font)
            
            letterNode.position = CGPoint(x: index * Int(letterNode.size.width), y: 0)
            
            self.addChild(letterNode)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FxNode: SKSpriteNode {
    private var fxVelocityX: Float = -3
    private var fxVelocityY: Float = 3
    private var fxAccelX: Float
    private var fxAccelY: Float
    private let alphaDecay: Float = -0.05
    public var finished = false
    
    // Arrays for each instrument type
    let higherPitchTextures = ["wham!", "bang!", "bam!"]
    let lowerPitchTextures = ["thump!", "boom!", "dum!"]
    let cymbalTextures = ["crash!", "snap!"]
    let hiHatTextures = ["tss!", "hiss!"]
    let percussionTextures = ["wham!"]
    
    init(fxType: InstrumentType) {
        // Random velocities and opposite accelerations
        self.fxVelocityX = Float.random(in: -4...4)
        self.fxVelocityY = Float.random(in: 2...4)  // Ensure positive Y velocity
        
        self.fxAccelX = fxVelocityX * alphaDecay * 0.8
        self.fxAccelY = fxVelocityY * alphaDecay * 3
        
        // Randomly select a texture based on the fxType
        var selectedTextureName: String
        
        switch fxType {
        case InstrumentType.higherPitch:
            selectedTextureName = higherPitchTextures.randomElement() ?? "default"
        case InstrumentType.lowerPitch:
            selectedTextureName = lowerPitchTextures.randomElement() ?? "default"
        case InstrumentType.cymbals:
            selectedTextureName = cymbalTextures.randomElement() ?? "default"
        case InstrumentType.hiHats:
            selectedTextureName = hiHatTextures.randomElement() ?? "default"
        case InstrumentType.percussion:
            selectedTextureName = percussionTextures.randomElement() ?? "default"
        default:
            selectedTextureName = "default"
        }

        let texture = SKTexture(imageNamed: selectedTextureName)

        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update () {
        self.position.x += CGFloat(fxVelocityX)
        self.position.y += CGFloat(fxVelocityY)
        
        fxVelocityX += fxAccelX
        fxVelocityY += fxAccelY
        
        if self.alpha > 0 {
            self.alpha += CGFloat(alphaDecay)
        } else {
            finished = true
            removeFromParent()
        }
    }
}

class InstrumentNode: SKNode {
    private var spriteNode: SKSpriteNode
    private var fxNodes: [FxNode]

    public var midiKey: UInt8
    private var hitAnimationFrame: Int8
    public let hitAnimationSpeed: Int8 = 6
    

//    private var nameLabel: TextNode

    init(instrument: UInt8, position: CGPoint) {
        self.spriteNode = SKSpriteNode()
        self.midiKey = instrument
        self.hitAnimationFrame = -1
        
        self.fxNodes = []
        
        super.init()
        
        self.position = position
        self.addChild(spriteNode)
        setupInstrument(instrument)
    }
    
    func hit() {
        self.spriteNode.position = CGPoint(x: 0, y: 0)
        self.hitAnimationFrame = 0
        
        var fxType: InstrumentType = getInstrumentType(for: self.midiKey) ?? InstrumentType.noInstrumentType
        let fxNode = FxNode(fxType: fxType)
        fxNode.position = CGPoint(x: 0, y: 32)
        addChild(fxNode)
        self.fxNodes.append(fxNode)
    }
    
    func updateFx () {
        for node in fxNodes {
            node.update()
        }
        
        while fxNodes.count > 0 && fxNodes.last?.finished == true {
            fxNodes.popLast()
        }
    }
    
    func update() {
        updateFx()
        updateBounce()
    }
    
    func updateBounce () {
        if self.hitAnimationFrame == -1 {
            return
        }

        self.hitAnimationFrame += 1
        
        if self.hitAnimationFrame <= self.hitAnimationSpeed / 2 {
            self.spriteNode.position.y -= CGFloat(12 / self.hitAnimationSpeed)
            return
        }

        if self.hitAnimationFrame <= self.hitAnimationSpeed {
            self.spriteNode.position.y += CGFloat(12 / self.hitAnimationSpeed)
        }
        
        if self.hitAnimationFrame == self.hitAnimationSpeed {
            self.hitAnimationFrame = -1
        }
    }
    
    func changeInstrument(to newInstrument: UInt8) {
        setupInstrument(newInstrument)
        self.midiKey = newInstrument
    }
    
    private func setupInstrument(_ instrument: UInt8) {
        if instrument == self.midiKey{
            return
        }
        let instrumentName = getInstrumentString(for: instrument)
        
        if let name = instrumentName {
            self.spriteNode.texture = SKTexture(imageNamed: "\(instrument)_image_silhouette")
            self.spriteNode.size = CGSize(width: 64, height: 64)
        } else {
            self.spriteNode.texture = nil
            self.spriteNode.size = CGSize(width: 0, height: 0)
        }
        
        self.spriteNode.position = CGPoint(x: 0, y: 0)
    }

    required init?(coder aDecoder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }
}

final class NoteNode: SKNode
{
    private let spriteNode: SKSpriteNode
    public var midiKey: UInt8

    init(midiKey: UInt8, position: CGPoint)
    {
        self.spriteNode = SKSpriteNode(imageNamed: "\(midiKey)_image")
        self.midiKey = midiKey
        
        super.init()
        self.position = position
        
        self.spriteNode.position = CGPoint(x: 0, y: 0)
        self.addChild(spriteNode)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
