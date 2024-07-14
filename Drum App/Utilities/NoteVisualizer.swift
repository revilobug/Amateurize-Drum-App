//
//  NoteVisualizer.swift
//  Drum App
//
//  Created by Oliver Li on 5/16/24.
//

import SpriteKit
import DequeModule

// percent of screen covered per second by notes
let initScrollSpeedFactor = 0.5
// original position where notes are spawned
let initXPos = -50
// where note targets lay (0 = left of screen, 1 = right of screen)
let initTargetFactor = 0.9

final class Track {
    let s : MidiScene

    var track: [MidiNote]
    var rendered : Deque<NoteNode>
    let yPos : Double
    var leftIndex : Int
    var rightIndex : Int
    var targetNode : InstrumentNode
    
    init(s: MidiScene, yPos: Double) {
        self.s = s
        self.track = []
        self.rendered = Deque<NoteNode>()
        self.yPos = yPos
        self.leftIndex = 0
        self.rightIndex = 0
        self.targetNode = InstrumentNode(instrument: 0, position: CGPoint(x: s.targetPosition, y: yPos))
    }
    
    func addNote(note: MidiNote) {
        track.append(note)
    }
    
    func updateTargetInstrument() {
        if rightIndex >= track.count {
            return
        }
        
        self.targetNode.changeInstrument(to: track[rightIndex].nKey)
        self.targetNode.update()
    }
    
    func update(distanceElapsed: Double, soundOn: Bool = true)
    {
        if distanceElapsed > 0
        {
            // rightIndex should always point to rightmost node in view
            while rightIndex < track.count && Double(track[rightIndex].xPos!) > s.windowLeft + s.windowWidth - 0.01
            {
                let node = rendered.popFirst()
                if soundOn {
                    s.run(SKAction.playSoundFileNamed(String(node!.midiKey), waitForCompletion: false))
                    self.targetNode.hit()
                }
                node!.removeFromParent()
                rightIndex += 1
            }
            
            for index in 0..<rendered.count
            {
                rendered[index].position.x += distanceElapsed
            }

            // leftIndex should always point to rightmost node NOT in view
            while leftIndex < track.count && Double(track[leftIndex].xPos!) > s.windowLeft
            {

                let node = NoteNode(midiKey:track[leftIndex].nKey,
                                    position: CGPoint(x: Double(track[leftIndex].xPos!) - s.windowLeft + s.spawnPosition, y: yPos))
            
                rendered.append(node)
                s.addChild(node)
                leftIndex += 1
            }
        }
        else
        {
            print("\(distanceElapsed)")

            leftIndex -= 1
            while leftIndex > 0 && Double(track[leftIndex].xPos!) < s.windowLeft
            {
                rendered.popLast()?.removeFromParent()
                leftIndex -= 1
            }
            leftIndex += 1


            for index in 0..<rendered.count
            {
                rendered[index].position.x += distanceElapsed
            }

            rightIndex -= 1
            while rightIndex >= 0 && Double(track[rightIndex].xPos!) < s.windowLeft + s.windowWidth
            {
                let node = NoteNode(midiKey: track[rightIndex].nKey,
                                    position: CGPoint(x: Double(track[rightIndex].xPos!) - s.windowLeft + s.spawnPosition, y: yPos))
                rendered.prepend(node)
                s.addChild(node)
                rightIndex -= 1
            }
            rightIndex += 1
        }
        updateTargetInstrument()
    }
}

final class MidiScene : SKScene {
    let screenWidth : CGFloat  = UIScreen.main.bounds.width
    let screenHeight : CGFloat = UIScreen.main.bounds.height

    let targetPosition : CGFloat
    let spawnPosition : CGFloat
    let originalBPM: UInt32
    let tickLength : Double

    var bpm : UInt32

    var scrollSpeed : Double
    var windowLeft : Double
    var windowWidth : Double

    var prevTime : TimeInterval
    
    let margin : CGFloat
    let vertSpacing : CGFloat
    
    var tracks : [String: Track]
    let song : [MidiNote]
    
    init(song: [MidiNote],
         bpm: UInt32,
         tickLength : Double,
         targetFactor : Double = initTargetFactor,
         scrollSpeedFactor : Double = initScrollSpeedFactor,
         spawnPositionPos : Int = initXPos)
    {
        // set all vars
        self.originalBPM = bpm
        self.bpm = bpm
        self.scrollSpeed = screenWidth * scrollSpeedFactor
        self.spawnPosition = CGFloat(spawnPositionPos)
        self.targetPosition = targetFactor * screenWidth
        
        
        self.windowLeft = self.spawnPosition
        self.windowWidth = self.targetPosition - self.spawnPosition
        self.tickLength = tickLength
        self.prevTime = 0
        
        self.margin = screenHeight * 0.1
        self.vertSpacing = (screenHeight - 2 * margin) / 3
        
        self.tracks = [String: Track]()
        self.song = song

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
        
        self.tracks["kick"] = Track(s: self, yPos: margin + 0 * vertSpacing)
        self.tracks["snare"] = Track(s: self, yPos: margin + 1 * vertSpacing)
        self.tracks["hihat"] = Track(s: self, yPos: margin + 2 * vertSpacing)
        self.tracks["misc"] = Track(s: self, yPos: margin + 3 * vertSpacing)
                        
        for index in 0..<song.count {
            var note = song[index]
            
            if note.nVelocity != 80 {
                print("(\(note.nVelocity))")
            }
            let songTime = Float(note.nStartTime) / 1_000_000 * Float(tickLength)
            note.xPos = Float(spawnPosition) + ((-1) * songTime * Float(scrollSpeed))

            if note.nKey == 36
            {
                self.tracks["kick"]!.addNote(note: note)
            }
            else if note.nKey == 38
            {
                self.tracks["snare"]!.addNote(note: note)
            }
            else if note.nKey == 42 || note.nKey == 44 || note.nKey == 46
            {
                self.tracks["hihat"]!.addNote(note: note)
            }
            else
            {
                self.tracks["misc"]!.addNote(note: note)
            }
        }
        
        for (_, track) in tracks {
            track.updateTargetInstrument()
            addChild(track.targetNode)
        }

        run(SKAction.playSoundFileNamed("init", waitForCompletion: false))
    }

    func changeBPM(newBPM: UInt32)
    {
        bpm = newBPM
        prevTime = -1
    }
    
    func changeTime(deltaTime: TimeInterval)
    {
        let distanceElapsed = deltaTime * scrollSpeed
        windowLeft -= distanceElapsed
        
        if deltaTime == 0
        {
            return
        }

        for (_, track) in tracks {
            track.update(distanceElapsed: distanceElapsed, soundOn: false)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if prevTime == 0
        {
            prevTime = currentTime
            return
        }

        let timeElapsed = (currentTime - prevTime) * (Double(bpm)/Double(originalBPM))
        prevTime = currentTime

        if timeElapsed > 0.5
        {
            return
        }

        let distanceElapsed = timeElapsed * scrollSpeed
        windowLeft -= distanceElapsed

        for (_, track) in tracks {
            track.update(distanceElapsed: distanceElapsed, soundOn: true)
        }
    }
}
