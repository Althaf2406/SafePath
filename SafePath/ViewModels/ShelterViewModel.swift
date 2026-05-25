import Foundation
import CoreLocation

/// Manages shelter data, filtering, and selection.
@MainActor
final class ShelterViewModel: ObservableObject {
    
    @Published var shelters: [Shelter] = []
    @Published var nearbyShelters: [Shelter] = []
    @Published var selectedShelter: Shelter?
    @Published var shelterDetail: Shelter?
    @Published var state: ViewState<[Shelter]> = .idle
    @Published var searchText: String = ""
    @Published var activeFilter: ShelterFilter = .nearest
    
    private let repository: ShelterRepository
    
    // MARK: - Integration hooks for Person 2
    var onShareWithFamily: ((Shelter) -> Void)?
    
    // MARK: - Integration hooks for Person 3
    var onSaveShelterOffline: ((Shelter) -> Void)?
    
    init(repository: ShelterRepository = ShelterRepository()) {
        self.repository = repository
    }
    
    // MARK: - Filter Enum
    
    enum ShelterFilter: String, CaseIterable {
        case nearest     = "Nearest"
        case available   = "Available"
        case medical     = "Medical"
        case highGround  = "High Ground"
        case petFriendly = "Pet Friendly"
        case hasCharging = "Has Charging"
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
    
    func fetchNearbyShelters(location: CLLocationCoordinate2D, radiusKm: Double = AppConstants.defaultRadiusKm) async {
        do {
            let data = try await repository.fetchNearbyShelters(
                lat: location.latitude,
                lng: location.longitude,
                radiusKm: radiusKm
            )
            nearbyShelters = data
            if case .idle = state {} else {
                // Also update main list if already loaded
            }
        } catch {
            print("Failed to fetch nearby shelters: \(error.localizedDescription)")
        }
    }
    
    func fetchShelterDetail(id: String) async {
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
        case .available:
            result = result.filter { $0.status.isAccepting }
        case .medical:
            result = result.filter { $0.facilities.contains("medical") }
        case .highGround:
            // Placeholder — would require elevation data
            break
        case .petFriendly:
            // Placeholder — would require pet_friendly facility flag
            break
        case .hasCharging:
            result = result.filter { $0.facilities.contains("charging") }
        }
        
        return result
    }
    
    // MARK: - Selection
    
    func selectShelter(_ shelter: Shelter) {
        selectedShelter = shelter
    }
    
    // MARK: - Find Nearest Available Shelter
    
    /// Finds the nearest shelter that is accepting evacuees, preferring medical facilities during emergencies.
    func findNearestAvailable(preferMedical: Bool = false) -> Shelter? {
        let candidates = (nearbyShelters.isEmpty ? shelters : nearbyShelters)
            .filter { $0.status.isAccepting }
            .sorted { ($0.distanceKm ?? 999) < ($1.distanceKm ?? 999) }
        
        if preferMedical, let medical = candidates.first(where: { $0.facilities.contains("medical") }) {
            return medical
        }
        
        return candidates.first
    }
}
