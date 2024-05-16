//
//  NoteVisualizer.swift
//  Drum App
//
//  Created by Oliver Li on 5/16/24.
//

import SpriteKit
import DequeModule

// percent of screen covered per second by notes
let initScrollSpeedFactor = 0.2
// original position where notes are spawned
let initXPos = -50
// where note targets lay (0 = left of screen, 1 = right of screen)
let initTargetFactor = 0.9

extension Queue where T == SKShapeNode {
    mutating func moveEachNode(dist: Double) {
        var currentNode = head
        while currentNode != nil {
            currentNode?.value.position.x += dist
            currentNode = currentNode?.next
        }
    }
}

final class MidiScene : SKScene {
    let screenWidth : CGFloat  = UIScreen.main.bounds.width
    let screenHeight : CGFloat = UIScreen.main.bounds.height

    let targetPosition : CGFloat
    let spawnPosition : CGFloat
    let originalBPM: UInt32
    let tickLength : Double

    var song: [MidiNote]
    var bpm : UInt32

    var scrollSpeed : Double
    var cameraXLeft : Double
    var cameraXRight : Double
    var leftIndex : Int
    var rightIndex : Int
    var rendered : Deque<SKNode>

    var prevTime : TimeInterval
    
    let margin : CGFloat
    let vertSpacing : CGFloat
    
    let kickYPos : Float
    let snareYPos : Float
    let hihatYPos : Float
    let miscYPos : Float

    init(song: [MidiNote],
         bpm: UInt32,
         tickLength : Double,
         targetFactor : Double = initTargetFactor,
         scrollSpeedFactor : Double = initScrollSpeedFactor,
         spawnPositionPos : Int = initXPos)
    {
        // set all vars
        self.song = song
        self.originalBPM = bpm
        self.bpm = bpm
        self.scrollSpeed = screenWidth * scrollSpeedFactor
        self.spawnPosition = CGFloat(spawnPositionPos)
        self.targetPosition = targetFactor * screenWidth
        
        self.cameraXLeft = self.spawnPosition
        self.cameraXRight = self.targetPosition
        self.tickLength = tickLength
        self.prevTime = 0
        self.leftIndex = 0
        self.rightIndex = 0
        
        self.margin = screenHeight * 0.1
        self.vertSpacing = (screenHeight - 2 * margin) / 3
        
        self.kickYPos = Float(margin + 0 * vertSpacing)
        self.snareYPos = Float(margin + 1 * vertSpacing)
        self.hihatYPos = Float(margin + 2 * vertSpacing)
        self.miscYPos = Float(margin + 3 * vertSpacing)
                
        for (index, note) in self.song.enumerated()
        {
            if note.nKey == 36
            {
                self.song[index].yPos = kickYPos
            }
            else if note.nKey == 38
            {
                self.song[index].yPos = snareYPos
            }
            else if note.nKey == 42 || note.nKey == 44 || note.nKey == 46
            {
                self.song[index].yPos = hihatYPos
            }
            else
            {
                self.song[index].yPos = miscYPos
            }
            
            let songTime = Float(self.song[index].nStartTime) / 1_000_000 * Float(tickLength)
            self.song[index].xPos = Float(spawnPosition) + ((-1) * songTime * Float(self.scrollSpeed))
        }

        self.rendered = Deque<SKNode>()
        let screenSize = CGSize(width: screenWidth, height: screenHeight + 20)
        super.init(size: screenSize)  // Call the superclass's initializer
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView)
    {
        isPaused = true
        backgroundColor = .clear
        scaleMode = .fill

        let kick = InstrumentNode(instrument: "Kick", position: CGPoint(x: targetPosition, y: CGFloat(kickYPos)))
        let snare = InstrumentNode(instrument: "Snare", position: CGPoint(x: targetPosition, y: CGFloat(snareYPos)))
        let hihat = InstrumentNode(instrument: "Hi-hats", position: CGPoint(x: targetPosition, y: CGFloat(hihatYPos)))
        let misc = InstrumentNode(instrument: "Misc", position: CGPoint(x: targetPosition, y: CGFloat(miscYPos)))

        addChild(kick)
        addChild(snare)
        addChild(hihat)
        addChild(misc)

        run(SKAction.playSoundFileNamed("midi/silent", waitForCompletion: false))
    }

    func changeBPM(newBPM: UInt32)
    {
        let changeFactor = Double(newBPM) / Double(bpm)
        bpm = newBPM

        rightIndex = leftIndex

        while (rightIndex > 0) && (Double(song[rightIndex].xPos!) < cameraXRight)
        {
            rightIndex -= 1
        }
        rightIndex += 1

        let startPos = song[rightIndex].xPos!

        for index in rightIndex...(song.count-1)
        {
            let deltaPos = song[index].xPos! - startPos
            song[index].xPos = startPos + deltaPos / Float(changeFactor)
        }

        leftIndex = rightIndex

        while (!rendered.isEmpty)
        {
            rendered.popFirst()?.removeFromParent()
        }

        while (leftIndex < song.count)
        {
            if Double(song[leftIndex].xPos!) > cameraXLeft
            {
                let node = NoteNode(instrument: "note" + String(song[leftIndex].nKey),
                                    position: CGPoint(x: Double(song[leftIndex].xPos!) - cameraXLeft + spawnPosition, y: CGFloat(song[leftIndex].yPos!)))
                rendered.append(node)
                addChild(node)
                leftIndex += 1
            }
            else
            {
                break
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if prevTime == 0
        {
            prevTime = currentTime
        }

        let timeElapsed = currentTime - prevTime
        if timeElapsed > 0.5
        {
            prevTime = currentTime
            return
        }
        
        let distanceElapsed = timeElapsed * scrollSpeed
        prevTime = currentTime

        cameraXLeft = cameraXLeft - distanceElapsed
        cameraXRight = cameraXRight - distanceElapsed

        while (leftIndex < song.count)
        {
            if Double(song[leftIndex].xPos!) > cameraXLeft
            {
                let node = NoteNode(instrument: "note" + String(song[leftIndex].nKey),
                                    position: CGPoint(x: Double(song[leftIndex].xPos!) - cameraXLeft + spawnPosition, y: CGFloat(song[leftIndex].yPos!)))
                rendered.append(node)
                addChild(node)
                leftIndex += 1
            }
            else
            {
                break
            }
        }

        while rendered.first != nil
        {
            if rendered.first!.position.x >= targetPosition
            {
                let node = rendered.popFirst()
                let name = "midi/" + node!.name!.suffix(2)
                run(SKAction.playSoundFileNamed(name, waitForCompletion: false))

                let waitAction = SKAction.wait(forDuration: 0.2)
                let removeAction = SKAction.run {node?.removeFromParent()}
                let sequence = SKAction.sequence([waitAction, removeAction])

                run(sequence)
            }
            else
            {
                break
            }
        }
        for index in 0..<rendered.count
        {
            rendered[index].position.x += distanceElapsed
        }
    }
}
