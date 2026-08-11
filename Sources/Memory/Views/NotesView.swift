import SwiftData
import SwiftUI

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [MemoryNote]

    @State private var selectedSlot = 0
    @State private var markdown = ""
    @State private var slotNotes: [Int: MemoryNote] = [:]
    @State private var loadedNote: MemoryNote?
    @State private var saveTask: Task<Void, Never>?

    private static let slotCount = 7
    private static let slotColors: [Color] = [
        .yellow,
        .orange,
        .red,
        .purple,
        .blue,
        .cyan,
        .green
    ]
    private static let slotNames = [
        "Yellow",
        "Orange",
        "Red",
        "Purple",
        "Blue",
        "Cyan",
        "Green"
    ]

    var body: some View {
        MarkdownEditorView(
            text: $markdown,
            minHeight: 0,
            showsLineNumbers: false,
            usesPlainStyle: true,
            font: .monospacedSystemFont(ofSize: 18, weight: .regular),
            contentInset: .zero
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 14) {
                    ForEach(0..<Self.slotCount, id: \.self) { slot in
                        noteSlotButton(slot)
                    }
                }
            }
        }
        .onAppear(perform: prepareNotes)
        .onChange(of: selectedSlot) { _, newSlot in
            saveTask?.cancel()
            saveNote()
            loadNote(in: newSlot)
        }
        .onChange(of: markdown) { _, _ in
            scheduleAutosave()
        }
        .onDisappear {
            saveTask?.cancel()
            saveNote()
        }
    }

    private func noteSlotButton(_ slot: Int) -> some View {
        let color = Self.slotColors[slot]
        let isSelected = selectedSlot == slot

        return Button {
            selectedSlot = slot
        } label: {
            Circle()
                .fill(isSelected ? color : .clear)
                .overlay {
                    Circle()
                        .stroke(color, lineWidth: 3)
                }
                .frame(width: 18, height: 18)
                .frame(width: 28, height: 28)
                .contentShape(Circle())
        }
        .buttonStyle(NoteSlotButtonStyle())
        .accessibilityLabel("\(Self.slotNames[slot]) note")
        .accessibilityValue(isSelected ? "Selected" : "")
    }

    private func prepareNotes() {
        var notesBySlot: [Int: MemoryNote] = [:]
        let existingNotes = notes.sorted { $0.updatedAt > $1.updatedAt }

        for note in existingNotes {
            if (0..<Self.slotCount).contains(note.slot), notesBySlot[note.slot] == nil {
                notesBySlot[note.slot] = note
            } else if let availableSlot = (0..<Self.slotCount).first(where: { notesBySlot[$0] == nil }) {
                note.slot = availableSlot
                notesBySlot[availableSlot] = note
            }
        }

        for slot in 0..<Self.slotCount where notesBySlot[slot] == nil {
            let note = MemoryNote(
                slot: slot,
                markdown: slot == 0 ? "# Today\n\n- " : ""
            )
            modelContext.insert(note)
            notesBySlot[slot] = note
        }

        slotNotes = notesBySlot
        loadedNote = slotNotes[selectedSlot]
        markdown = loadedNote?.markdown ?? ""
    }

    private func loadNote(in slot: Int) {
        let note = slotNotes[slot] ?? createNote(in: slot)
        slotNotes[slot] = note
        loadedNote = note
        markdown = note.markdown
    }

    private func createNote(in slot: Int) -> MemoryNote {
        let note = MemoryNote(slot: slot, markdown: "")
        modelContext.insert(note)
        return note
    }

    private func scheduleAutosave() {
        guard loadedNote != nil else {
            return
        }

        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                saveNote()
            }
        }
    }

    private func saveNote() {
        guard let loadedNote, loadedNote.markdown != markdown else {
            return
        }

        loadedNote.markdown = markdown
        loadedNote.updatedAt = .now
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
