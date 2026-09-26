import SwiftUI

struct RootTabView: View {
    @State private var selectedSection = AppSection.notes
    @State private var selectedSlot = 0
    @State private var flashcardMode = FlashcardMode.review

    private static let slotColors: [Color] = [
        .yellow, .orange, .red, .purple, .blue, .cyan, .green
    ]
    private static let slotNames = [
        "Yellow", "Orange", "Red", "Purple", "Blue", "Cyan", "Green"
    ]

    var body: some View {
        Group {
            switch selectedSection {
            case .notes:
                NotesView(selectedSlot: $selectedSlot)
            case .flashcards:
                FlashcardsView(mode: $flashcardMode)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar { navigationToolbar }
    }

    @ToolbarContentBuilder
    private var navigationToolbar: some ToolbarContent {
        if #available(macOS 26, *) {
            ToolbarItem(placement: .principal) {
                sectionControls
            }
            .sharedBackgroundVisibility(.hidden)

            ToolbarSpacer(.flexible)

            ToolbarItem(placement: .automatic) {
                sectionTabs
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .principal) {
                sectionControls
            }

            ToolbarItem(placement: .automatic) {
                Spacer()
            }

            ToolbarItem(placement: .automatic) {
                sectionTabs
            }
        }
    }

    @ViewBuilder
    private var sectionControls: some View {
        switch selectedSection {
        case .notes:
            noteSlots
        case .flashcards:
            flashcardTabs
        }
    }

    private var noteSlots: some View {
        HStack(spacing: 10) {
            ForEach(Self.slotColors.indices, id: \.self) { slot in
                let color = Self.slotColors[slot]

                Button {
                    selectedSlot = slot
                } label: {
                    Circle()
                        .fill(selectedSlot == slot ? color : .clear)
                        .overlay {
                            Circle().stroke(
                                color,
                                lineWidth: selectedSlot == slot ? 2.5 : 3.5
                            )
                        }
                        .frame(width: 18, height: 18)
                        .frame(width: 28, height: 28)
                        .contentShape(Circle())
                }
                .buttonStyle(NoteSlotButtonStyle())
                .accessibilityLabel("\(Self.slotNames[slot]) note")
                .accessibilityValue(selectedSlot == slot ? "Selected" : "")
            }
        }
    }

    private var flashcardTabs: some View {
        HStack(spacing: 4) {
            ForEach(FlashcardMode.allCases) { mode in
                tabButton(mode.title, isSelected: flashcardMode == mode) {
                    flashcardMode = mode
                }
            }
        }
    }

    private var sectionTabs: some View {
        HStack(spacing: 4) {
            ForEach(AppSection.allCases) { section in
                tabButton(section.title, isSelected: selectedSection == section) {
                    selectedSection = section
                }
            }
        }
    }

    private func tabButton(
        _ title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                .padding(.horizontal, 12)
                .frame(height: 28)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.primary.opacity(0.1))
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct NoteSlotButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(
                .spring(response: 0.2, dampingFraction: 1),
                value: configuration.isPressed
            )
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
