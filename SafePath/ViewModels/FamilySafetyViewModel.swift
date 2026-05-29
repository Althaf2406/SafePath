import Foundation
import Combine

/// Person 2: Manages family group operations.
@MainActor
final class FamilySafetyViewModel: ObservableObject {

    // MARK: - Published State

    @Published var familyGroup: FamilyGroup?
    @Published var members: [FamilyMember] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let repository = FamilyRepository()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Group Actions

    /// POST /family/group — Creates a new family group.
    func createGroup(authToken: String, name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            familyGroup = try await repository.createGroup(authToken: authToken, name: name)
            members = familyGroup?.members ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// GET /family/group/:id — Fetches group details and refreshes members list.
    func fetchGroup(authToken: String, groupID: String) async {
        isLoading = true
        errorMessage = nil
        do {
            familyGroup = try await repository.fetchGroup(authToken: authToken, groupID: groupID)
            members = familyGroup?.members ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Member Actions

    /// POST /family/group/:id/invite — Invites a member by phone or email.
    func inviteMember(authToken: String, phone: String? = nil, email: String? = nil) async {
        guard let groupID = familyGroup?.id else { return }
        isLoading = true
        errorMessage = nil
        do {
            let newMember = try await repository.inviteMember(
                authToken: authToken,
                groupID: groupID,
                phone: phone,
                email: email
            )
            members.append(newMember)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// DELETE /family/group/:id/member/:memberId — Removes a member (admin only).
    func removeMember(authToken: String, memberID: String) async {
        guard let groupID = familyGroup?.id else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await repository.removeMember(authToken: authToken, groupID: groupID, memberID: memberID)
            members.removeAll { $0.id == memberID }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// PUT /family/group/:id/member/:memberId/status — Updates a member's safety status.
    func updateMemberStatus(authToken: String, memberID: String, status: FamilyMember.MemberStatus) async {
        guard let groupID = familyGroup?.id else { return }
        isLoading = true
        errorMessage = nil
        do {
            let updated = try await repository.updateMemberStatus(
                authToken: authToken,
                groupID: groupID,
                memberID: memberID,
                status: status
            )
            if let idx = members.firstIndex(where: { $0.id == memberID }) {
                members[idx] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Location Actions

    /// POST /family/location — Shares current user's location with the family group.
    func shareLocation(authToken: String, latitude: Double, longitude: Double) async {
        guard let groupID = familyGroup?.id else { return }
        errorMessage = nil
        do {
            try await repository.shareLocation(
                authToken: authToken,
                groupID: groupID,
                latitude: latitude,
                longitude: longitude
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// GET /family/group/:id/locations — Refreshes all member locations.
    func fetchFamilyLocations(authToken: String) async {
        guard let groupID = familyGroup?.id else { return }
        isLoading = true
        errorMessage = nil
        do {
            members = try await repository.fetchFamilyLocations(authToken: authToken, groupID: groupID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Helpers

    /// Clears any displayed error message.
    func clearError() {
        errorMessage = nil
    }
}
