import SwiftUI

struct RootTabView: View {
    @State private var selectedSection = AppSection.notes

    var body: some View {
        Group {
            switch selectedSection {
            case .notes:
                NotesView()
            case .flashcards:
                FlashcardsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("Section", selection: $selectedSection) {
                    ForEach(AppSection.allCases) { section in
                        Text(section.title).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 220)
            }
        }
    }
}

private enum AppSection: String, CaseIterable, Identifiable {
    case notes
    case flashcards

    var id: String { rawValue }

    var title: String {
        switch self {
        case .notes: "Notes"
        case .flashcards: "Flashcards"
        }
    }
}
