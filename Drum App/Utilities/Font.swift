////
////  Font.swift
////  Drum App
////
////  Created by Oliver Li on 6/23/24.
////
//
//import UIKit
//import SwiftUI
//
//// UIImage extension to create a blank image
//extension UIImage {
//    static func blankImage(width: CGFloat, height: CGFloat) -> UIImage? {
//        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
//        return renderer.image { ctx in
//            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
//            ctx.cgContext.fill(CGRect(x: 0, y: 0, width: width, height: height))
//        }
//    }
//}
//
//
//// Manages creating an image for a specific character
//class LetterImage {
//    private let character: Character
//    private let font: String
//    private let spaceWidth: CGFloat  // The width for spaces
//
//    init(character: Character, font: String, spaceWidth: CGFloat = 20) {
//        self.character = character.isUppercase ? character : Character(character.uppercased())
//        self.font = font
//        self.spaceWidth = spaceWidth
//    }
//
//    func createImage() -> UIImage? {
//        if self.character == " " {
//            // Create a blank image for spaces
//            return UIImage.blankImage(width: spaceWidth, height: 1) // Height is 1 because only width matters here
//        } else {
//            let imageName = "\(font)_\(self.character)"
//            return UIImage(named: imageName)
//        }
//    }
//}
//
//// Manages creating a sequence of images for a string of text
//class TextImageManager {
//    private let text: String
//    private let font: String
//
//    init(text: String, font: String = "game") {
//        self.text = text
//        self.font = font
//    }
//
//    func createImages() -> [UIImage] {
//        return text.map { LetterImage(character: $0, font: font).createImage() }.compactMap { $0 }
//    }
//}
//
//struct TextImageView: View {
//    let text: String
//    let font: String
//    
//    // This view will create and manage the images for the text
//    var body: some View {
//        HStack (spacing: 0.7){
//            ForEach(textManager.createImages(), id: \.self) { img in
//                Image(uiImage: img)
//            }
//        }
//        .onAppear {
//            // Ensure the text manager is initialized when the view appears
//            self.textManager = TextImageManager(text: self.text, font: self.font)
//        }
//    }
//    
//    // Manager to create images
//    @State private var textManager: TextImageManager
//
//    init(text: String, font: String = "game") {
//        self.text = text
//        self.font = font
//        _textManager = State(initialValue: TextImageManager(text: text, font: font))
//    }
//}

import SwiftUI

struct TextImageView: View {
    let font: String
    @Binding var text: String  // Changed to Binding to update with external changes
    
    var body: some View {
        HStack(spacing: 0.7) {
            ForEach(text.map { String($0) }, id: \.self) { char in
                Image(uiImage: TextImageManager(character: Character(char), font: font).createImage() ?? UIImage())
            }
        }
    }
    
    init(text: Binding<String>, font: String = "game") {
        self._text = text
        self.font = font
    }
}

class TextImageManager {
    private let character: Character
    private let font: String
    
    init(character: Character, font: String) {
        self.character = character
        self.font = font
    }
    
    func createImage() -> UIImage? {
        if character == " " {
            return UIImage.blankImage(width: 20, height: 1)
        } else {
            let imageName = "\(font)_\(character)"
            return UIImage(named: imageName)
        }
    }
}

extension UIImage {
    static func blankImage(width: CGFloat, height: CGFloat) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
}
