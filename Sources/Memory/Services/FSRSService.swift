import Foundation

struct ReviewSchedule {
    var stability: Double
    var difficulty: Double
    var scheduledDays: Int
    var dueAt: Date
    var state: MemoryCardState
}

struct FSRSService {
    func schedule(card: MemoryCard, rating: ReviewRating, reviewedAt: Date = .now) -> ReviewSchedule {
        let fsrsCard = Card(
            due: card.dueAt ?? reviewedAt,
            stability: card.stability ?? 0,
            difficulty: card.difficulty ?? 0,
            elapsedDays: Double(card.elapsedDays),
            scheduledDays: Double(card.scheduledDays),
            reps: card.reps,
            lapses: card.lapses,
            state: fsrsCardState(from: card.stateRaw),
            lastReview: card.lastReviewedAt
        )
        let scheduler = FSRS(parameters: FSRSParameters())
        // App ratings exclude `.manual`, the only grade rejected by `next`.
        let next = try! scheduler.next(
            card: fsrsCard,
            now: reviewedAt,
            grade: fsrsRating(from: rating)
        ).card

        return ReviewSchedule(
            stability: next.stability,
            difficulty: next.difficulty,
            scheduledDays: Int(next.scheduledDays),
            dueAt: next.due,
            state: appCardState(from: next.state)
        )
    }

    private func fsrsRating(from rating: ReviewRating) -> Rating {
        switch rating {
        case .again: .again
        case .hard: .hard
        case .good: .good
        case .easy: .easy
        }
    }

    private func fsrsCardState(from rawValue: String) -> CardState {
        switch MemoryCardState(rawValue: rawValue) {
        case .learning: .learning
        case .review: .review
        case .relearning: .relearning
        case .new, nil: .new
        }
    }

    private func appCardState(from state: CardState) -> MemoryCardState {
        switch state {
        case .new: .new
        case .learning: .learning
        case .review: .review
        case .relearning: .relearning
        }
    }
}
