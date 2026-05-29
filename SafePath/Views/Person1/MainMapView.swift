import SwiftUI
import Combine
import MapKit

/// Main map screen with Normal (Shelter Map) and Emergency (Evacuation Map) modes.
struct MainMapView: View {
    @EnvironmentObject var locationService: LocationService
    
    @StateObject private var shelterVM = ShelterViewModel()
    @StateObject private var alertVM = DisasterAlertViewModel()
    @StateObject private var routeVM = EvacuationRouteViewModel()
    
    @State private var isEmergencyMode = false
    @State private var showBottomSheet = true
    @State private var showShelterList = false
    @State private var showShelterDetail = false
    @State private var navigateToShelterDetail: Shelter?
    
    var body: some View {
        ZStack(alignment: .top) {
            // Full-screen map
            EvacuationMapView(
                userCoordinate: locationService.currentLocation,
                shelters: shelterVM.filteredShelters,
                selectedShelter: shelterVM.selectedShelter,
                alerts: isEmergencyMode ? alertVM.nearbyAlerts : [],
                primaryRoute: routeVM.currentRoute?.mkRoute,
                alternativeRoutes: routeVM.alternativeRoutes.compactMap(\.mkRoute),
                isEmergencyMode: isEmergencyMode,
                onShelterTapped: { shelter in
                    shelterVM.selectShelter(shelter)
                    showBottomSheet = true
                }
            )
            .ignoresSafeArea()
            
            // Top overlay controls
            VStack(spacing: 0) {
                topBar
                
                // Emergency alert banner
                if isEmergencyMode, let alert = alertVM.nearbyAlerts.first {
                    emergencyBanner(alert)
                }
                
                Spacer()
            }
            
            // Bottom sheet
            VStack {
                Spacer()
                
                if showBottomSheet {
                    MapBottomSheetView(
                        selectedShelter: shelterVM.selectedShelter,
                        currentRoute: routeVM.currentRoute,
                        isEmergencyMode: isEmergencyMode,
                        onSelectShelter: {
                            if let shelter = shelterVM.selectedShelter, let loc = locationService.currentLocation {
                                Task { await routeVM.calculateRoute(from: loc, to: shelter) }
                            }
                        },
                        onStartRoute: {
                            if let shelter = shelterVM.selectedShelter, let loc = locationService.currentLocation {
                                Task { await routeVM.calculateRoute(from: loc, to: shelter) }
                            }
                        },
                        onChangeShelter: {
                            showShelterList = true
                        },
                        onViewShelterDetail: { shelter in
                            navigateToShelterDetail = shelter
                            showShelterDetail = true
                        },
                        onShareRouteWithFamily: {
                            // Person 2 placeholder
                            if let route = routeVM.currentRoute {
                                routeVM.onShareRoute?(route)
                            }
                        },
                        onSOS: {
                            // Person 2 placeholder
                            routeVM.onSOS?()
                        },
                        onSaveOffline: {
                            // Person 3 placeholder
                            if let route = routeVM.currentRoute {
                                routeVM.onSaveRouteOffline?(route)
                            }
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            
            // Floating buttons (right side)
            VStack {
                Spacer()
                    .frame(height: 160)
                
                VStack(spacing: 10) {
                    // Find nearest shelter
                    floatingButton(icon: "building.2.fill", label: "Nearest") {
                        if let nearest = shelterVM.findNearestAvailable(preferMedical: isEmergencyMode) {
                            shelterVM.selectShelter(nearest)
                            if let loc = locationService.currentLocation {
                                Task { await routeVM.calculateRoute(from: loc, to: nearest) }
                            }
                        }
                    }
                    
                    // My location
                    floatingButton(icon: "location.fill", label: "Location") {
                        locationService.startUpdating()
                    }
                    
                    // Toggle bottom sheet
                    floatingButton(icon: showBottomSheet ? "chevron.down" : "chevron.up", label: "Sheet") {
                        withAnimation(.spring()) {
                            showBottomSheet.toggle()
                        }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 16)
            
            // Route calculating overlay
            if routeVM.isCalculating {
                calculatingOverlay
            }
        }
        .sheet(isPresented: $showShelterList) {
            ShelterListView(onSelectShelterForRoute: { shelter in
                shelterVM.selectShelter(shelter)
                showShelterList = false
                if let loc = locationService.currentLocation {
                    Task { await routeVM.calculateRoute(from: loc, to: shelter) }
                }
            })
            .environmentObject(locationService)
        }
        .sheet(isPresented: $showShelterDetail) {
            if let shelter = navigateToShelterDetail {
                NavigationStack {
                    ShelterDetailView(shelter: shelter, viewModel: shelterVM)
                }
            }
        }
        .task {
            locationService.requestPermission()
            alertVM.requestNotificationPermission()
            
            // Fetch initial data
            await shelterVM.fetchAllShelters()
            await alertVM.fetchAllAlerts()
            
            if let loc = locationService.currentLocation {
                await shelterVM.fetchNearbyShelters(location: loc)
                await alertVM.fetchNearbyAlerts(location: loc)
                
                // Auto-enable emergency mode if critical alerts nearby
                if !alertVM.criticalAlerts.isEmpty {
                    withAnimation { isEmergencyMode = true }
                    
                    // Auto-find nearest shelter
                    if let nearest = shelterVM.findNearestAvailable(preferMedical: true) {
                        shelterVM.selectShelter(nearest)
                        await routeVM.calculateRoute(from: loc, to: nearest)
                    }
                }
            }
        }
        .onChange(of: locationService.currentLocation?.latitude) { _ in
            // Recalculate route when location changes
            if let loc = locationService.currentLocation, let shelter = shelterVM.selectedShelter {
                Task { await routeVM.recalculateIfNeeded(newLocation: loc, shelter: shelter) }
            }
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack(spacing: 12) {
            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text(isEmergencyMode ? "Evacuation Map" : "Shelter Map")
                    .font(SafePathFonts.headline)
                    .foregroundColor(SafePathColors.textPrimary)
            }
            
            Spacer()
            
            // Mode chip
            modeChip
            
            // Shelter list button
            Button(action: { showShelterList = true }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SafePathColors.textPrimary)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Mode Toggle Chip
    
    private var modeChip: some View {
        Button(action: {
            withAnimation(.spring()) { isEmergencyMode.toggle() }
            
            if isEmergencyMode {
                // Enter emergency: find nearest shelter and route
                if let loc = locationService.currentLocation,
                   let nearest = shelterVM.findNearestAvailable(preferMedical: true) {
                    shelterVM.selectShelter(nearest)
                    Task { await routeVM.calculateRoute(from: loc, to: nearest) }
                }
            } else {
                routeVM.clearRoute()
            }
        }) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isEmergencyMode ? SafePathColors.dangerRed : SafePathColors.safeGreen)
                    .frame(width: 8, height: 8)
                Text(isEmergencyMode ? "Emergency" : "Normal")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(isEmergencyMode ? SafePathColors.dangerRed : SafePathColors.safeGreen)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isEmergencyMode
                    ? SafePathColors.dangerRed.opacity(0.12)
                    : SafePathColors.safeGreen.opacity(0.12)
            )
            .cornerRadius(20)
        }
    }
    
    // MARK: - Emergency Banner
    
    private func emergencyBanner(_ alert: DisasterAlert) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(alert.typeDisplayName) — M\(String(format: "%.1f", alert.magnitude))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text(alert.locationName)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }
            Spacer()
            if let dist = alert.distanceKm {
                Text(dist.distanceDisplay)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(SafePathColors.dangerRed)
    }
    
    // MARK: - Floating Button
    
    private func floatingButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(label)
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(SafePathColors.primaryBlue)
            .frame(width: 52, height: 52)
            .background(.ultraThinMaterial)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        }
    }
    
    // MARK: - Calculating Overlay
    
    private var calculatingOverlay: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(.white)
            Text("Calculating route...")
                .font(SafePathFonts.caption)
                .foregroundColor(.white)
        }
        .padding(24)
        .background(Color.black.opacity(0.6))
        .cornerRadius(16)
    }
}

// MARK: - Preview

#if DEBUG
struct MainMapView_Previews: PreviewProvider {
    static var previews: some View {
        MainMapView()
            .environmentObject(LocationService())
    }
}
#endif
