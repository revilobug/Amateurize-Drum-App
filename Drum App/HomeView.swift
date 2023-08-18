//
//  HomeView.swift
//  Drum App
//
//  Created by Oliver Li on 8/12/23.
//

import SwiftUI

struct HomeView: View {
    @Binding var currentView: AppView
    @Binding var documentURL: URL?

    var body: some View {
        ZStack (alignment: .center) {
            Image("backdrop")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            VStack (spacing: 10){
                Image ("title")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height:60)
                    .padding(.horizontal)
                
                Button(action: {
                    let uploadFile = Upload_File(documentURL: $documentURL, currentView: $currentView)
                    let controller = UIHostingController(rootView: uploadFile)
                    controller.modalPresentationStyle = .formSheet
                    UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true)
                }) {
                    HStack {
                        Image("uploadbutton")
                            .resizable()
                            .aspectRatio(contentMode: .fit) // Replace with your custom icon name
                            .frame(height:36)
                    }
                }
            }
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
