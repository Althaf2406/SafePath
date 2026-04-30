//
//  MainView.swift
//  lab_week_10
//
//  Created by  Mualli on 30/04/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedStory: Story?

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Memuat cerita...")
                } else if viewModel.stories.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Belum ada cerita.")
                            .foregroundStyle(.secondary)
                        Text("Tambahkan cerita dari Admin atau Profile.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.stories) { story in
                                StoryCardView(story: story) {
                                    selectedStory = story
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Daftar Cerita")
            .navigationSubtitle("Pilih jalan yang ingin kau telusuri")
            .task {
                await viewModel.fetchStories()
            }
            .refreshable {
                await viewModel.fetchStories()
            }
            .fullScreenCover(item: $selectedStory) { story in
                GameplayView(story: story)
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

// MARK: - StoryCardView
struct StoryCardView: View {
    let story: Story
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(story.title)
                .font(.headline)

            Text(story.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Button(action: onStart) {
                HStack {
                    Text("Mulai cerita")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.primary)
                .foregroundStyle(Color(.systemBackground))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
