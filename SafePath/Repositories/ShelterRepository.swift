import Foundation

/// Fetches shelter data from the SafePath Express backend (PostgreSQL-backed).
final class ShelterRepository {
    
    private let api: APIService
    
    init(api: APIService = .shared) {
        self.api = api
    }
    
    /// Fetch all shelters.
    func fetchAllShelters() async throws -> [Shelter] {
        return try await api.fetchData(.shelters)
    }
    
    /// Fetch a single shelter by ID.
    func fetchShelter(id: Int) async throws -> Shelter {
        return try await api.fetchData(.shelterDetail(id: id))
    }
    
    /// Fetch nearby shelters within radius.
    func fetchNearbyShelters(lat: Double, lng: Double, radiusKm: Double = AppConstants.defaultRadiusKm) async throws -> [Shelter] {
        return try await api.fetchData(.nearbyShelters(lat: lat, lng: lng, radiusKm: radiusKm))
    }
    
    /// Fetch recommended shelters based on location and disaster type.
    func fetchRecommendedShelters(lat: Double, lng: Double, disasterType: String) async throws -> [Shelter] {
        return try await api.fetchData(.recommendedShelters(lat: lat, lng: lng, disasterType: disasterType))
    }
}

