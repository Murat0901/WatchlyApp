//
//  TutorialContentView.swift
//  Watchly
//
//  Created by Murat Menzilci on 2/3/22.
//

import SwiftUI

/// App tutorial to install watch faces
struct TutorialContentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    private let tutorialAssets: [String] = (1...4).map { "tutorial-\($0)" }
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            VStack {
                HeaderView(title: "Tutorial", subtitle: "How to Add a Watch Face?")
                    .clipped().ignoresSafeArea()
                Spacer()
            }
            VStack {
                Spacer()
                TutorialPagesView
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Exit Tutorial").foregroundColor(.white)
                        .font(.system(size: 12, weight: .medium))
                }.padding()
            }
        }
    }
    
    /// Tutorial pages
    private var TutorialPagesView: some View {
        TabView {
            ForEach(0..<tutorialAssets.count, id: \.self) { index in
                Image(uiImage: UIImage(named: tutorialAssets[index])!)
                    .resizable().aspectRatio(contentMode: .fit)
                    .overlay(
                        VStack {
                            Spacer()
                            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .top, endPoint: .bottom)
                                .frame(height: 100)
                        }
                    ).padding(.horizontal, 40)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: UIScreen.main.bounds.height/1.6)
    }
}

// MARK: - Preview UI
struct TutorialContentView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialContentView()
    }
}
