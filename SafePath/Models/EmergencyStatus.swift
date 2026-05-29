import Foundation
import Combine

/// Person 2: Represents emergency status for a user.
struct EmergencyStatus: Codable, Identifiable {
    let id: String
    var userId: String
    var status: String  // "safe", "need_help", "evacuating", "unknown"
    var message: String?
    var latitude: Double?
    var longitude: Double?
    var updatedAt: Date?
    
    // TODO: Person 2 — Add SOS details, responder info, escalation level.
}
