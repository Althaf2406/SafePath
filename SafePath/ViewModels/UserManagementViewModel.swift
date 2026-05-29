import Foundation
import Combine

/// Person 2: Manages user registration, login, logout, and profile.
@MainActor
final class UserManagementViewModel: ObservableObject {
    // TODO: Person 2 will implement user registration, login, logout, and profile management.
    // TODO: Person 2 will store auth tokens securely and manage session state.
    // TODO: Person 2 will expose currentUser published property for other features.
    
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
}
