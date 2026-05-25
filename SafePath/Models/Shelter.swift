import Foundation
import CoreLocation

/// Shelter status indicating availability.
enum ShelterStatus: String, Codable, CaseIterable {
    case available    = "available"
    case almostFull   = "almost_full"
    case full         = "full"
    case closed       = "closed"
    case unsafe       = "unsafe"
    
    var displayName: String {
        switch self {
        case .available:  return "Available"
        case .almostFull: return "Almost Full"
        case .full:       return "Full"
        case .closed:     return "Closed"
        case .unsafe:     return "Unsafe"
        }
    }
    
    /// Whether this shelter can accept evacuees.
    var isAccepting: Bool {
        self == .available || self == .almostFull
    }
}

/// A shelter/evacuation point fetched from the SafePath backend (PostgreSQL).
struct Shelter: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let capacityTotal: Int
    let capacityUsed: Int
    let availableSpace: Int
    let status: ShelterStatus
    let facilities: [String]
    let contactPhone: String?
    let source: String?
    let isVerified: Bool
    let lastUpdated: String?
    
    // Populated by nearby endpoint or client-side calculation
    var distanceKm: Double?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var capacityPercentage: Double {
        guard capacityTotal > 0 else { return 0 }
        return Double(capacityUsed) / Double(capacityTotal) * 100
    }
    
    /// Returns a human-readable facility name from the facility key.
    static func facilityDisplayName(_ key: String) -> String {
        switch key {
        case "water":         return "Water"
        case "food":          return "Food"
        case "medical":       return "Medical"
        case "toilet":        return "Toilet"
        case "charging":      return "Charging"
        case "sleeping_area": return "Sleeping Area"
        default:              return key.capitalized
        }
    }
    
    /// Returns an SF Symbol name for the facility key.
    static func facilityIcon(_ key: String) -> String {
        switch key {
        case "water":         return "drop.fill"
        case "food":          return "fork.knife"
        case "medical":       return "cross.case.fill"
        case "toilet":        return "toilet.fill"
        case "charging":      return "bolt.fill"
        case "sleeping_area": return "bed.double.fill"
        default:              return "building.2.fill"
        }
    }
}

// MARK: - Preview / Test Fixture

#if DEBUG
extension Shelter {
    static let preview = Shelter(
        id: "preview-shelter-1",
        name: "GOR Bung Tomo Surabaya",
        address: "Jl. Joyoboyo No.1, Sawunggaling, Wonokromo, Surabaya",
        latitude: -7.3071,
        longitude: 112.7358,
        capacityTotal: 2000,
        capacityUsed: 120,
        availableSpace: 1880,
        status: .available,
        facilities: ["water", "food", "toilet", "sleeping_area"],
        contactPhone: "031-5678901",
        source: "Pemerintah Kota Surabaya",
        isVerified: true,
        lastUpdated: "2024-12-01T10:00:00.000Z",
        distanceKm: 1.8
    )
    
    static let previewAlmostFull = Shelter(
        id: "preview-shelter-2",
        name: "Balai Pemuda Surabaya",
        address: "Jl. Gubernur Suryo No.15, Genteng, Surabaya",
        latitude: -7.2619,
        longitude: 112.7487,
        capacityTotal: 300,
        capacityUsed: 280,
        availableSpace: 20,
        status: .almostFull,
        facilities: ["water", "toilet", "charging"],
        contactPhone: "031-5347898",
        source: "Pemerintah Kota Surabaya",
        isVerified: true,
        lastUpdated: "2024-12-01T10:00:00.000Z",
        distanceKm: 3.2
    )
    
    static let previewList: [Shelter] = [preview, previewAlmostFull]
}
#endif
