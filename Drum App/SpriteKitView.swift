//
//  SpriteKitView.swift
//  Drum App
//
//  Created by Oliver Li on 7/29/23.
//

import Foundation
import SwiftUI
import SpriteKit

class CustomSKScene: SKScene, ObservableObject {
    var instrumentsDict: [UInt8: CGFloat]
    var song: [MidiNote]
    var bpm: UInt32
    var targetPos : CGFloat
    var initPos : CGFloat
    var initialTime: TimeInterval
    var moveTime : TimeInterval
    var tickLength : Double
    var speedMult : Float
    var isGamePaused : Bool
    let screenWidth : CGFloat  = UIScreen.main.bounds.width
    let screenHeight : CGFloat = UIScreen.main.bounds.height

    init(instruments: Set<UInt8>, song: [MidiNote], bpm: UInt32, targetFactor : CGFloat, initPos : CGFloat, tickLength : Double) {
        let screenSize = CGSize(width: screenWidth, height: screenHeight + 20)
        self.instrumentsDict = [:]
        let verticalSpacing = screenHeight / CGFloat(instruments.count + 1)

        // Create and position the nodes for each instrument
        for (index, instrument) in instruments.enumerated() {
            instrumentsDict[instrument] = verticalSpacing * CGFloat(index + 1)
        }
        
        self.song = song
        self.bpm = bpm
        self.targetPos = targetFactor * screenWidth
        self.initPos = initPos
        self.initialTime = 0.0
        self.moveTime = (targetFactor * screenWidth - initPos) / CGFloat(bpm * 2)
        self.tickLength = tickLength
        self.speedMult = 1.0
        self.isGamePaused = false
                
        super.init(size: screenSize)  // Call the superclass's initializer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        pauseGame()

        backgroundColor = .clear
        scaleMode = .fill

        for (instrument, pos) in instrumentsDict {
            let node = SKShapeNode(circleOfRadius: 15)
            let nodeName = SKLabelNode(text: "\(instrument)")
            node.fillColor = SKColor.clear
            node.strokeColor = SKColor.black
            node.lineWidth = 3
            node.position = CGPoint(x: screenWidth * 0.9, y: pos)
            nodeName.position = CGPoint(x: screenWidth * 0.9, y: pos)
            addChild(node)
            addChild(nodeName)
        }
    }

    func pauseGame () {
        isGamePaused = true
        
        let opacityNode = SKSpriteNode(color: SKColor.black, size: size)
        opacityNode.alpha = 0.5
        opacityNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(opacityNode)
        
        let countdownLabel = SKLabelNode(text: "3")
        countdownLabel.zPosition = 200
        countdownLabel.fontSize = 60
        countdownLabel.fontColor = .white
        countdownLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)  // Centered the label
        addChild(countdownLabel)

        // Create a countdown sequence
        let updateTo2 = SKAction.run { countdownLabel.text = "2" }
        let updateTo1 = SKAction.run { countdownLabel.text = "1" }
        let removeCountdown = SKAction.run {
            countdownLabel.removeFromParent()
            opacityNode.removeFromParent()
        }
        
        let unpauseGame = SKAction.run { self.isGamePaused = false }
        
        let countdownSequence = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            updateTo2,
            SKAction.wait(forDuration: 1.0),
            updateTo1,
            SKAction.wait(forDuration: 1.0),
            removeCountdown,
            unpauseGame
        ])

        countdownLabel.run(countdownSequence)
    }
    
    func changeBPM (bpm: UInt32) {
        isPaused = true
        
        self.speedMult = Float(bpm) / Float(self.bpm)
        self.moveTime = (targetPos - initPos) / CGFloat(speedMult * Float(bpm) * 2)
        for note in children {
            if note.name != nil {
                if note.name!.prefix(4) != "note" {
                    continue
                }
                let time = (targetPos - note.position.x) / CGFloat(speedMult * Float(bpm) * 2)
                note.removeAllActions()
                note.run(SKAction.moveBy(x: targetPos - note.position.x, y: 0, duration: time))
                note.run(SKAction.sequence([SKAction.wait(forDuration: time + 0.2), SKAction.removeFromParent()]))
                let name = "midi/" + note.name!.suffix(2)
                let sound = SKAction.playSoundFileNamed(name, waitForCompletion: false)
                let seq = SKAction.sequence([SKAction.wait(forDuration: time), sound])
                note.run(seq)
            }
        }
        
        pauseGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGamePaused {
            return
        }
        
        // If it's the first update, set the elapsed time to current time
        if initialTime == 0 {
            initialTime = currentTime
        }

        let songTime = currentTime - initialTime

        while !song.isEmpty {
            let note = song.first!
            
            if (Double(note.nStartTime) / 1_000_000.0 / Double(self.speedMult) * tickLength) < songTime {
                let node = SKShapeNode(circleOfRadius: 12)
                node.fillColor = SKColor.black
                node.name = "note" + String(note.nKey)
                node.position = CGPoint(x: initPos, y: instrumentsDict[note.nKey]!)
                let moveAction = SKAction.moveBy(x: targetPos - initPos, y: 0, duration: moveTime)
                node.run(moveAction)
                addChild(node)
                let delay = SKAction.wait(forDuration: moveTime + 0.2)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([delay, remove])
                node.run(sequence)
                
                let soundName : String = "midi/" + String(note.nKey)
                let sound = SKAction.playSoundFileNamed(soundName, waitForCompletion: false)
                let seq = SKAction.sequence([SKAction.wait(forDuration: moveTime), sound])
                node.run(seq)

                song.removeFirst()
            }
            else {
                break
            }
        }
    }
}

struct GameView: View {
    @State private var isMenuVisible : Bool
    @State var customScene : CustomSKScene
    @Binding var currentView: AppView
    
    
    init (currentView: Binding<AppView>, midiData: MidiSong) {
        self.isMenuVisible = false
        self.customScene = CustomSKScene(instruments: midiData.instruments, song: midiData.song, bpm: midiData.m_nBPM, targetFactor: 0.9, initPos : CGFloat(-50), tickLength: midiData.nTickLength)
        self._currentView = currentView
    }
    
    var body: some View {
        ZStack (alignment: .center){
            VStack {
                HStack{
                    Button(action: {isMenuVisible.toggle()}) {
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
                ZStack{
                    Image("game-backdrop1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                    SpriteView(scene: customScene, options: [.allowsTransparency])
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .edgesIgnoringSafeArea(.all)
                }
            )
            if isMenuVisible {
                MenuView(customScene: $customScene, isMenuVisible: $isMenuVisible).onAppear{customScene.isPaused = true}
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
        @State private var newBPM : Float = 0.0
        @Binding var customScene: CustomSKScene
        @Binding var isMenuVisible : Bool
        
        var body: some View {
            VStack {
                Spacer()
                HStack{
                    Spacer()
                    ZStack{
                        Rectangle()
                            .fill(.white)
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                            .cornerRadius(10)
                        switch currentMenu {
                        case .home:
                        VStack{
                            Button (action: {currentMenu = .mainMenu}) {Text("Main Menu")}
                            Button (action: {currentMenu = .settings}) {Text("Settings")}
                            Button (action: {currentMenu = .changeBPM}) {Text("Change BPM")}
                            Button(action: {
                                isMenuVisible = false
                                customScene.isPaused = false
                            }) {Text("Close")}
                        }
                        case .changeBPM:
                        VStack{
                            Slider (value: $newBPM, in: 0...480)
                            Button (action: {
                                customScene.changeBPM(bpm: UInt32(newBPM))
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

}

