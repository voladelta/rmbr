import SwiftUI

struct FlashcardsView: View {
    @Binding var mode: FlashcardMode

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
