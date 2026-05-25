import Foundation

/// Person 2: Represents a notification sent to family members.
struct FamilyNotification: Codable, Identifiable {
    let id: String
    var title: String
    var body: String
    var type: String  // "alert", "sos", "status_update", "route_shared"
    var timestamp: Date?
    var isRead: Bool
    
    // TODO: Person 2 — Add sender info, deep link action, priority.
}
