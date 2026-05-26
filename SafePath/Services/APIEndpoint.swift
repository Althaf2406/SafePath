import Foundation

/// Defines all SafePath API endpoint paths.
enum APIEndpoint {
    case disasterAlerts
    case nearbyAlerts(lat: Double, lng: Double, radiusKm: Double)
    case weatherAlert(adm4: String)
    case shelters
    case shelterDetail(id: Int)
    case nearbyShelters(lat: Double, lng: Double, radiusKm: Double)
    case recommendedShelters(lat: Double, lng: Double, disasterType: String)
    case evacuationRoute(originLat: Double, originLng: Double, destLat: Double, destLng: Double)
    
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
        case .recommendedShelters(let lat, let lng, let disasterType):
            return "/shelters/recommended?lat=\(lat)&lng=\(lng)&disasterType=\(disasterType)"
        case .evacuationRoute(let originLat, let originLng, let destLat, let destLng):
            return "/evacuation-route?originLat=\(originLat)&originLng=\(originLng)&destLat=\(destLat)&destLng=\(destLng)"
        }
    }
    
    var method: String {
        return "GET"
    }
    
    /// Full URL combining base URL and path.
    var url: URL? {
        URL(string: AppConstants.apiBaseURL + path)
    }
}

