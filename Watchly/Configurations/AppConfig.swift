//
//  AppConfig.swift
//  Watchly
//
//  Created by Murat Menzilci on 1/31/22.
//

import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {
    
    /// This is the AdMob Interstitial ad id
    /// Test App ID: ca-app-pub-3940256099942544~1458002511
    //static let adMobAdId: String = "ca-app-pub-3940256099942544/4411468910"
    //static let adMobFrequency: Int = 2 /// every 2 watch faces preview
    
    // MARK: - Settings flow items
    static let emailSupport = "menzilcim@gmail.com"
    static let privacyURL: URL = URL(string: "https://muratworks.com/?p=69")!
    static let termsAndConditionsURL: URL = URL(string: "https://muratworks.com/?p=71")!
    static let yourAppURL: URL = URL(string: "https://apps.apple.com/app/id6470202238")!
    
    // MARK: - Generic configurations
    static let maxRowItems: Int = 5
    
    // MARK: - In App Purchases
    static let premiumVersion: String = "Watchly.Premium"
}

// MARK: - Custom tab bar items
enum CustomTabBarItem: String, CaseIterable, Identifiable {
    case gallery, settings, tutorial
    var id: Int { hashValue }
    
    /// Tab bar item icon
    var icon: String {
        switch self {
        case .gallery:
            return "square.grid.2x2"
        case .settings:
            return "gearshape"
        case .tutorial:
            return "book.circle"
        }
    }
}
