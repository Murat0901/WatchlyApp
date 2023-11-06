//
//  SettingsTabView.swift
//  Watchly
//
//  Created by Murat Menzilci on 1/31/22.
//

import SwiftUI
import StoreKit
import MessageUI
import PurchaseKit
import SuperwallKit
import RevenueCat

/// Main settings flow
struct SettingsTabView: View {
    
    @EnvironmentObject var manager: DataManager
    @State private var showLoadingView: Bool = false
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false, content: {
                HeaderView(title: "Settings", subtitle: " ")
                VStack {
                    if manager.isPremiumUser == true {
                        CustomHeader(title: "IN-APP PURCHASES")
                        InAppPurchasesView
                    }
                    CustomHeader(title: "TUTORIAL")
                    TutorialItemView
                    CustomHeader(title: "SPREAD THE WORD")
                    RatingShareView
                    CustomHeader(title: "SUPPORT & PRIVACY")
                    PrivacySupportView
                }.padding([.leading, .trailing], 18)
                Spacer(minLength: 100)
            }).ignoresSafeArea()
            
            /// Show loading view
            LoadingView(isLoading: $showLoadingView)
        }
        /// Hide the default navigation bar
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("").navigationBarHidden(true)
    }
    
    /// Create custom header view
    private func CustomHeader(title: String, subtitle: String? = nil) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).font(.system(size: 18, weight: .medium))
                if let subtitleText = subtitle {
                    Text(subtitleText)
                }
            }
            Spacer()
        }.foregroundColor(Color("TextColor"))
    }
    
    /// Custom settings item
    private func SettingsItem(title: String, icon: String, action: @escaping() -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            action()
        }, label: {
            HStack {
                Image(systemName: icon).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22, alignment: .center)
                Text(title).font(.system(size: 18))
                Spacer()
                Image(systemName: "chevron.right")
            }.foregroundColor(Color("TextColor")).padding()
        })
    }
    
    // MARK: - Tutorial option
    private var TutorialItemView: some View {
        VStack {
            SettingsItem(title: "How to Add a Watch Face?", icon: "questionmark.circle") {
                manager.fullScreenMode = .tutorial
            }
        }.padding([.top, .bottom], 5).background(
            Color("Secondary").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        ).padding(.bottom, 40)
    }
    
    // MARK: - In App Purchases
    private var InAppPurchasesView: some View {
        VStack {
            SettingsItem(title: "Upgrade Premium", icon: "crown") {
                Superwall.shared.register(event: "campaign_trigger")
            }
            Color("TextColor").frame(height: 1).opacity(0.2)
            SettingsItem(title: "Restore Purchases", icon: "arrow.clockwise") {
                showLoadingView = true
                showLoadingView = true
                Task {
                    do {
                        Purchases.shared.restorePurchases { (purchaserInfo, error) in
                            if let error = error {
                                // Handle error
                                print("Restore Failed: \(error.localizedDescription)")
                            } else if let info = purchaserInfo {
                                if info.entitlements["pro"]?.isActive == true {
                                    // Grant user premium access
                                    print("Restore Successful: User is premium")
                                    // Update the userIsPremium flag to true
                                    manager.isPremiumUser = true
                                } else {
                                    // User is not premium
                                    print("Restore Successful: User is not premium")
                                }
                            }
                            // Hide the loading view
                            showLoadingView = false
                        }
                    } catch {
                        // Handle the error
                        showLoadingView = false
                    }
                }
            }
        }.padding([.top, .bottom], 5).background(
            Color("Secondary").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        ).padding(.bottom, 40)
    }
    
    // MARK: - Rating and Share
    private var RatingShareView: some View {
        VStack {
            SettingsItem(title: "Rate App", icon: "star") {
                if let scene = UIApplication.shared.windows.first?.windowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
            Color("TextColor").frame(height: 1).opacity(0.2)
            SettingsItem(title: "Share App", icon: "square.and.arrow.up") {
                let shareController = UIActivityViewController(activityItems: [AppConfig.yourAppURL], applicationActivities: nil)
                rootController?.present(shareController, animated: true, completion: nil)
            }
        }.padding([.top, .bottom], 5).background(
            Color("Secondary").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        ).padding(.bottom, 40)
    }
    
    // MARK: - Support & Privacy
    private var PrivacySupportView: some View {
        VStack {
            SettingsItem(title: "E-Mail us", icon: "envelope.badge") {
                EmailPresenter.shared.present()
            }
            Color("TextColor").frame(height: 1).opacity(0.2)
            SettingsItem(title: "Privacy Policy", icon: "hand.raised") {
                UIApplication.shared.open(AppConfig.privacyURL, options: [:], completionHandler: nil)
            }
            Color("TextColor").frame(height: 1).opacity(0.2)
            SettingsItem(title: "Terms of Use", icon: "doc.text") {
                UIApplication.shared.open(AppConfig.termsAndConditionsURL, options: [:], completionHandler: nil)
            }
        }.padding([.top, .bottom], 5).background(
            Color("Secondary").cornerRadius(15)
                .shadow(color: Color.black.opacity(0.07), radius: 10)
        )
    }
}

// MARK: - Preview UI
struct SettingsTabView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTabView().environmentObject(DataManager())
    }
}

// MARK: - Mail presenter for SwiftUI
class EmailPresenter: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailPresenter()
    private override init() { }
    
    func present() {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: "Email Simulator", message: "Email is not supported on the simulator. This will work on a physical device only.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            rootController?.present(alert, animated: true, completion: nil)
            return
        }
        let picker = MFMailComposeViewController()
        picker.setToRecipients([AppConfig.emailSupport])
        picker.mailComposeDelegate = self
        rootController?.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        rootController?.dismiss(animated: true, completion: nil)
    }
}
