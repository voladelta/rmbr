import SwiftUI

struct FlashcardsView: View {
    @State private var mode = FlashcardMode.review

    var body: some View {
        Group {
            switch mode {
            case .review:
                ReviewView()
            case .add:
                AddCardView()
            case .manage:
                ManageCardsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Flashcard mode", selection: $mode) {
                    ForEach(FlashcardMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 300)
            }
        }
    }
}

enum FlashcardMode: String, CaseIterable, Identifiable {
    case review
    case add
    case manage

    var id: String { rawValue }

    var title: String {
        switch self {
        case .review: "Review"
        case .add: "Add"
        case .manage: "Manage"
        }
    }
}
