import Foundation

/// Person 3: Manages preparedness reminders and scheduling.
@MainActor
final class PreparednessViewModel: ObservableObject {
    // TODO: Person 3 will implement reminder CRUD, scheduling, and notification triggers.
    
    @Published var reminders: [PreparednessReminder] = []
}
