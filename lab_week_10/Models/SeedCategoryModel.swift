//
//  lab_week_10App.swift
//  lab_week_10
//
//  Created by  Mualli on 30/04/26.
//

import Foundation
import FirebaseFirestore

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
