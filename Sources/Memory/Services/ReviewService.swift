import Foundation
import SwiftData

@MainActor
struct ReviewService {
    private let fsrs = FSRSService()

    func review(card: MemoryCard, rating: ReviewRating, in context: ModelContext, reviewedAt: Date = .now) {
        let stabilityBefore = card.stability
        let difficultyBefore = card.difficulty
        let dueBefore = card.dueAt
        let schedule = fsrs.schedule(card: card, rating: rating, reviewedAt: reviewedAt)

        card.elapsedDays = elapsedDays(since: card.lastReviewedAt, now: reviewedAt)
        card.scheduledDays = schedule.scheduledDays
        card.stability = schedule.stability
        card.difficulty = schedule.difficulty
        card.dueAt = schedule.dueAt
        card.lastReviewedAt = reviewedAt
        card.updatedAt = reviewedAt
        card.reps += 1
        card.stateRaw = schedule.state.rawValue

        if rating == .again {
            card.lapses += 1
        }

        context.insert(CardReviewLog(
            cardID: card.id,
            reviewedAt: reviewedAt,
            ratingRaw: rating.title,
            stabilityBefore: stabilityBefore,
            difficultyBefore: difficultyBefore,
            stabilityAfter: schedule.stability,
            difficultyAfter: schedule.difficulty,
            dueBefore: dueBefore,
            dueAfter: schedule.dueAt
        ))
    }

    private func elapsedDays(since priorReview: Date?, now: Date) -> Int {
        guard let priorReview else {
            return 0
        }

        return max(0, Calendar.current.dateComponents([.day], from: priorReview, to: now).day ?? 0)
    }
}
