import Foundation
import Combine
import CoreLocation

/// Manages shelter data, filtering, and selection.
@MainActor
final class ShelterViewModel: ObservableObject {
    
    @Published var shelters: [Shelter] = []
    @Published var nearbyShelters: [Shelter] = []
    @Published var recommendedShelters: [Shelter] = []
    @Published var selectedShelter: Shelter?
    @Published var shelterDetail: Shelter?
    @Published var state: ViewState<[Shelter]> = .idle
    @Published var searchText: String = ""
    @Published var activeFilter: ShelterFilter = .nearest
    @Published var activeDisasterType: String = ""
    
    private let repository: ShelterRepository
    
    // MARK: - Integration hooks for Person 2
    var onShareWithFamily: ((Shelter) -> Void)?
    
    // MARK: - Integration hooks for Person 3
    var onSaveShelterOffline: ((Shelter) -> Void)?
    
    init(repository: ShelterRepository) {
        self.repository = repository
    }
    
    convenience init() {
        self.init(repository: ShelterRepository())
    }
    
    // MARK: - Filter Enum
    
    enum ShelterFilter: String, CaseIterable {
        case nearest     = "Nearest"
        case recommended = "Recommended"
        case available   = "Available"
        case medical     = "Medical"
        case highGround  = "High Ground"
        case petFriendly = "Pet Friendly"
    }
    
    // MARK: - Fetch
    
    func fetchAllShelters() async {
        state = .loading
        do {
            let data = try await repository.fetchAllShelters()
            shelters = data
            state = data.isEmpty ? .empty : .loaded(data)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func fetchNearbyShelters(location: CLLocationCoordinate2D) async {
        await fetchNearbyShelters(location: location, radiusKm: AppConstants.defaultRadiusKm)
    }
    
    func fetchNearbyShelters(location: CLLocationCoordinate2D, radiusKm: Double) async {
        do {
            let data = try await repository.fetchNearbyShelters(
                lat: location.latitude,
                lng: location.longitude,
                radiusKm: radiusKm
            )
            nearbyShelters = data
        } catch {
            print("Failed to fetch nearby shelters: \(error.localizedDescription)")
        }
    }
    
    func fetchRecommendedShelters(location: CLLocationCoordinate2D, disasterType: String) async {
        do {
            let data = try await repository.fetchRecommendedShelters(
                lat: location.latitude,
                lng: location.longitude,
                disasterType: disasterType
            )
            recommendedShelters = data
        } catch {
            print("Failed to fetch recommended shelters: \(error.localizedDescription)")
        }
    }
    
    func fetchShelterDetail(id: Int) async {
        do {
            shelterDetail = try await repository.fetchShelter(id: id)
        } catch {
            print("Failed to fetch shelter detail: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Filtering
    
    var filteredShelters: [Shelter] {
        var result = nearbyShelters.isEmpty ? shelters : nearbyShelters
        
        // Search text filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Active filter
        switch activeFilter {
        case .nearest:
            result.sort { ($0.distanceKm ?? 999) < ($1.distanceKm ?? 999) }
        case .recommended:
            if !recommendedShelters.isEmpty {
                result = recommendedShelters
            } else {
                result.sort { ($0.distanceKm ?? 999) < ($1.distanceKm ?? 999) }
            }
        case .available:
            result = result.filter { $0.isActive }
        case .medical:
            result = result.filter { s in
                s.facilities.contains { f in f.localizedCaseInsensitiveContains("Medis") || f.localizedCaseInsensitiveContains("medical") }
            }
        case .highGround:
            result = result.filter { $0.buildingLevel >= 3 }
        case .petFriendly:
            result = result.filter { s in
                s.facilities.contains { f in f.localizedCaseInsensitiveContains("pet") || f.localizedCaseInsensitiveContains("hewan") }
            }
        }
        
        return result
    }
    
    // MARK: - Selection
    
    func selectShelter(_ shelter: Shelter) {
        selectedShelter = shelter
    }
    
    // MARK: - Find Nearest Available Shelter
    
    /// Finds the nearest shelter that is active.
    func findNearestAvailable(preferMedical: Bool = false) -> Shelter? {
        let candidates = (nearbyShelters.isEmpty ? shelters : nearbyShelters)
            .filter { $0.isActive }
            .sorted { ($0.distanceKm ?? 999) < ($1.distanceKm ?? 999) }
        
        if preferMedical, let medical = candidates.first(where: { s in
            s.facilities.contains { f in f.localizedCaseInsensitiveContains("Medis") || f.localizedCaseInsensitiveContains("medical") }
        }) {
            return medical
        }
        
        return candidates.first
    }
}

