import Foundation
import Combine

/// Person 2: Manages user registration, login, logout, and profile.
@MainActor
final class UserManagementViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let repository = UserRepository()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Auth Actions

    /// POST /auth/register — Registers a new user account.
    func register(name: String, email: String, password: String, phone: String? = nil) async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await repository.register(name: name, email: email, password: password, phone: phone)
            currentUser = user
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// POST /auth/login — Authenticates user and stores session.
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await repository.login(email: email, password: password)
            currentUser = user
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// POST /auth/logout — Logs out and clears local session.
    func logout() async {
        guard let token = currentUser?.authToken else {
            currentUser = nil
            isLoggedIn = false
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await repository.logout(authToken: token)
        } catch {
            errorMessage = error.localizedDescription
        }
        currentUser = nil
        isLoggedIn = false
        isLoading = false
    }

    // MARK: - Profile Actions

    /// GET /user/profile — Fetches the latest profile from backend.
    func fetchProfile() async {
        guard let token = currentUser?.authToken else { return }
        isLoading = true
        errorMessage = nil
        do {
            currentUser = try await repository.fetchProfile(authToken: token)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// PUT /user/profile — Updates name, phone, or profile image.
    func updateProfile(name: String? = nil, phone: String? = nil, profileImageURL: String? = nil) async {
        guard let token = currentUser?.authToken else { return }
        isLoading = true
        errorMessage = nil
        do {
            currentUser = try await repository.updateProfile(
                authToken: token,
                name: name,
                phone: phone,
                profileImageURL: profileImageURL
            )
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
