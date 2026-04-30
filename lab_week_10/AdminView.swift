// MARK: - AdminView.swift

import SwiftUI

struct AdminView: View {
    @StateObject private var viewModel = AdminViewModel()
    @State private var showAddStory: Bool = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.stories.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "Belum Ada Cerita",
                        systemImage: "book.closed",
                        description: Text("Tap + untuk membuat cerita baru.")
                    )
                } else {
                    Section("Rancangan Cerita") {
                        ForEach(viewModel.stories) { story in
                            NavigationLink(destination: StoryNodeListView(story: story)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(story.title)
                                        .font(.headline)
                                    Text(story.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { offsets in
                            Task {
                                for index in offsets {
                                    if let id = viewModel.stories[index].id {
                                        await viewModel.deleteStory(id: id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Arsitek")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddStory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await viewModel.fetchStories()
            }
            .refreshable {
                await viewModel.fetchStories()
            }
            .sheet(isPresented: $showAddStory) {
                AddStorySheet(viewModel: viewModel)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
        }
    }
}

// MARK: - AddStorySheet
struct AddStorySheet: View {
    @ObservedObject var viewModel: AdminViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Detail Cerita") {
                    TextField("Judul", text: $viewModel.storyTitle)
                    TextField("Deskripsi", text: $viewModel.storyDescription, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Cerita Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        viewModel.storyTitle = ""
                        viewModel.storyDescription = ""
                        viewModel.clearMessages()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        Task {
                            await viewModel.addStory()
                            if viewModel.successMessage != nil {
                                viewModel.clearMessages()
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
}

// MARK: - StoryNodeListView
struct StoryNodeListView: View {
    let story: Story
    @StateObject private var viewModel = AdminViewModel()
    @State private var showAddNode: Bool = false
    @State private var nodeToEdit: StoryNode?

    var body: some View {
        List {
            if viewModel.nodes.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "Belum Ada Node",
                    systemImage: "text.bubble",
                    description: Text("Tap + untuk membuat node pertama.")
                )
            } else {
                ForEach(viewModel.nodes) { node in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            if node.isEntryPoint {
                                Label("Entry Point", systemImage: "play.fill")
                                    .font(.caption.bold())
                                    .foregroundStyle(.green)
                            }
                            Spacer()
                            Button {
                                viewModel.loadNodeIntoForm(node)
                                nodeToEdit = node
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                        }

                        Text(node.narrative)
                            .font(.subheadline)
                            .lineLimit(2)
                            .foregroundStyle(.primary)

                        if !node.choices.isEmpty {
                            Text("\(node.choices.count) pilihan")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    Task {
                        for index in offsets {
                            if let id = viewModel.nodes[index].id {
                                await viewModel.deleteNode(id: id, storyId: story.id ?? "")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(story.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.resetNodeForm()
                    showAddNode = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await viewModel.fetchStories()
            await viewModel.fetchNodes(for: story.id ?? "")
        }
        .refreshable {
            await viewModel.fetchNodes(for: story.id ?? "")
        }
        .sheet(isPresented: $showAddNode) {
            NodeFormSheet(
                viewModel: viewModel,
                story: story,
                editingNode: nil
            )
        }
        .sheet(item: $nodeToEdit) { node in
            NodeFormSheet(
                viewModel: viewModel,
                story: story,
                editingNode: node
            )
        }
    }
}
