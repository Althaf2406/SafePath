//
//  AdminViewModel.swift
//  lab_week_10
//
//  Created by  Mualli on 30/04/26.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private init() {}

    // MARK: - Auth

    func login(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }

    func register(email: String, password: String, name: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = AppUser(id: result.user.uid, name: name, email: email)
        try db.collection("users").document(result.user.uid).setData(from: user)
        return result.user
    }

    func logout() throws {
        try Auth.auth().signOut()
    }

    func currentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }

    // MARK: - User Profile

    func fetchUser(uid: String) async throws -> AppUser {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        guard let user = try? snapshot.data(as: AppUser.self) else {
            throw AppError.userNotFound
        }
        return user
    }

    func markStoryCompleted(uid: String, storyId: String) async throws {
        try await db.collection("users").document(uid).updateData([
            "completedStories": FieldValue.arrayUnion([storyId])
        ])
    }

    // MARK: - Stories

    func fetchStories() async throws -> [Story] {
        let snapshot = try await db.collection("stories").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Story.self) }
    }

    func addStory(_ story: Story) async throws -> String {
        let ref = try db.collection("stories").addDocument(from: story)
        return ref.documentID
    }

    func updateStory(_ story: Story) async throws {
        guard let id = story.id else { return }
        try db.collection("stories").document(id).setData(from: story)
    }

    func deleteStory(id: String) async throws {
        try await db.collection("stories").document(id).delete()
    }

    // MARK: - Story Nodes

    func fetchNodes(for storyId: String) async throws -> [StoryNode] {
        let snapshot = try await db.collection("storyNodes")
            .whereField("storyId", isEqualTo: storyId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: StoryNode.self) }
    }

    func addNode(_ node: StoryNode) async throws -> String {
        let ref = try db.collection("storyNodes").addDocument(from: node)
        return ref.documentID
    }

    func updateNode(_ node: StoryNode) async throws {
        guard let id = node.id else { return }
        try db.collection("storyNodes").document(id).setData(from: node)
    }

    func deleteNode(id: String) async throws {
        try await db.collection("storyNodes").document(id).delete()
    }

    func fetchNode(id: String) async throws -> StoryNode {
        let snapshot = try await db.collection("storyNodes").document(id).getDocument()
        guard let node = try? snapshot.data(as: StoryNode.self) else {
            throw AppError.nodeNotFound
        }
        return node
    }

    // MARK: - Seed Data

    func seedCategory(_ category: SeedCategory) async throws {
        // Create a story
        let story = Story(
            title: storyTitle(for: category),
            description: category.description,
            category: category.rawValue
        )
        let storyId = try await addStory(story)

        // Create entry node
        let entryNode = StoryNode(
            storyId: storyId,
            narrative: entryNarrative(for: category),
            isEntryPoint: true,
            choices: []
        )
        let entryNodeId = try await addNode(entryNode)

        // Create child nodes
        let (choice1Text, node1Narrative) = firstChoice(for: category)
        let (choice2Text, node2Narrative) = secondChoice(for: category)

        let node1 = StoryNode(storyId: storyId, narrative: node1Narrative, isEntryPoint: false, choices: [])
        let node2 = StoryNode(storyId: storyId, narrative: node2Narrative, isEntryPoint: false, choices: [])

        let node1Id = try await addNode(node1)
        let node2Id = try await addNode(node2)

        // Link entry node choices
        var updatedEntry = entryNode
        updatedEntry.id = entryNodeId
        updatedEntry.choices = [
            Choice(label: choice1Text, nextNodeId: node1Id),
            Choice(label: choice2Text, nextNodeId: node2Id)
        ]
        try await updateNode(updatedEntry)

        // Update story entryNodeId
        var updatedStory = story
        updatedStory.id = storyId
        updatedStory.entryNodeId = entryNodeId
        try await updateStory(updatedStory)
    }

    // MARK: - Seed Helpers

    private func storyTitle(for category: SeedCategory) -> String {
        switch category {
        case .bajak: return "Tekad Sang Kapten"
        case .ninja: return "Jalan Ninja"
        case .romance: return "Sakura Terakhir"
        }
    }

    private func entryNarrative(for category: SeedCategory) -> String {
        switch category {
        case .bajak: return "Dylan berdiri di atas dek kapalnya, menatap lautan luas. Sebuah peta tua menunjuk ke pulau misterius di timur. Badai mendekat dari barat."
        case .ninja: return "Ian berlatih di hutan. Ujian ninja tinggal besok pagi. Ian merasa kurang menguasai chakra-nya."
        case .romance: return "Gavin duduk di bawah pohon sakura yang mulai berguguran. Dia melihat seseorang yang familiar berjalan mendekat."
        }
    }

    private func firstChoice(for category: SeedCategory) -> (String, String) {
        switch category {
        case .bajak: return ("Berlayar ke timur", "Dylan memerintahkan kru untuk berlayar menembus badai menuju timur. Ombak besar menggulung kapal.")
        case .ninja: return ("Meditasi Chakra", "Ian duduk bersila dan mulai memusatkan energinya. Perlahan, chakra-nya mengalir dengan tenang.")
        case .romance: return ("Menyapa duluan", "Gavin memberanikan diri berdiri dan melambaikan tangan. Hatinya berdebar kencang.")
        }
    }

    private func secondChoice(for category: SeedCategory) -> (String, String) {
        switch category {
        case .bajak: return ("Menunggu badai reda", "Dylan memilih untuk berlabuh dan menunggu. Para kru beristirahat, namun sebuah kapal bajak laut lain mendekat.")
        case .ninja: return ("Latihan Fisik Keras", "Ian memutuskan untuk berlatih fisik sepanjang malam. Tubuhnya lelah, tapi tekadnya semakin kuat.")
        case .romance: return ("Pura-pura tidak kenal", "Gavin membalik badan dan berjalan pergi. Tapi langkahnya terhenti saat mendengar nama panggilannya.")
        }
    }
}

// MARK: - App Errors
enum AppError: LocalizedError {
    case userNotFound
    case nodeNotFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .userNotFound: return "User tidak ditemukan."
        case .nodeNotFound: return "Node cerita tidak ditemukan."
        case .unknown: return "Terjadi kesalahan tidak dikenal."
        }
    }
}
