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
        let item = try? scheduler.next(
            card: fsrsCard,
            now: reviewedAt,
            grade: fsrsRating(from: rating)
        )
        let next = item?.card

        return ReviewSchedule(
            stability: next?.stability ?? card.stability ?? 0,
            difficulty: next?.difficulty ?? card.difficulty ?? 0,
            scheduledDays: Int(next?.scheduledDays ?? Double(card.scheduledDays)),
            dueAt: next?.due ?? card.dueAt ?? reviewedAt,
            state: appCardState(from: next?.state ?? fsrsCardState(from: card.stateRaw))
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
