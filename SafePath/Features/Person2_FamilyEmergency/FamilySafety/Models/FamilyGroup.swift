import Foundation

/// Person 2: Represents a family group for emergency coordination.
struct FamilyGroup: Codable, Identifiable {
    let id: String
    var name: String
    var members: [FamilyMember]
    var createdAt: Date?
    
    // TODO: Person 2 — Add invite code, group settings, admin role.
}
