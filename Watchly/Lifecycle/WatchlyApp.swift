//
//  WatchlyApp.swift
//  Watchly
//
//  Created by Murat Menzilci on 1/31/22.
//

import SwiftUI
import Firebase
import PurchaseKit
//import GoogleMobileAds
import RevenueCat
import SuperwallKit

@main
struct WatchlyApp: App {
    
    @StateObject private var manager: DataManager = DataManager()
    
    /// Default init method. Any initial configurations goes here, similar to the old way of using AppDelegate
    init() {
        
        Purchases.configure(withAPIKey: "appl_sScKugakSTKaWSLJyjlLVswsVXS", appUserID: nil)
        Superwall.configure(apiKey: "pk_e27941f0e7a6dc03062e46c488b17334aa0a2697e87f2766")
        FirebaseApp.configure()
        PKManager.loadProducts(identifiers: [AppConfig.premiumVersion])
        //GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    // MARK: - Main rendering function
    var body: some Scene {
        WindowGroup {
            OnboardingView().environmentObject(manager)
        }
    }
}

// MARK: - Present an alert from anywhere in the app
func presentAlert(title: String, message: String, primaryAction: UIAlertAction = .ok, secondaryAction: UIAlertAction? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(primaryAction)
    if let secondary = secondaryAction { alert.addAction(secondary) }
    rootController?.present(alert, animated: true, completion: nil)
}

extension UIAlertAction {
    static var ok: UIAlertAction {
        UIAlertAction(title: "OK", style: .cancel, handler: nil)
    }
}

var rootController: UIViewController? {
    var root = UIApplication.shared.windows.first?.rootViewController
    if let presenter = root?.presentedViewController { root = presenter }
    return root
}

/// Show a loading indicator view
struct LoadingView: View {
    
    @Binding var isLoading: Bool
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            if isLoading {
                Color.black.edgesIgnoringSafeArea(.all).opacity(0.4)
                ProgressView("please wait...")
                    .scaleEffect(1.1, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white).padding()
                    .background(RoundedRectangle(cornerRadius: 10).opacity(0.7))
            }
        }.colorScheme(.light)
    }
}


// MARK: - Google AdMob Interstitial - Support class
/*

class Interstitial: NSObject, GADFullScreenContentDelegate {
    var isPremiumUser: Bool = UserDefaults.standard.bool(forKey: AppConfig.premiumVersion)
    private var interstitial: GADInterstitialAd?
    private var presentedCount: Int = 0
    static var shared: Interstitial = Interstitial()
    
    /// Default initializer of interstitial class
    override init() {
        super.init()
        loadInterstitial()
    }
    
    /// Request AdMob Interstitial ads
 func loadInterstitial() {
     let request = GADRequest()
     GADInterstitialAd.load(withAdUnitID: AppConfig.adMobAdId, request: request, completionHandler: { [self] ad, error in
         if ad != nil { interstitial = ad }
         interstitial?.fullScreenContentDelegate = self
     })
 }
 
 func showInterstitialAds() {
     presentedCount += 1
     if self.interstitial != nil, presentedCount % AppConfig.adMobFrequency == 0, !isPremiumUser {
         var root = UIApplication.shared.windows.first?.rootViewController
         if let presenter = root?.presentedViewController { root = presenter }
         self.interstitial?.present(fromRootViewController: root!)
     }
     if self.interstitial == nil { loadInterstitial() }
 }
 
 func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
     loadInterstitial()
 }
 */
