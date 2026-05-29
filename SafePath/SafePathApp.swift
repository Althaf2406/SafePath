import SwiftUI
import Combine

@main
struct SafePathApp: App {
    @StateObject private var locationService = LocationService()
    
    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(locationService)
                .onAppear {
                    locationService.requestPermission()
                }
        }
    }
}
