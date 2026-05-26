import Foundation

/// Handles offline JSON local caching using UserDefaults.
final class LocalStorageService {
    
    static let shared = LocalStorageService()
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {}
    
    func save<T: Encodable>(_ object: T, forKey key: String) {
        do {
            let data = try encoder.encode(object)
            defaults.set(data, forKey: key)
        } catch {
            print("Offline Cache Error (save): \(error.localizedDescription)")
        }
    }
    
    func load<T: Decodable>(forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Offline Cache Error (load): \(error.localizedDescription)")
            return nil
        }
    }
    
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}

