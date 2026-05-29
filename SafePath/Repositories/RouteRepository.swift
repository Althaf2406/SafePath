import Foundation
import Combine
import MapKit

/// Generates real evacuation routes using MapKit MKDirections.
final class RouteRepository {
    
    /// Calculate a walking route from origin to a shelter coordinate using MapKit.
    func calculateRoute(
        from origin: CLLocationCoordinate2D,
        to shelter: Shelter
    ) async throws -> EvacuationRoute {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: shelter.coordinate))
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        
        guard let primaryRoute = response.routes.first else {
            throw RouteError.noRouteFound
        }
        
        return EvacuationRoute(
            id: UUID().uuidString,
            shelterId: String(shelter.id),
            shelterName: shelter.name,
            distanceMeters: primaryRoute.distance,
            expectedTravelTime: primaryRoute.expectedTravelTime,
            safetyScore: 0.85, // Placeholder — future risk layer integration
            mkRoute: primaryRoute
        )
    }
    
    /// Calculate route and return alternatives too.
    func calculateRouteWithAlternatives(
        from origin: CLLocationCoordinate2D,
        to shelter: Shelter
    ) async throws -> (primary: EvacuationRoute, alternatives: [EvacuationRoute]) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: shelter.coordinate))
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        
        guard let primaryMK = response.routes.first else {
            throw RouteError.noRouteFound
        }
        
        let primary = EvacuationRoute(
            id: UUID().uuidString,
            shelterId: String(shelter.id),
            shelterName: shelter.name,
            distanceMeters: primaryMK.distance,
            expectedTravelTime: primaryMK.expectedTravelTime,
            safetyScore: 0.85,
            mkRoute: primaryMK
        )
        
        let alternatives = response.routes.dropFirst().map { route in
            EvacuationRoute(
                id: UUID().uuidString,
                shelterId: String(shelter.id),
                shelterName: shelter.name,
                distanceMeters: route.distance,
                expectedTravelTime: route.expectedTravelTime,
                safetyScore: 0.75,
                mkRoute: route
            )
        }
        
        return (primary, Array(alternatives))
    }
}

// MARK: - Route Error

enum RouteError: LocalizedError {
    case noRouteFound
    case calculationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noRouteFound:
            return "No evacuation route found to this shelter."
        case .calculationFailed(let err):
            return "Route calculation failed: \(err.localizedDescription)"
        }
    }
}
