import SwiftUI
import MapKit

/// Detail screen for a single shelter.
struct ShelterDetailView: View {
    let shelter: Shelter
    @ObservedObject var viewModel: ShelterViewModel
    
    @State private var mapRegion: MKCoordinateRegion
    
    init(shelter: Shelter, viewModel: ShelterViewModel) {
        self.shelter = shelter
        self.viewModel = viewModel
        _mapRegion = State(initialValue: MKCoordinateRegion(
            center: shelter.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Map preview
                mapPreview
                
                // Header
                headerSection
                
                // Capacity
                capacitySection
                
                // Facilities
                facilitiesSection
                
                // Contact info
                contactSection
                
                // Action buttons
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationTitle("Shelter Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Map Preview
    
    private var mapPreview: some View {
        Map(coordinateRegion: $mapRegion, annotationItems: [shelter]) { s in
            MapAnnotation(coordinate: s.coordinate) {
                Image(systemName: "building.2.fill")
                    .font(.title2)
                    .foregroundColor(SafePathColors.accentBlue)
                    .padding(8)
                    .background(Circle().fill(.white))
                    .shadow(radius: 3)
            }
        }
        .frame(height: 200)
        .cornerRadius(16)
        .allowsHitTesting(false)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(shelter.name)
                    .font(SafePathFonts.title)
                    .foregroundColor(SafePathColors.textPrimary)
                Spacer()
                StatusChip(status: shelter.status)
            }
            
            Label(shelter.address, systemImage: "mappin.circle.fill")
                .font(SafePathFonts.body)
                .foregroundColor(SafePathColors.textSecondary)
            
            HStack(spacing: 16) {
                if let dist = shelter.distanceKm {
                    Label(dist.distanceDisplay, systemImage: "location.fill")
                        .font(SafePathFonts.caption)
                        .foregroundColor(SafePathColors.accentBlue)
                }
                
                if shelter.isVerified {
                    Label("Verified", systemImage: "checkmark.seal.fill")
                        .font(SafePathFonts.caption)
                        .foregroundColor(SafePathColors.safeGreen)
                }
                
                if let source = shelter.source {
                    Label(source, systemImage: "building.columns.fill")
                        .font(SafePathFonts.caption)
                        .foregroundColor(SafePathColors.textSecondary)
                }
            }
        }
        .padding(16)
        .safePathCard()
    }
    
    // MARK: - Capacity
    
    private var capacitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Capacity")
                .font(SafePathFonts.headline)
                .foregroundColor(SafePathColors.textPrimary)
            
            HStack(spacing: 20) {
                capacityStat(value: "\(shelter.capacityTotal)", label: "Total")
                capacityStat(value: "\(shelter.capacityUsed)", label: "Used")
                capacityStat(value: "\(shelter.availableSpace)", label: "Available", highlight: true)
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(capacityColor)
                        .frame(width: geo.size.width * min(shelter.capacityPercentage / 100, 1.0), height: 10)
                }
            }
            .frame(height: 10)
            
            Text("\(Int(shelter.capacityPercentage))% occupied")
                .font(SafePathFonts.caption)
                .foregroundColor(SafePathColors.textSecondary)
        }
        .padding(16)
        .safePathCard()
    }
    
    private func capacityStat(value: String, label: String, highlight: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(highlight ? SafePathColors.safeGreen : SafePathColors.textPrimary)
            Text(label)
                .font(SafePathFonts.caption)
                .foregroundColor(SafePathColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Facilities
    
    private var facilitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Facilities")
                .font(SafePathFonts.headline)
                .foregroundColor(SafePathColors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(shelter.facilities, id: \.self) { facility in
                    VStack(spacing: 6) {
                        Image(systemName: Shelter.facilityIcon(facility))
                            .font(.title3)
                            .foregroundColor(SafePathColors.accentBlue)
                        Text(Shelter.facilityDisplayName(facility))
                            .font(SafePathFonts.caption)
                            .foregroundColor(SafePathColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(SafePathColors.accentBlue.opacity(0.06))
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .safePathCard()
    }
    
    // MARK: - Contact
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Emergency Contact")
                .font(SafePathFonts.headline)
                .foregroundColor(SafePathColors.textPrimary)
            
            if let phone = shelter.contactPhone {
                Label(phone, systemImage: "phone.fill")
                    .font(SafePathFonts.body)
                    .foregroundColor(SafePathColors.accentBlue)
            }
            
            if let lastUpdated = shelter.lastUpdated, let date = lastUpdated.iso8601Date {
                Label("Last updated: \(date.shortDisplay)", systemImage: "clock.fill")
                    .font(SafePathFonts.caption)
                    .foregroundColor(SafePathColors.textSecondary)
            }
        }
        .padding(16)
        .safePathCard()
    }
    
    // MARK: - Actions
    
    private var actionButtons: some View {
        VStack(spacing: 10) {
            // Select as destination
            Button(action: { viewModel.selectShelter(shelter) }) {
                Label("Select as Evacuation Destination", systemImage: "mappin.and.ellipse")
                    .font(SafePathFonts.buttonLabel)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(SafePathColors.accentBlue)
                    .cornerRadius(14)
            }
            
            // Start route
            Button(action: { viewModel.selectShelter(shelter) }) {
                Label("Start Route", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(SafePathFonts.buttonLabel)
                    .foregroundColor(SafePathColors.accentBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(SafePathColors.accentBlue.opacity(0.1))
                    .cornerRadius(14)
            }
            
            HStack(spacing: 10) {
                // Person 2 placeholder: Share with Family
                Button(action: { viewModel.onShareWithFamily?(shelter) }) {
                    Label("Share", systemImage: "person.2.fill")
                        .font(SafePathFonts.caption)
                        .foregroundColor(SafePathColors.accentBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(SafePathColors.accentBlue.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Person 3 placeholder: Save Offline
                Button(action: { viewModel.onSaveShelterOffline?(shelter) }) {
                    Label("Save Offline", systemImage: "arrow.down.circle.fill")
                        .font(SafePathFonts.caption)
                        .foregroundColor(SafePathColors.offlineGray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(SafePathColors.offlineGray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var capacityColor: Color {
        if shelter.capacityPercentage >= 90 { return SafePathColors.dangerRed }
        if shelter.capacityPercentage >= 70 { return SafePathColors.warningOrange }
        return SafePathColors.safeGreen
    }
}

// MARK: - Preview

#if DEBUG
struct ShelterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShelterDetailView(shelter: .preview, viewModel: ShelterViewModel())
        }
    }
}
#endif
