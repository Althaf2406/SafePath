import Foundation
import Combine

/// Person 2: Manages family group operations.
@MainActor
final class FamilySafetyViewModel: ObservableObject {
    // TODO: Person 2 will implement create group, invite member, remove member, update status.
    // TODO: Person 2 will use Person 1's selectedShelter and currentRoute for family sharing.
    
    @Published var familyGroup: FamilyGroup?
    @Published var members: [FamilyMember] = []
}
