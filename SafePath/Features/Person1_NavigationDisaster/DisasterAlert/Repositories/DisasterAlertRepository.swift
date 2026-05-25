import Foundation

/// Fetches disaster alert data from the SafePath Express backend.
final class DisasterAlertRepository {
    
    private let api: APIService
    
    init(api: APIService = .shared) {
        self.api = api
    }
    
    /// Fetch all disaster alerts.
    func fetchAllAlerts() async throws -> [DisasterAlert] {
        return try await api.fetchData(.disasterAlerts)
    }
    
    /// Fetch disaster alerts near a coordinate.
    func fetchNearbyAlerts(lat: Double, lng: Double, radiusKm: Double = AppConstants.alertProximityThresholdKm) async throws -> [DisasterAlert] {
        return try await api.fetchData(.nearbyAlerts(lat: lat, lng: lng, radiusKm: radiusKm))
    }
}
