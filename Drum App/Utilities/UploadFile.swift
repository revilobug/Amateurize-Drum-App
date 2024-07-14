//
//  Upload_File.swift
//  Drum App
//
//  Created by Oliver Li on 7/13/23.
//

import SwiftUI
import MobileCoreServices

struct Upload_File: UIViewControllerRepresentable 
{
    @Binding var documentURL: URL?
    @Binding var currentView: AppView

    func makeCoordinator() -> Coordinator 
    {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController 
    {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.midi-audio"], in: .import)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate 
    {
        var parent: Upload_File

        init(_ parent: Upload_File) 
        {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) 
        {
            guard let url = urls.first else { return }
            parent.documentURL = url
            parent.currentView = .loading
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) 
        {
            parent.documentURL = nil
        }
    }
}
