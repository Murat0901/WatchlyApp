//
//  DataManager.swift
//  Watchly
//
//  Created by Murat Menzilci on 1/31/22.
//

import SwiftUI
import Firebase
import Foundation

/// Full screen type
enum FullScreenType: Identifiable {
    case premium, tutorial
    var id: Int { hashValue }
}

/// Main data manager to fetch data and control the app
class DataManager: ObservableObject {
    
    /// Dynamic properties that the UI will react to
    @Published var showLoading: Bool = false
    @Published var fullScreenMode: FullScreenType?
    @Published var selectedTab: CustomTabBarItem = .gallery
    @Published var categories: [CategoryModel] = [CategoryModel]()
    @Published var selectedWatchFace: String = ""
    @Published var showAllCategoryItems: Bool = false
    @Published var seeAllCategory: CategoryModel? {
        didSet { showAllCategoryItems = seeAllCategory != nil }
    }
    
    /// Dynamic properties that the UI will react to AND store values in UserDefaults
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    
    /// Image downloader model
    @ObservedObject var assetModel: AssetModel = AssetModel(path: "")

}

// MARK: - Fetch categories from Firebase
extension DataManager {
    
    /// Fetch all watch faces categories
    func fetchCategories() {
        showLoading = true
        Firestore.firestore().collection("WatchCollections").getDocuments { snapshot, _ in
            DispatchQueue.main.async {
                self.showLoading = false
                self.categories = snapshot?.documents.map { CategoryModel.build($0) }.filter { !$0.title.isEmpty } ?? []
            }
        }
    }

}

// MARK: - Save selected Watch Face
extension DataManager {
    
    /// Get the watch face image and present the native share items view
    func saveCurrentWatchFace() {
        assetModel.image = nil
        assetModel.imageLocation = "\(selectedWatchFace).jpg"
        assetModel.fetchAsset()
        if let image = assetModel.image {
            let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            share.excludedActivityTypes = [.airDrop, .assignToContact, .addToReadingList, .copyToPasteboard, .message, .mail, .markupAsPDF, .openInIBooks, .print, .saveToCameraRoll]
            rootController?.present(share, animated: true, completion: nil)
        }
    }
    
}
