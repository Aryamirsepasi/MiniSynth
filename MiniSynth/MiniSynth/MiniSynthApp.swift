//
//  MiniSynthApp.swift
//  MiniSynth
//
//  Created by Arya Mirsepasi on 23.05.25.
//

import SwiftUI

@main
struct MiniSynthApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .statusBarHidden(false)
                // Force landscape orientation
                .onAppear {
                    AppDelegate.orientationLock = .landscape
                }
        }
    }
}

// MARK: - App Delegate for orientation control
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.landscape
    
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
