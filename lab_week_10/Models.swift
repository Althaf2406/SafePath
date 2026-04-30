// MARK: - Models.swift
// StoryApp - AFL Week 10
// Mobile Application Development

import Foundation
import FirebaseFirestore

// MARK: - User Model
struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var completedStories: [String]

    init(id: String? = nil, name: String, email: String, completedStories: [String] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.completedStories = completedStories
    }
}

// MARK: - Story Model
struct Story: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var category: String
    var entryNodeId: String?

    init(id: String? = nil, title: String, description: String, category: String = "General", entryNodeId: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.entryNodeId = entryNodeId
    }
}

// MARK: - StoryNode Model
struct StoryNode: Identifiable, Codable {
    @DocumentID var id: String?
    var storyId: String
    var narrative: String
    var isEntryPoint: Bool
    var choices: [Choice]

    init(id: String? = nil, storyId: String, narrative: String, isEntryPoint: Bool = false, choices: [Choice] = []) {
        self.id = id
        self.storyId = storyId
        self.narrative = narrative
        self.isEntryPoint = isEntryPoint
        self.choices = choices
    }
}

// MARK: - Choice Model
struct Choice: Identifiable, Codable {
    var id: String
    var label: String
    var nextNodeId: String?

    init(id: String = UUID().uuidString, label: String, nextNodeId: String? = nil) {
        self.id = id
        self.label = label
        self.nextNodeId = nextNodeId
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var iconName: String

    init(id: String = UUID().uuidString, title: String, description: String, iconName: String = "star.fill") {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
    }
}

// MARK: - Seed Data Categories
enum SeedCategory: String, CaseIterable {
    case bajak = "Bajak Laut"
    case ninja = "Ninja"
    case romance = "Romance"

    var description: String {
        switch self {
        case .bajak: return "Mulai petualangan mencari harta karun samudra."
        case .ninja: return "Mulai perjalanan ninja menembus batas desa."
        case .romance: return "Mulai kisah asmara manis di bawah sakura."
        }
    }

    var iconName: String {
        switch self {
        case .bajak: return "ferry.fill"
        case .ninja: return "figure.run"
        case .romance: return "heart.fill"
        }
    }
}
