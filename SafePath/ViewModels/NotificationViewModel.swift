import Foundation
import Combine

/// Person 2: Manages notification list and read state.
@MainActor
final class NotificationViewModel: ObservableObject {
    // TODO: Person 2 will implement notification list, mark read, clear, and badge count.
    // TODO: Person 2 will receive notifications from Person 1's disaster alert triggers.
    
    @Published var notifications: [FamilyNotification] = []
    @Published var unreadCount: Int = 0
}
