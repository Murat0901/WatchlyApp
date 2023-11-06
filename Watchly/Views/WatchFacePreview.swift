//
//  WatchFacePreview.swift
//  Watchly
//
//  Created by Murat Menzilci on 2/3/22.
//

import SwiftUI

/// Full screen watch face preview with the save option
struct WatchFacePreview: View {
    
    @EnvironmentObject var manager: DataManager
    @State private var showIntroAnimation: Bool = false
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea().onTapGesture {
                manager.selectedWatchFace = ""
            }
            WatchFaceItem
            AddWatchFaceButton
        }.onAppear {
            if !showIntroAnimation {
                //Interstitial.shared.showInterstitialAds()
                showIntroAnimation = true
            }
        }
    }
    
    /// Watch face item
    private var WatchFaceItem: some View {
        let width = UIScreen.main.bounds.width/2.5
        let height = width * 1.25
        return RemoteImage(assetModel: AssetModel(path: "\(manager.selectedWatchFace).jpg"), placeholder: "placeholder")
            .frame(width: width, height: height)
            .cornerRadius(25).padding(5).overlay(
                RoundedRectangle(cornerRadius: 29).stroke(Color.white.opacity(0.5), lineWidth: 4)
            )
            .padding(5).scaleEffect(showIntroAnimation ? 1 : 0.9)
            .padding(.bottom, 50).animation(Animation.easeIn(duration: 0.3))
    }
    
    /// Add Watch Face button
    private var AddWatchFaceButton: some View {
        VStack(spacing: 15) {
            Spacer()
            Button {
                manager.saveCurrentWatchFace()
            } label: {
                Text("Add this Watch Face")
                    .padding(.horizontal, 20).padding(.vertical, 15)
                    .font(.system(size: 20, weight: .medium))
                    .background(Color.white.cornerRadius(15))
                    .foregroundColor(.black)
            }
            
            Button {
                manager.fullScreenMode = .tutorial
                manager.selectedWatchFace = ""
            } label: {
                Text("Show Tutorial").font(.system(size: 15, weight: .medium))
            }
        }
        .foregroundColor(Color.white)
        .padding(.vertical, 75).opacity(showIntroAnimation ? 1 : 0)
        .animation(Animation.linear.delay(0.4))
    }
}

// MARK: - Preview UI
struct WatchFacePreview_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        manager.selectedWatchFace = "Abstract/1"
        return WatchFacePreview().environmentObject(manager)
    }
}
