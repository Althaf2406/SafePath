import Foundation

/// Represents a registered SafePath user.
struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var phone: String?
    var profileImageURL: String?
    var createdAt: Date?

    // Person 2 — Authentication & family references
    var authToken: String?
    var refreshToken: String?
    var familyGroupIDs: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case profileImageURL  = "profile_image_url"
        case createdAt        = "created_at"
        case authToken        = "auth_token"
        case refreshToken     = "refresh_token"
        case familyGroupIDs   = "family_group_ids"
    }

    // MARK: - Helpers

    /// Returns true when the user has a valid auth token present.
    var isAuthenticated: Bool {
        authToken != nil && !(authToken!.isEmpty)
    }

    /// Returns true when the user belongs to at least one family group.
    var hasFamilyGroup: Bool {
        !familyGroupIDs.isEmpty
    }

    // MARK: - Init

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        phone: String? = nil,
        profileImageURL: String? = nil,
        createdAt: Date? = Date(),
        authToken: String? = nil,
        refreshToken: String? = nil,
        familyGroupIDs: [String] = []
    ) {
        self.id              = id
        self.name            = name
        self.email           = email
        self.phone           = phone
        self.profileImageURL = profileImageURL
        self.createdAt       = createdAt
        self.authToken       = authToken
        self.refreshToken    = refreshToken
        self.familyGroupIDs  = familyGroupIDs
    }
}
