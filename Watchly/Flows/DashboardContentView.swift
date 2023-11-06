//
//  DashboardContentView.swift
//  Watchly
//
//  Created by Murat Menzilci on 1/31/22.
//

import SwiftUI
import StoreKit
import RevenueCat
import SuperwallKit

struct OnboardingView: View {
    @AppStorage("isOnboardingViewShowing") var isOnboardingViewShowing = true
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @State private var onboardingPageIndex: Int = 0
    let onboardingPages: [(imageName: String, title: String, description: String)] = [
        ("onboarding-1", "Watch Faces Gallery", "Personalize your Apple Watch Face with designed faces and collection."),
        ("onboarding-2", "Personilze Your Apple Watch", "Amazing Collection of Apple Watch Faces and Complications all in one app."),
        ("onboarding-3", "Help Us Grow", "Give us 5 stars to support us! We really appreciate your support!")
    ]

    var body: some View {
        if isOnboardingViewShowing {
            ZStack {
                VStack {
                    OnboardingScreen(imageName: onboardingPages[onboardingPageIndex].imageName, title: onboardingPages[onboardingPageIndex].title, description: onboardingPages[onboardingPageIndex].description)
                    Spacer() // Push the button to the bottom
                }
                
                VStack {
                    Spacer()
                    Button(action: {
                        if onboardingPageIndex == 1 {
                            // Request rating when the second "Continue" button is clicked
                            if let scene = UIApplication.shared.windows.first?.windowScene {
                                SKStoreReviewController.requestReview(in: scene)
                            }
                        }

                        if onboardingPageIndex < onboardingPages.count - 1 {
                            onboardingPageIndex += 1
                        } else {
                            UserDefaults.standard.set(false, forKey: "isOnboardingViewShowing")
                            if isFirstLaunch {
                                // Trigger campaign and show paywall here
                                Superwall.shared.register(event: "campaign_trigger")
                                isFirstLaunch = false
                                // Add code to show the paywall
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 15) // Vertical padding for button height
                        .background(Color.blue) // Background color of the button
                    }
                    .cornerRadius(10)
                    .padding(.horizontal, 15) // Horizontal padding for space from the sides
                    .padding(.bottom, 35) // Add padding at the bottom
                }


            }
            .background(Color.black.ignoresSafeArea())
            .foregroundColor(Color.primary)
            .navigationBarHidden(true)
            .onAppear{
                /*
                 DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                     if #available(iOS 14, *) {
                         ATTrackingManager.requestTrackingAuthorization { (status) in
                             //print("IDFA STATUS: \(status.rawValue)")
                         }
                     }
                 }
                 */
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    fetchUserSubscriptionStatus()
                }
            }
        } else {
            DashboardContentView()
        }
    }

     func fetchUserSubscriptionStatus() {
         Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
             guard let proEntitlement = purchaserInfo?.entitlements["pro"], proEntitlement.isActive else {
                 return
             }
         }
     }
}



struct OnboardingScreen: View {
    var imageName: String
    var title: String
    var description: String

    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: UIScreen.main.bounds.height / 2) // Set max height to half of what you want to show
                .padding()
            Text(title)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text(description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer() // To push content to the top
        }
        .padding(.top, 50) // Add some top padding to prevent content from sticking to the top edge
    }
}

/// Main dasbhboard flow for the app
struct DashboardContentView: View {
    
    @EnvironmentObject var manager: DataManager
    
    // MARK: - Main rendering function
    var body: some View {
        NavigationView {
            ZStack {
                TabView {
                    GalleryTabView().environmentObject(manager)
                        .tabItem { TabItemView(tab: .gallery) }
                    
                    TutorialContentView().environmentObject(manager)
                        .tabItem { TabItemView(tab: .tutorial) }
                    
                    SettingsTabView().environmentObject(manager)
                        .tabItem { TabItemView(tab: .settings) }
                }
                .blur(radius: manager.selectedWatchFace.isEmpty ? 0 : 15)
                .fullScreenCover(item: $manager.fullScreenMode) { type in
                    switch type {
                    case .premium:
                        PremiumContentView(title: "Premium Version", subtitle: "Upgrade Today", features: ["Remove ads", "Unlock all categories"], productIds: [AppConfig.premiumVersion]) { _, status, _ in
                            DispatchQueue.main.async {
                                Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
                                    if let customerInfo = purchaserInfo {
                                        if customerInfo.entitlements.all["pro"] != nil {
                                            // User is a pro user, proceed with presenting the document camera
                                            manager.isPremiumUser = true
                                        }
                                    }
                                    manager.fullScreenMode = nil
                                }
                            }
                        }
                    case .tutorial:
                        TutorialContentView()
                    }
                }
                
                /// Full screen watch face preview
                if !manager.selectedWatchFace.isEmpty {
                    WatchFacePreview().environmentObject(manager)
                }
            }
            /// Hide the default navigation bar
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("").navigationBarHidden(true)
            
        }.accentColor(Color.white)
    }
    
    /// Create tab item
    private func TabItemView(tab: CustomTabBarItem) -> some View {
        VStack {
            Image(systemName: tab.icon)
            Text(tab.rawValue.capitalized)
        }
    }
}

// MARK: - Preview UI
struct DashboardContentView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardContentView().environmentObject(DataManager())
    }
}
