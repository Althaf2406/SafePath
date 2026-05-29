import Foundation

/// Person 2: Repository for family group API calls.
/// Connects to Express backend family endpoints via APIService.
final class FamilyRepository {

    private let api = APIService.shared

    // MARK: - Group Endpoints

    /// POST /family/group
    func createGroup(authToken: String, name: String) async throws -> FamilyGroup {
        let body: [String: Any] = ["name": name]
        return try await api.send(.createFamilyGroup, authToken: authToken, body: body)
    }

    /// GET /family/group/:groupId
    func fetchGroup(authToken: String, groupID: String) async throws -> FamilyGroup {
        return try await api.send(.fetchFamilyGroup(groupID: groupID), authToken: authToken)
    }

    /// GET /family/groups
    func fetchAllGroups(authToken: String) async throws -> [FamilyGroup] {
        return try await api.send(.fetchAllFamilyGroups, authToken: authToken)
    }

    // MARK: - Member Endpoints

    /// POST /family/group/:groupId/invite
    func inviteMember(
        authToken: String,
        groupID: String,
        phone: String? = nil,
        email: String? = nil
    ) async throws -> FamilyMember {
        var body: [String: Any] = [:]
        if let phone = phone { body["phone"] = phone }
        if let email = email { body["email"] = email }

        return try await api.send(.inviteFamilyMember(groupID: groupID), authToken: authToken, body: body)
    }

    /// DELETE /family/group/:groupId/member/:memberId
    func removeMember(authToken: String, groupID: String, memberID: String) async throws {
        try await api.sendVoid(.removeFamilyMember(groupID: groupID, memberID: memberID), authToken: authToken)
    }

    /// PUT /family/group/:groupId/member/:memberId/status
    func updateMemberStatus(
        authToken: String,
        groupID: String,
        memberID: String,
        status: FamilyMember.MemberStatus
    ) async throws -> FamilyMember {
        let body: [String: Any] = ["status": status.rawValue]
        return try await api.send(
            .updateFamilyMemberStatus(groupID: groupID, memberID: memberID),
            authToken: authToken,
            body: body
        )
    }

    // MARK: - Location Endpoints

    /// POST /family/location
    func shareLocation(
        authToken: String,
        groupID: String,
        latitude: Double,
        longitude: Double
    ) async throws {
        let body: [String: Any] = [
            "group_id":  groupID,
            "latitude":  latitude,
            "longitude": longitude
        ]
        try await api.sendVoid(.shareLocation, authToken: authToken, body: body)
    }

    /// GET /family/group/:groupId/locations
    func fetchFamilyLocations(authToken: String, groupID: String) async throws -> [FamilyMember] {
        return try await api.send(.fetchFamilyLocations(groupID: groupID), authToken: authToken)
    }
}
