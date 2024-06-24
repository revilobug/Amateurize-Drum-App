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

class InstrumentNode: SKNode {
    
    private var spriteNode: SKSpriteNode
    public var midiKey: UInt8
//    private var nameLabel: TextNode

    init(instrument: UInt8, position: CGPoint) {
        self.spriteNode = SKSpriteNode()
        self.midiKey = instrument
        super.init()
        
        self.position = position
        self.addChild(spriteNode)
        setupInstrument(instrument)
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
        if instrument == 57 || instrument == 49 {
            self.spriteNode.position = CGPoint(x: 0, y: 16)
        }

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
    
    func playSound ()
    {
        run(SKAction.playSoundFileNamed(String(self.midiKey), waitForCompletion: false))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
