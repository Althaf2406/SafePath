import Foundation

/// Represents a registered SafePath user.
struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var phone: String?
    var profileImageURL: String?
    var createdAt: Date?
    
    // TODO: Person 2 — Add authentication tokens, password hash, etc.
    // TODO: Person 2 — Add family group references.
}
