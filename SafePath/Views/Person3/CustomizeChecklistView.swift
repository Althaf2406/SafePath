import SwiftUI
import Combine

/// Person 3: Customize Checklist screen matching the visual style in Screenshot 3.
struct CustomizeChecklistView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var itemName: String = ""
    @State private var selectedCategory: String = "Lighting"
    @State private var quantity: Int = 1
    @State private var priority: String = "High"
    @State private var disasterType: String = "Flood"
    
    let categories = ["Lighting", "Food & Water", "Medical", "Tools", "Documents"]
    let disasterTypes = ["Flood", "Earthquake", "Tsunami", "Volcano", "Wildfire"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Details
                headerView
                
                // Form Card
                formCard
                
                // Recently Added Items Section
                recentlyAddedSection
                
                // TODO comment
                Text("// TODO: Person 3: Add actual database save and edit functions here.")
                    .font(.system(size: 10))
                    .foregroundColor(SafePathColors.textSecondary)
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(SafePathColors.primaryBlue)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Image(systemName: "shield.fill")
                        .foregroundColor(SafePathColors.primaryBlue)
                        .font(.headline)
                    Text("SafePath")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(SafePathColors.primaryBlue)
                    .font(.title3)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Customize Checklist")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(SafePathColors.primaryBlue)
            
            Text("Update your emergency supplies for specific disaster types.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SafePathColors.textSecondary)
                .lineLimit(2)
        }
    }
    
    // MARK: - Form Card
    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Item Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Item Name")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                TextField("e.g. Tactical Flashlight", text: $itemName)
                    .padding()
                    .background(SafePathColors.backgroundLight.opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
                    )
            }
            
            // Category & Quantity Row
            HStack(spacing: 12) {
                // Category Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Category")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)
                    
                    Menu {
                        ForEach(categories, id: \.self) { cat in
                            Button(cat) { selectedCategory = cat }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory)
                                .foregroundColor(SafePathColors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(SafePathColors.textSecondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(SafePathColors.backgroundLight.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
                        )
                    }
                }
                
                // Quantity Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quantity")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)
                    
                    Menu {
                        ForEach(1...10, id: \.self) { num in
                            Button("\(num)") { quantity = num }
                        }
                    } label: {
                        HStack {
                            Text("\(quantity)")
                                .foregroundColor(SafePathColors.textPrimary)
                            Spacer()
                        }
                        .padding()
                        .background(SafePathColors.backgroundLight.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
                        )
                    }
                    .frame(width: 100)
                }
            }
            
            // Priority & Disaster Type Row
            HStack(spacing: 12) {
                // Priority Selector
                VStack(alignment: .leading, spacing: 6) {
                    Text("Priority")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)
                    
                    HStack(spacing: 0) {
                        Button(action: { priority = "High" }) {
                            Text("High")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(priority == "High" ? .white : SafePathColors.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(priority == "High" ? SafePathColors.primaryBlue : SafePathColors.lightBlueCard)
                        }
                        
                        Button(action: { priority = "Medium" }) {
                            Text("Medium")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(priority == "Medium" ? .white : SafePathColors.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(priority == "Medium" ? SafePathColors.primaryBlue : SafePathColors.lightBlueCard)
                        }
                    }
                    .cornerRadius(10)
                }
                
                // Disaster Type Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Disaster Type")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)
                    
                    Menu {
                        ForEach(disasterTypes, id: \.self) { type in
                            Button(type) { disasterType = type }
                        }
                    } label: {
                        HStack {
                            Text(disasterType)
                                .foregroundColor(SafePathColors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(SafePathColors.textSecondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(SafePathColors.backgroundLight.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
                        )
                    }
                }
            }
            .padding(.bottom, 8)
            
            // Save Item Button
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down.fill")
                    Text("Save Item")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(SafePathColors.primaryBlue)
                .cornerRadius(12)
            }
            
            // Delete Item Button
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash.fill")
                    Text("Delete Item")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(SafePathColors.dangerRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(SafePathColors.dangerRed, lineWidth: 1.5)
                )
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Recently Added Section
    private var recentlyAddedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENTLY ADDED ITEMS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(SafePathColors.textSecondary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                // Item 1: First Aid Kit
                HStack(spacing: 12) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(SafePathColors.safeGreen)
                        .frame(width: 40, height: 40)
                        .background(SafePathColors.safeGreen.opacity(0.1))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("First Aid Kit")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(SafePathColors.textPrimary)
                        Text("Medical • High Priority")
                            .font(.system(size: 12))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "pencil")
                        .foregroundColor(SafePathColors.textSecondary)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(16)
                
                // Item 2: Water Purifier
                HStack(spacing: 12) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(SafePathColors.dangerRed)
                        .frame(width: 40, height: 40)
                        .background(SafePathColors.dangerRed.opacity(0.1))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Water Purifier")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(SafePathColors.textPrimary)
                        Text("Nutrition • Qty: 2")
                            .font(.system(size: 12))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "pencil")
                        .foregroundColor(SafePathColors.textSecondary)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(16)
            }
        }
    }
}

#Preview {
    CustomizeChecklistView()
}
