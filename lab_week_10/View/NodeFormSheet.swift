// MARK: - NodeFormSheet.swift

import SwiftUI

struct NodeFormSheet: View {
    @ObservedObject var viewModel: AdminViewModel
    let story: Story
    let editingNode: StoryNode?
    @Environment(\.dismiss) private var dismiss

    @State private var showAddChoice: Bool = false
    @State private var choiceLabel: String = ""
    @State private var choiceNextNodeId: String = ""

    private var isEditing: Bool { editingNode != nil }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Narrative
                Section("Narasi") {
                    TextEditor(text: $viewModel.nodeNarrative)
                        .frame(minHeight: 100)
                }

                // MARK: - Entry Point Toggle
                Section {
                    Toggle("Jadikan Entry Point", isOn: $viewModel.nodeIsEntryPoint)
                }

                // MARK: - Choices
                Section {
                    ForEach(viewModel.nodeChoices) { choice in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(choice.label).font(.subheadline.bold())
                            if let nextId = choice.nextNodeId, !nextId.isEmpty {
                                Text("→ Node: \(nextId)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("→ Akhir cerita")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { offsets in
                        viewModel.removeChoice(at: offsets)
                    }

                    Button {
                        choiceLabel = ""
                        choiceNextNodeId = ""
                        showAddChoice = true
                    } label: {
                        Label("Tambah Pilihan", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Pilihan (\(viewModel.nodeChoices.count))")
                } footer: {
                    Text("Kosongkan Node ID untuk menandai akhir cerita.")
                        .font(.caption)
                }

                // Available Nodes for reference
                if !viewModel.nodes.isEmpty {
                    Section("Node yang Tersedia (salin ID)") {
                        ForEach(viewModel.nodes) { node in
                            if node.id != editingNode?.id {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(node.narrative)
                                            .font(.caption)
                                            .lineLimit(1)
                                        Text(node.id ?? "-")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Button {
                                        UIPasteboard.general.string = node.id
                                    } label: {
                                        Image(systemName: "doc.on.clipboard")
                                            .font(.caption)
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // Error
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red).font(.caption)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Node" : "Node Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        viewModel.resetNodeForm()
                        viewModel.clearMessages()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        Task {
                            if let node = editingNode {
                                await viewModel.updateNode(node, storyId: story.id ?? "")
                            } else {
                                await viewModel.addNode(to: story.id ?? "")
                            }
                            if viewModel.successMessage != nil {
                                viewModel.clearMessages()
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading || viewModel.nodeNarrative.isEmpty)
                }
            }
            .alert("Tambah Pilihan", isPresented: $showAddChoice) {
                TextField("Label pilihan", text: $choiceLabel)
                TextField("Node ID tujuan (opsional)", text: $choiceNextNodeId)
                Button("Tambah") {
                    guard !choiceLabel.isEmpty else { return }
                    viewModel.addChoice(
                        label: choiceLabel,
                        nextNodeId: choiceNextNodeId.isEmpty ? nil : choiceNextNodeId
                    )
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Isi label dan Node ID tujuan.")
            }
        }
    }
}
