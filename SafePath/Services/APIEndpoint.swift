import Foundation

/// Defines all SafePath API endpoint paths.
enum APIEndpoint {
    case disasterAlerts
    case nearbyAlerts(lat: Double, lng: Double, radiusKm: Double)
    case weatherAlert(adm4: String)
    case shelters
    case shelterDetail(id: String)
    case nearbyShelters(lat: Double, lng: Double, radiusKm: Double)
    case updateShelterStatus(id: String)
    
    var path: String {
        switch self {
        case .disasterAlerts:
            return "/disaster-alert"
        case .nearbyAlerts(let lat, let lng, let radiusKm):
            return "/disaster-alert/nearby?lat=\(lat)&lng=\(lng)&radiusKm=\(radiusKm)"
        case .weatherAlert(let adm4):
            return "/weather-alert?adm4=\(adm4)"
        case .shelters:
            return "/shelters"
        case .shelterDetail(let id):
            return "/shelters/\(id)"
        case .nearbyShelters(let lat, let lng, let radiusKm):
            return "/shelters/nearby?lat=\(lat)&lng=\(lng)&radiusKm=\(radiusKm)"
        case .updateShelterStatus(let id):
            return "/shelters/\(id)/status"
        }
    }
    
    var method: String {
        switch self {
        case .updateShelterStatus:
            return "PATCH"
        default:
            return "GET"
        }
    }
    
    /// Full URL combining base URL and path.
    var url: URL? {
        URL(string: AppConstants.apiBaseURL + path)
    }
}
