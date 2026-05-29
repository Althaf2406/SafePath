import SwiftUI
import Combine

/// Person 3: Emergency Checklist view matching the visual style in Screenshot 2.
struct ChecklistView: View {
    @State private var selectedCategory: String = "All"
    @State private var items: [LocalChecklistItem] = [
        LocalChecklistItem(name: "Water bottle", category: "Food & Water", priority: .high, isCompleted: true),
        LocalChecklistItem(name: "Instant food", category: "Food & Water", priority: .high, isCompleted: true),
        LocalChecklistItem(name: "First aid kit", category: "Medical", priority: .high, isCompleted: false),
        LocalChecklistItem(name: "Flashlight", category: "Tools", priority: .high, isCompleted: false),
        LocalChecklistItem(name: "Extra batteries", category: "Tools", priority: .medium, isCompleted: false),
        LocalChecklistItem(name: "Matches & lighter", category: "Tools", priority: .low, isCompleted: false),
        LocalChecklistItem(name: "Emergency blanket", category: "Medical", priority: .medium, isCompleted: false)
    ]
    @State private var isNavigatingToCustomize = false
    
    let categories = ["All", "Food & Water", "Medical", "Tools", "Documents"]
    
    var completedCount: Int {
        items.filter { $0.isCompleted }.count
    }
    
    var totalCount: Int {
        items.count
    }
    
    var filteredItems: [LocalChecklistItem] {
        if selectedCategory == "All" {
            return items
        } else {
            return items.filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1. Overall Readiness Progress Card
                    readinessCard
                    
                    // 2. Category Filter Pills
                    categoryFilters
                    
                    // 3. Checklist Items List Card
                    itemsListCard
                    
                    // TODO: Person 3 should integrate checklist storage and syncing with CoreData/SQLite.
                    Text("// TODO: Person 3: Hook checklist item completion to SQLite/CoreData offline storage.")
                        .font(.system(size: 10))
                        .foregroundColor(SafePathColors.textSecondary)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(SafePathColors.backgroundLight.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(SafePathColors.primaryBlue)
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("SafePath")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(SafePathColors.primaryBlue)
                            .font(.title3)
                    }
                }
            }
            .navigationDestination(isPresented: $isNavigatingToCustomize) {
                CustomizeChecklistView()
            }
        }
    }
    
    // MARK: - Overall Readiness Card
    private var readinessCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Overall Readiness")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.textPrimary)
                Spacer()
                Text("\(completedCount)/\(totalCount) Completed")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.primaryBlue)
            }
            
            // Custom Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(SafePathColors.backgroundLight)
                        .frame(height: 10)
                    
                    let percentage = totalCount > 0 ? CGFloat(completedCount) / CGFloat(totalCount) : 0
                    RoundedRectangle(cornerRadius: 6)
                        .fill(SafePathColors.primaryBlue)
                        .frame(width: geo.size.width * percentage, height: 10)
                }
            }
            .frame(height: 10)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Category Filters
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    let isSelected = selectedCategory == category
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(isSelected ? .white : SafePathColors.primaryBlue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isSelected ? SafePathColors.primaryBlue : SafePathColors.lightBlueCard)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    // MARK: - Items List Card
    private var itemsListCard: some View {
        VStack(spacing: 0) {
            Text("Emergency Checklist")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(SafePathColors.primaryBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)
            
            VStack(spacing: 0) {
                ForEach(filteredItems) { item in
                    let index = items.firstIndex(where: { $0.id == item.id }) ?? 0
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            // Checkbox Button
                            Button(action: {
                                withAnimation {
                                    items[index].isCompleted.toggle()
                                }
                            }) {
                                Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                                    .font(.title2)
                                    .foregroundColor(item.isCompleted ? SafePathColors.primaryBlue : .gray)
                            }
                            
                            // Item Text
                            Text(item.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(item.isCompleted ? SafePathColors.textSecondary : SafePathColors.textPrimary)
                                .strikethrough(item.isCompleted, color: SafePathColors.textSecondary)
                            
                            Spacer()
                            
                            // Priority Badge
                            Text(item.priority.rawValue)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(item.priority.color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(item.priority.color.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
                
                // Add Item Dashed Button
                Button(action: {
                    isNavigatingToCustomize = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Item")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(SafePathColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                            .foregroundColor(SafePathColors.textSecondary.opacity(0.5))
                    )
                    .padding(16)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Helper Models
struct LocalChecklistItem: Identifiable {
    let id = UUID()
    var name: String
    var category: String
    var priority: LocalChecklistPriority
    var isCompleted: Bool
}

enum LocalChecklistPriority: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: Color {
        switch self {
        case .high: return SafePathColors.dangerRed
        case .medium: return SafePathColors.primaryBlue
        case .low: return SafePathColors.safeGreen
        }
    }
}

#Preview {
    ChecklistView()
}
