//
//  smallGaolApp.swift
//  smallGaol
//
//  Created by Apple on 2024/03/20.
//

import SwiftUI
import Firebase

@main
struct smallGaolApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            TopView()
//            Interstitial1()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    var goalViewModel = GoalViewModel() // GoalViewModelのインスタンスをプロパティとして追加

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "hasLaunchedBefore") {
            let authManager = AuthManager()
            authManager.anonymousSignIn(){
                DispatchQueue.main.async {
                    // createUserの完了を待ってからisLoadingを更新
                    authManager.createUser() {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        DispatchQueue.main.async {
                            self.goalViewModel.createSampleGoal()
                            self.goalViewModel.createSampleReward()
                            self.goalViewModel.isLoading = false // ここでisLoadingを更新
                            print("USERID:\(authManager.currentUserId!)")
                        }
                    }
                }
            }
            userDefaults.set(true, forKey: "hasLaunchedBefore")
            userDefaults.synchronize()
        }
        return true
    }
}


