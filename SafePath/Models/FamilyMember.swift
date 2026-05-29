import Foundation
import Combine

/// Person 2: Represents a member in a family group.
struct FamilyMember: Codable, Identifiable {
    let id: String
    var name: String
    var phone: String?
    var isSafe: Bool?
    var lastLatitude: Double?
    var lastLongitude: Double?
    var lastUpdated: Date?
    
    // TODO: Person 2 — Add role (admin/member), status, avatar, etc.
}
