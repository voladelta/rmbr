import SwiftData
import SwiftUI

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MemoryCard.dueAt, order: .forward) private var cards: [MemoryCard]

    @State private var answerVisible = false

    private let reviewService = ReviewService()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Review")
                    .font(.title2.bold())

                Spacer()

                Text("\(dueCards.count) due")
                    .foregroundStyle(.secondary)
            }

            if let card = dueCards.first {
                reviewCard(card)
            } else {
                ContentUnavailableView(
                    "No Cards Due",
                    systemImage: "checkmark.circle",
                    description: Text("Add a card or come back when the next review is due.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }

    private var dueCards: [MemoryCard] {
        let now = Date()
        return cards.filter { card in
            guard let dueAt = card.dueAt else {
                return true
            }

            return dueAt <= now
        }
    }

    @ViewBuilder
    private func reviewCard(_ card: MemoryCard) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Question")
                .font(.headline)

            ScrollView {
                Text(card.questionMarkdown)
                    .font(.system(.title3, design: .rounded))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 120)

            if answerVisible {
                Divider()

                Text("Answer")
                    .font(.headline)

                ScrollView {
                    Text(card.answerMarkdown)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 160)

                HStack {
                    ForEach(ReviewRating.allCases) { rating in
                        Button(rating.title) {
                            review(card, rating: rating)
                        }
                        .keyboardShortcut(keyEquivalent(for: rating), modifiers: [])
                    }
                }
            } else {
                Button("Show Answer") {
                    answerVisible = true
                }
                .keyboardShortcut(.space, modifiers: [])
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private func review(_ card: MemoryCard, rating: ReviewRating) {
        reviewService.review(card: card, rating: rating, in: modelContext)
        answerVisible = false
    }

    private func keyEquivalent(for rating: ReviewRating) -> KeyEquivalent {
        switch rating {
        case .again: "1"
        case .hard: "2"
        case .good: "3"
        case .easy: "4"
        }
    }
}
