import SwiftData
import SwiftUI

struct ManageCardsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MemoryCard.updatedAt, order: .reverse) private var cards: [MemoryCard]

    @State private var searchText = ""
    @State private var editingCard: MemoryCard?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Manage Cards")
                .font(.title2.bold())

            Table(filteredCards) {
                TableColumn("Question") { card in
                    Text(card.questionMarkdown)
                        .lineLimit(1)
                }

                TableColumn("Due") { card in
                    Text(dueLabel(for: card))
                        .foregroundStyle(.secondary)
                }

                TableColumn("Reps") { card in
                    Text("\(card.reps)")
                        .foregroundStyle(.secondary)
                }
            }
            .searchable(text: $searchText, prompt: "Search")
            .contextMenu(forSelectionType: MemoryCard.ID.self) { selection in
                Button("Edit Card") {
                    if let id = selection.first {
                        editingCard = cards.first { $0.id == id }
                    }
                }
                .disabled(selection.count != 1)

                Button("Reset Scheduling") {
                    reset(selection: selection)
                }
                .disabled(selection.isEmpty)

                Button("Delete", role: .destructive) {
                    delete(selection: selection)
                }
                .disabled(selection.isEmpty)
            }
        }
        .padding()
        .sheet(item: $editingCard) { card in
            EditCardView(card: card)
                .frame(minWidth: 560, minHeight: 520)
        }
    }

    private var filteredCards: [MemoryCard] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return cards
        }

        return cards.filter { card in
            card.questionMarkdown.localizedCaseInsensitiveContains(query) ||
            card.answerMarkdown.localizedCaseInsensitiveContains(query)
        }
    }

    private func dueLabel(for card: MemoryCard) -> String {
        guard let dueAt = card.dueAt else {
            return "Now"
        }

        if Calendar.current.isDateInToday(dueAt) {
            return "Today"
        }

        return dueAt.formatted(date: .abbreviated, time: .omitted)
    }

    private func reset(selection: Set<MemoryCard.ID>) {
        for card in cards where selection.contains(card.id) {
            card.dueAt = .now
            card.lastReviewedAt = nil
            card.stability = nil
            card.difficulty = nil
            card.elapsedDays = 0
            card.scheduledDays = 0
            card.reps = 0
            card.lapses = 0
            card.stateRaw = MemoryCardState.new.rawValue
            card.updatedAt = .now
        }
    }

    private func delete(selection: Set<MemoryCard.ID>) {
        for card in cards where selection.contains(card.id) {
            modelContext.delete(card)
        }
    }
}

private struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var card: MemoryCard

    var body: some View {
        Form {
            Section("Question") {
                MarkdownEditorView(text: $card.questionMarkdown, minHeight: 150)
            }

            Section("Answer") {
                MarkdownEditorView(text: $card.answerMarkdown, minHeight: 220)
            }

            HStack {
                Spacer()

                Button("Done") {
                    card.updatedAt = .now
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
