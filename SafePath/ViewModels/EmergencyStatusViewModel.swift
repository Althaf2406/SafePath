import Foundation
import Combine

/// Person 2: Manages emergency status updates and SOS triggers.
@MainActor
final class EmergencyStatusViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentStatus: EmergencyStatus?
    @Published var familyStatuses: [EmergencyStatus] = []
    @Published var isLoading: Bool = false
    @Published var isSOSActive: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let repository = EmergencyStatusRepository()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Status Actions

    /// POST /emergency/status — Updates the current user's emergency status.
    func updateStatus(
        authToken: String,
        status: EmergencyStatus.EmergencyStatusType,
        message: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        do {
            currentStatus = try await repository.updateStatus(
                authToken: authToken,
                status: status,
                message: message,
                latitude: latitude,
                longitude: longitude
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Convenience — marks user as safe and updates status.
    func markSafe(authToken: String, latitude: Double? = nil, longitude: Double? = nil) async {
        await updateStatus(authToken: authToken, status: .safe, latitude: latitude, longitude: longitude)
    }

    /// GET /emergency/family/:groupId/statuses — Fetches statuses for all family members.
    func fetchFamilyStatuses(authToken: String, groupID: String) async {
        isLoading = true
        errorMessage = nil
        do {
            familyStatuses = try await repository.fetchFamilyStatuses(authToken: authToken, groupID: groupID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - SOS Actions

    /// POST /emergency/sos — Triggers SOS and notifies all family members.
    func triggerSOS(
        authToken: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        message: String? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        do {
            currentStatus = try await repository.triggerSOS(
                authToken: authToken,
                latitude: latitude,
                longitude: longitude,
                message: message
            )
            isSOSActive = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// POST /emergency/sos/:id/resolve — Resolves an active SOS.
    func resolveSOS(authToken: String) async {
        guard let sosID = currentStatus?.id else { return }
        isLoading = true
        errorMessage = nil
        do {
            currentStatus = try await repository.resolveSOS(authToken: authToken, sosID: sosID)
            isSOSActive = false
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
