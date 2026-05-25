import Foundation

/// Person 2: Manages emergency status updates and SOS triggers.
@MainActor
final class EmergencyStatusViewModel: ObservableObject {
    // TODO: Person 2 will implement SOS trigger, status update, and family notification.
    // TODO: Person 2 will use Person 1's onSOS and onMarkSafe hooks.
    
    @Published var currentStatus: EmergencyStatus?
    @Published var familyStatuses: [EmergencyStatus] = []
}
