import Foundation

/// Person 3: Manages first aid guide data.
@MainActor
final class FirstAidGuideViewModel: ObservableObject {
    // TODO: Person 3 will implement guide loading, search, and bookmarking.
    
    @Published var guides: [FirstAidGuide] = []
    @Published var selectedGuide: FirstAidGuide?
}
