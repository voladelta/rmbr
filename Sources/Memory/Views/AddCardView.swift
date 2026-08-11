import SwiftData
import SwiftUI

struct AddCardView: View {
    @Environment(\.modelContext) private var modelContext

    @FocusState private var focusedField: Field?
    @State private var question = ""
    @State private var answer = ""

    var body: some View {
        Form {
            Section("Question") {
                MarkdownEditorView(text: $question, minHeight: 160)
                    .focused($focusedField, equals: .question)
            }

            Section("Answer") {
                MarkdownEditorView(text: $answer, minHeight: 220)
                    .focused($focusedField, equals: .answer)
            }

            Button("Save MemoryCard", action: saveCard)
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(!canSave)
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            focusedField = .question
        }
    }

    private var canSave: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveCard() {
        guard canSave else {
            return
        }

        modelContext.insert(MemoryCard(
            questionMarkdown: question.trimmingCharacters(in: .whitespacesAndNewlines),
            answerMarkdown: answer.trimmingCharacters(in: .whitespacesAndNewlines)
        ))

        question = ""
        answer = ""
        focusedField = .question
    }

    private enum Field {
        case question
        case answer
    }
}
