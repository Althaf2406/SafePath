import Foundation

/// Person 3: Manages offline survival data, cache access, and offline emergency resources.
@MainActor
final class OfflineSurvivalViewModel: ObservableObject {
    // TODO: Person 3 will implement offline survival data, cache access, and offline emergency resources.
    // TODO: Person 3 will use Person 1's onSaveShelterOffline, onSaveRouteOffline, onSaveAlertOffline hooks.
    
    @Published var offlineData: OfflineSurvivalData?
    @Published var isOfflineMode: Bool = false
}
