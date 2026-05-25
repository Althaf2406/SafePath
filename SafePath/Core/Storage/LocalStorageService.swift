import Foundation

/// Placeholder for Person 3's offline local storage service.
/// Person 3 will implement persistent storage for offline shelter, route, and alert data.
final class LocalStorageService {
    
    static let shared = LocalStorageService()
    private init() {}
    
    // TODO: Person 3 — Implement UserDefaults / FileManager / Core Data storage for offline data.
    // TODO: Person 3 — Save shelter list for offline access.
    // TODO: Person 3 — Save route data for offline navigation.
    // TODO: Person 3 — Save disaster alert data for offline viewing.
    
    func save<T: Encodable>(_ object: T, forKey key: String) {
        // TODO: Person 3 will implement
    }
    
    func load<T: Decodable>(forKey key: String) -> T? {
        // TODO: Person 3 will implement
        return nil
    }
    
    func remove(forKey key: String) {
        // TODO: Person 3 will implement
    }
}
