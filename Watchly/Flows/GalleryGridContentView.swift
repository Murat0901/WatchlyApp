//
//  GalleryGridContentView.swift
//  Watchly
//
//  Created by Murat Menzilci on 2/3/22.
//

import SwiftUI
import RevenueCat
import SuperwallKit

/// Shows an entire gallery grid with items for a given category
struct GalleryGridContentView: View {
    
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Main rendering function
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(0..<manager.seeAllCategory!.itemsCount, id: \.self) { index in
                    WatchFaceItem(model: manager.seeAllCategory!, index: index)
                }
            }.padding(.horizontal, 8)
        }.navigationBarTitleDisplayMode(.inline).navigationTitle(manager.seeAllCategory!.title)
    }
    
    /// Watch face grid item
    private func WatchFaceItem(model: CategoryModel, index: Int) -> some View {
        let width = UIScreen.main.bounds.width/3 - 30
        let height = width * 1.25
        return RemoteImage(assetModel: AssetModel(path: "\(model.title)/\(index+1).jpg"), placeholder: "placeholder")
            .frame(width: width, height: height)
            .cornerRadius(22).padding(5).overlay(
                RoundedRectangle(cornerRadius: 26).stroke(Color.white.opacity(0.5), lineWidth: 4)
            )
            .padding(5)
            .overlay(PremiumTag().opacity(model.isPremium ? 1 : 0))
            .onTapGesture {
                if model.isPremium {
                    Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
                        if let error = error {
                            // An error occurred
                            print("RevenueCat Error: \(error.localizedDescription)")
                        } else if let customerInfo = purchaserInfo {
                            if customerInfo.entitlements.all["pro"] != nil {
                                // User is a pro user, proceed with presenting the document camera
                                manager.selectedWatchFace = "\(model.title)/\(index+1)"
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                // User is not a pro user and has scanned more than 2 documents, show the paywall
                                Superwall.shared.register(event: "campaign_trigger")
                            }
                        }
                    }
                } else{
                    manager.selectedWatchFace = "\(model.title)/\(index+1)"
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}

// MARK: - Preview UI
struct GalleryGridView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryGridContentView().environmentObject(DataManager())
    }
}
