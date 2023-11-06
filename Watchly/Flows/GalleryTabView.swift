//
//  GalleryTabView.swift
//  Watchly
//
//  Created by Murat Menzilci on 1/31/22.
//

import SwiftUI
import RevenueCat
import SuperwallKit

/// Gallery tab with watch faces from Firebase
struct GalleryTabView: View {
    
    @EnvironmentObject var manager: DataManager
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            NavigationLink(isActive: $manager.showAllCategoryItems) {
                GalleryGridContentView().environmentObject(manager)
            } label: {
                EmptyView()
            }.isDetailLink(false)
            
            ScrollView(.vertical, showsIndicators: true) {
                HeaderView(title: "Watch Faces", subtitle: "Explore our Gallery")
                LazyVStack(spacing: 15) {
                    ForEach(0..<Categories.count, id: \.self) { index in
                        CategorySection(model: Categories[index])
                        Color.white.frame(height: 1).padding(.horizontal)
                            .padding(.top, 10).opacity(index == (Categories.count - 1) ? 0 : 0.3)
                    }
                }
                Spacer(minLength: 70)
            }.ignoresSafeArea().onAppear {
                if manager.categories.count == 0 { manager.fetchCategories() }
            }
            
            /// Show loading view while fetching data
            LoadingView(isLoading: $manager.showLoading)
        }
        /// Hide the default navigation bar
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("").navigationBarHidden(true)
    }
    
    /// Build a category section view
    private func CategorySection(model: CategoryModel) -> some View {
        VStack {
            HStack {
                Text(model.title).font(.system(size: 20, weight: .semibold))
                Spacer()
                if model.itemsCount > AppConfig.maxRowItems {
                    Button {
                        manager.seeAllCategory = model
                    } label: {
                        HStack(spacing: 5) {
                            if model.isPremium && !manager.isPremiumUser {
                                Image(systemName: "crown.fill")
                            }
                            Text("See all (\(model.itemsCount))")
                            Image(systemName: "chevron.right")
                        }
                    }.font(.system(size: 15)).foregroundColor(.white).opacity(0.6)
                }
            }.padding(.horizontal)
            SectionItems(model: model)
        }
    }

    /// Horizontal carousel with items
    private func SectionItems(model: CategoryModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                Spacer(minLength: -5)
                ForEach(0..<min(model.itemsCount, AppConfig.maxRowItems), id: \.self) { index in
                    WatchFaceItem(model: model, index: index)
                }
                Spacer(minLength: -5)
            }
        }
    }
    
    /// Watch face carousel item
    private func WatchFaceItem(model: CategoryModel, index: Int) -> some View {
        let width = UIScreen.main.bounds.width/3.5
        let height = width * 1.25
        return RemoteImage(assetModel: AssetModel(path: "\(model.title)/\(index+1).jpg"), placeholder: "placeholder")
            .frame(width: width, height: height)
            .cornerRadius(25).padding(5).overlay(
                RoundedRectangle(cornerRadius: 29).stroke(Color.white.opacity(0.5), lineWidth: 4)
            )
            .padding(5)
            .overlay(PremiumTag().opacity(model.isPremium ? 1 : 0))
            .onTapGesture {
                Purchases.shared.invalidateCustomerInfoCache()  // Force refresh
                if model.isPremium {
                    Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
                        if let error = error {
                            // An error occurred
                            print("RevenueCat Error: \(error.localizedDescription)")
                            // Consider showing an error message to the user here
                        } else if let customerInfo = purchaserInfo, customerInfo.entitlements.all["pro"] != nil {
                            // User is a pro user, proceed with presenting the document camera
                            manager.selectedWatchFace = "\(model.title)/\(index+1)"
                        } else {
                            // User is not a pro user and has scanned more than 2 documents, show the paywall
                            Superwall.shared.register(event: "campaign_trigger")
                        }
                    }
                } else {
                    manager.selectedWatchFace = "\(model.title)/\(index+1)"
                }
            }
    }
    
    /// Categories for the app
    private var Categories: [CategoryModel] {
        manager.categories
    }
}

// MARK: - Preview UI
struct GalleryTabView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        manager.categories = [
            CategoryModel(title: "Abstract", isPremium: false, itemsCount: 10),
            CategoryModel(title: "Nature", isPremium: false, itemsCount: 10),
            CategoryModel(title: "Cars", isPremium: false, itemsCount: 10)
        ]
        return GalleryTabView().environmentObject(manager)
    }
}
