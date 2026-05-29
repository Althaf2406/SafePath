import Foundation
import Combine

/// Priority level for checklist items.
enum ChecklistPriority: String, Codable, CaseIterable {
    case high   = "High"
    case medium = "Medium"
    case low    = "Low"
    
    // TODO: Person 3 — Extend with sorting, color mapping, etc.
}

/// Person 3: A single item in an emergency checklist.
struct ChecklistItem: Codable, Identifiable {
    let id: String
    var name: String
    var isChecked: Bool
    var category: String
    var quantity: Int?
    var priority: ChecklistPriority
    var disasterType: String?
    
    // TODO: Person 3 — Add expiry date, photo, notes.
}

// MARK: - Preview / Test Fixture

#if DEBUG
extension ChecklistItem {
    static let previewItems: [ChecklistItem] = [
        ChecklistItem(id: "1", name: "Water bottle", isChecked: true, category: "Food & Water", quantity: 2, priority: .high, disasterType: nil),
        ChecklistItem(id: "2", name: "Instant food", isChecked: true, category: "Food & Water", quantity: 3, priority: .high, disasterType: nil),
        ChecklistItem(id: "3", name: "First aid kit", isChecked: false, category: "Medical", quantity: 1, priority: .high, disasterType: nil),
        ChecklistItem(id: "4", name: "Flashlight", isChecked: false, category: "Tools", quantity: 1, priority: .high, disasterType: nil),
        ChecklistItem(id: "5", name: "Extra batteries", isChecked: false, category: "Tools", quantity: 4, priority: .medium, disasterType: nil),
        ChecklistItem(id: "6", name: "Whistle", isChecked: true, category: "Tools", quantity: 1, priority: .medium, disasterType: nil),
        ChecklistItem(id: "7", name: "Bandages", isChecked: true, category: "Medical", quantity: 5, priority: .high, disasterType: nil),
        ChecklistItem(id: "8", name: "Face mask", isChecked: false, category: "Medical", quantity: 3, priority: .medium, disasterType: nil),
        ChecklistItem(id: "9", name: "Rain poncho", isChecked: true, category: "Documents", quantity: 1, priority: .low, disasterType: "Flood"),
        ChecklistItem(id: "10", name: "ID documents copy", isChecked: true, category: "Documents", quantity: 1, priority: .high, disasterType: nil),
        ChecklistItem(id: "11", name: "Cash reserves", isChecked: true, category: "Documents", quantity: nil, priority: .high, disasterType: nil),
        ChecklistItem(id: "12", name: "Water purifier", isChecked: false, category: "Food & Water", quantity: 2, priority: .medium, disasterType: "Flood")
    ]
}
#endif
