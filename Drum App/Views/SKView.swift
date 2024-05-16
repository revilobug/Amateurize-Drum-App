//
//  SKView.swift
//  Drum App
//
//  Created by Oliver Li on 8/21/23.
//

import Foundation
import SwiftUI
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


struct GameView: View {
    @State private var isMenuVisible : Bool
    @State private var isCountVisibile : Bool
    @State var customScene : MidiScene
    @Binding var currentView: AppView

    init (currentView: Binding<AppView>, midiData: MidiSong) 
    {
        self.isMenuVisible = false
        self.isCountVisibile = true
        self.customScene = MidiScene(song: midiData.song,
                                     bpm: midiData.m_nBPM,
                                     tickLength: midiData.nTickLength)
        self._currentView = currentView
    }

    var body: some View 
    {
        ZStack (alignment: .center)
        {
            VStack 
            {
                HStack
                {
                    Button(action: {isMenuVisible.toggle()}) 
                    {
                        Image("pause")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width:60, height: 60)
                    }.padding(.top, 20).padding(.leading, 20).edgesIgnoringSafeArea(.all)
                    Spacer()
                }
                Spacer()
            }

            .background(
                ZStack
                {
                    Image("game-backdrop1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                    SpriteView(scene: customScene, options: [.allowsTransparency])
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .edgesIgnoringSafeArea(.all)
                }
            )
            if isMenuVisible 
            {
                MenuView(newBPM: Float(customScene.bpm), customScene: $customScene, isMenuVisible: $isMenuVisible, isCountVisible: $isCountVisibile, currentView: $currentView).onAppear{customScene.isPaused = true}
            }
            if isCountVisibile 
            {
                CountdownView(show: $isCountVisibile, customScene: $customScene).onAppear{customScene.isPaused = true}
            }
        }
    }
}


struct CountdownView: View {
    @Binding var show: Bool
    @Binding var customScene: MidiScene
    @State private var counter = 3

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Color.black.opacity(0.8)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                Text("\(counter)")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
            )
            .onReceive(timer) { _ in
                if counter > 0 {
                    counter -= 1
                } else {
                    timer.upstream.connect().cancel()  // Stop the timer when countdown is over
                    customScene.isPaused = false
                    show = false
                }
            }
    }
}

struct MenuView : View {
    enum MenuState {
        case home
        case mainMenu
        case settings
        case changeBPM
    }

    @State private var currentMenu : MenuState = .home
    @State var newBPM : Float = 0.0
    @Binding var customScene: MidiScene
    @Binding var isMenuVisible : Bool
    @Binding var isCountVisible : Bool
    @Binding var currentView: AppView
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        VStack {
            Spacer()
            HStack{
                Spacer()
                ZStack{
                    Rectangle()
                        .fill(.white)
                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.6)
                        .cornerRadius(10)
                    switch currentMenu {
                    case .home:
                    VStack{
                        Button (action: {currentView = .home}) {Text("Main Menu")}
                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.1)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        Button (action: {currentMenu = .settings}) {Text("Settings")}
                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.1)
                        .background(Color.blue)
                        .foregroundColor(.white)

                        Button (action: {currentMenu = .changeBPM}) {Text("Change BPM")}
                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.1)
                        .background(Color.blue)
                        .foregroundColor(.white)

                        Button(action: {
                            isMenuVisible = false
                            isCountVisible = true
                        }) {Text("Close")}
                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.1)
                        .background(Color.blue)
                        .foregroundColor(.white)
                    }
                    case .changeBPM:
                    VStack{
                        Text("BPM: \(Int(newBPM))")
                            .font(.headline)

                        Slider(value: $newBPM, in: 10...240)
                            .frame(width: 200)  // adjust this value as needed
                        Button (action: {
                            customScene.changeBPM(newBPM: UInt32(newBPM))
                            currentMenu = .home
                        }) {Text("Looks Good!")}
                    }
                    case .mainMenu:
                        EmptyView()
                    case .settings:
                        EmptyView()
                    }
                }
                Spacer()
            }
            Spacer()
        }
    }
}

