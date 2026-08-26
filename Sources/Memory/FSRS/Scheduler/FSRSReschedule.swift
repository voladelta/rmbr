import Foundation

class FSRSReschedule {
    private var fsrs: FSRS
    
    init(fsrs: FSRS) {
        self.fsrs = fsrs
    }
    
    func replay(
        card: Card,
        reviewDate: Date,
        rating: Rating
    ) throws -> RecordLogItem {
        try fsrs.next(card: card, now: reviewDate, grade: rating)
    }
    
    func handleManualRating(
        card: Card,
        state: CardState,
        reviewDate: Date,
        elapsedDays: Double,
        stability: Double?,
        difficulty: Double?,
        due: Date?
    ) throws -> RecordLogItem {
        var log: ReviewLog
        var nextCard: Card

        if state == .new {
            log = .init(
                rating: .manual,
                state: state,
                due: due ?? reviewDate,
                stability: card.stability,
                difficulty: card.difficulty,
                elapsedDays: elapsedDays,
                lastElapsedDays: card.elapsedDays,
                scheduledDays: card.scheduledDays,
                review: reviewDate
            )
            nextCard = FSRSDefaults().createEmptyCard(
                now: reviewDate
            )
            nextCard.lastReview = reviewDate
        } else {
            guard let due = due else {
                throw FSRSError(.invalidParam, "reschedule: due is required for manual rating")
            }
            let schduledDays = Date.dateDiff(now: due, pre: reviewDate, unit: .days)
            log = .init(
                rating: .manual,
                state: card.state,
                due: card.lastReview ?? card.due,
                stability: card.stability,
                difficulty: card.difficulty,
                elapsedDays: elapsedDays,
                lastElapsedDays: card.elapsedDays,
                scheduledDays: card.scheduledDays,
                review: reviewDate
            )
            nextCard = .init(
                due: due,
                stability: stability ?? card.stability,
                difficulty: difficulty ?? card.difficulty,
                elapsedDays: elapsedDays,
                scheduledDays: schduledDays,
                reps: card.reps + 1,
                lapses: card.lapses,
                state: state,
                lastReview: reviewDate
            )
        }
        return .init(card: nextCard, log: log)
    }

    
    func reschedule(
        currentCard: Card,
        reviews: [ReviewLog]
    ) throws -> [RecordLogItem] {
        var result = [RecordLogItem]()
        var curCard = FSRSDefaults().createEmptyCard(now: currentCard.due)
        for review in reviews {
            var item: RecordLogItem
            if review.rating == .manual {
                var interval = 0.0
                if curCard.state != .new, let lastReview = curCard.lastReview {
                    interval = Date.dateDiff(
                        now: review.review,
                        pre: lastReview,
                        unit: .days
                    )
                }
                guard let state = review.state else {
                    throw FSRSError(.invalidParam, "reschedule: state is required for manual rating")
                }
                item = try handleManualRating(
                    card: curCard,
                    state: state,
                    reviewDate: review.review,
                    elapsedDays: interval,
                    stability: review.stability,
                    difficulty: review.difficulty,
                    due: review.due
                )
                result.append(item)
                curCard = item.card
            } else {
                do {
                    item = try replay(
                        card: curCard, reviewDate: review.review, rating: review.rating
                    )
                    result.append(item)
                    curCard = item.card
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        return result
    }

    func calculateManualRecord(
        currentCard: Card,
        now: Date,
        recordLogItem: RecordLogItem?,
        updateMemory: Bool = false
    ) throws -> RecordLogItem? {
        guard let item = recordLogItem else { return nil }
        let rescheduleCard = item.card
        let log = item.log
        
        var curCard = currentCard.newCard
        if curCard.due.timeIntervalSince1970 == rescheduleCard.due.timeIntervalSince1970 {
            return nil
        }
        curCard.scheduledDays = Date.dateDiff(
            now: rescheduleCard.due,
            pre: curCard.due,
            unit: .days
        )
        return try handleManualRating(
            card: curCard,
            state: rescheduleCard.state,
            reviewDate: now,
            elapsedDays: log.elapsedDays,
            stability: updateMemory ? rescheduleCard.stability : nil,
            difficulty: updateMemory ? rescheduleCard.difficulty : nil,
            due: rescheduleCard.due
        )
    }
}
