import Foundation
import Combine
import CoreLocation
import UserNotifications

/// View state for data-driven UI.
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(String)
}

/// Manages disaster alert data and local notification scheduling.
@MainActor
final class DisasterAlertViewModel: ObservableObject {
    
    @Published var allAlerts: [DisasterAlert] = []
    @Published var nearbyAlerts: [DisasterAlert] = []
    @Published var state: ViewState<[DisasterAlert]> = .idle
    @Published var selectedAlert: DisasterAlert?
    
    private let repository: DisasterAlertRepository
    
    // MARK: - Integration hooks for Person 2
    var onNotifyFamily: ((DisasterAlert) -> Void)?
    var onMarkSafe: (() -> Void)?
    
    // MARK: - Integration hooks for Person 3
    var onSaveAlertOffline: ((DisasterAlert) -> Void)?
    
    init(repository: DisasterAlertRepository) {
        self.repository = repository
    }
    
    convenience init() {
        self.init(repository: DisasterAlertRepository())
    }
    
    // MARK: - Fetch All Alerts
    
    func fetchAllAlerts() async {
        state = .loading
        do {
            let alerts = try await repository.fetchAllAlerts()
            allAlerts = alerts
            state = alerts.isEmpty ? .empty : .loaded(alerts)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Fetch Nearby Alerts
    
    func fetchNearbyAlerts(location: CLLocationCoordinate2D) async {
        await fetchNearbyAlerts(location: location, radiusKm: AppConstants.alertProximityThresholdKm)
    }
    
    func fetchNearbyAlerts(location: CLLocationCoordinate2D, radiusKm: Double) async {
        do {
            let alerts = try await repository.fetchNearbyAlerts(
                lat: location.latitude,
                lng: location.longitude,
                radiusKm: radiusKm
            )
            nearbyAlerts = alerts
            
            // Schedule local notifications for high-severity nearby alerts
            for alert in alerts where alert.severity == .critical || alert.severity == .high {
                scheduleLocalNotification(for: alert)
            }
        } catch {
            // Nearby fetch failure is non-fatal; keep existing data
            print("Failed to fetch nearby alerts: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Local Notification
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleLocalNotification(for alert: DisasterAlert) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ \(alert.typeDisplayName) — \(alert.severity.displayName)"
        content.body = "\(alert.locationName). Magnitudo \(alert.magnitude). \(alert.instruction)"
        content.sound = .default
        content.categoryIdentifier = "DISASTER_ALERT"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "disaster-\(alert.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Filtered views
    
    var criticalAlerts: [DisasterAlert] {
        allAlerts.filter { $0.severity == .critical }
    }
    
    var highSeverityAlerts: [DisasterAlert] {
        allAlerts.filter { $0.severity == .critical || $0.severity == .high }
    }
}
