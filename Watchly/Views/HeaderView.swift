//
//  HeaderView.swift
//  Watchly
//
//  Created by Murat Menzilci on 1/31/22.
//

import SwiftUI

/// Custom header view
struct HeaderView: View {
   
    let title: String
    let subtitle: String
    @State private var headerImageNames: [String] = (1...12).map { "header-image-\($0)" }
    
    // MARK: - Main rendering function
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 4), spacing: 12) {
            ForEach(0..<headerImageNames.count, id: \.self) { index in
                WatchFace(imageName: headerImageNames[index])
            }
        }
        .rotationEffect(Angle(degrees: -20))
        .scaleEffect(1.3).clipped().overlay(
            ZStack {
                VStack {
                    Spacer()
                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 100)
                }
                Color.black.opacity(0.45)
                VStack {
                    Text(title).font(.system(size: 35, weight: .bold))
                    Text(subtitle).font(.system(size: 18, weight: .medium))
                }.padding(.top, 120)
                VStack {
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 100)
                    Spacer()
                }
            }
        ).frame(height: 240, alignment: .bottom).ignoresSafeArea().onAppear {
            if title == "Settings" { headerImageNames = headerImageNames.shuffled() }
        }
    }
    
    /// Watch face view
    private func WatchFace(imageName: String) -> some View {
        let width = UIScreen.main.bounds.width/4.5
        let height = width * 1.222
        return Image(uiImage: UIImage(named: imageName)!)
            .resizable().aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .cornerRadius(20)
    }
}

// MARK: - Preview UI
struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(title: "Watch Faces", subtitle: "Explore our Gallery")
    }
}
