//
//  Upload_File.swift
//  Drum App
//
//  Created by Oliver Li on 7/13/23.
//

import SwiftUI
import MobileCoreServices

struct Upload_File: UIViewControllerRepresentable {
    @Binding var documentURL: URL?
    @Binding var currentView: AppView  // Keep the binding to currentView

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.midi-audio"], in: .import)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: Upload_File

        init(_ parent: Upload_File) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                return
            }
            parent.documentURL = url
            
            // No longer process midiData here; just update the currentView if needed
            parent.currentView = .loading  // Notify ContentView to present the next view
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.documentURL = nil
        }
    }
}
