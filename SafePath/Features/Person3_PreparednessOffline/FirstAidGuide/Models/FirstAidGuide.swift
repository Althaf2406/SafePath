import Foundation

/// Person 3: Represents a first aid guide topic.
struct FirstAidGuide: Codable, Identifiable {
    let id: String
    var title: String
    var category: String  // "cpr", "bleeding", "burns", "fractures", "choking"
    var steps: [String]
    var iconName: String?
    
    // TODO: Person 3 — Add images, video URLs, difficulty level, estimated time.
}
