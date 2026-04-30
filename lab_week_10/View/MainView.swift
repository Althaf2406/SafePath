// MARK: - StoryApp.swift
// Entry point aplikasi
// Pastikan GoogleService-Info.plist sudah ditambahkan ke project

import SwiftUI
import FirebaseAuth
import FirebaseCore

@main
struct StoryApp: App {
    @StateObject private var authVM = AuthViewModel()

    // Register Firebase AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
        }
    }
}

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
