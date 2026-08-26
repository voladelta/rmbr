import Foundation

public class FSRS: FSRSAlgorithm {
    func `repeat`(
        card: Card,
        now: Date,
        _ completion: ((_ log: IPreview) -> IPreview)? = nil
    ) -> IPreview {
        let obj = params.enableShortTerm
        ? BasicScheduler(card: card, reviewTime: now, algorithm: self)
        : LongTermScheduler(card: card, reviewTime: now, algorithm: self)
        let log = obj.preview
        if let completion = completion {
            return completion(log)
        } else {
            return log
        }
    }
    
    func next(
        card: Card,
        now: Date,
        grade: Rating,
        completion: ((_ log: RecordLogItem) -> RecordLogItem)? = nil
    ) throws -> RecordLogItem {
        if grade == .manual {
            throw FSRSError(.invalidRating, "Cannot review a manual rating")
        }
        let obj = params.enableShortTerm
        ? BasicScheduler(card: card, reviewTime: now, algorithm: self)
        : LongTermScheduler(card: card, reviewTime: now, algorithm: self)
        let log = obj.review(grade)
        if let completion = completion {
            return completion(log)
        } else {
            return log
        }
    }
    
    func getRetrievability(
        card: Card,
        now: Date = Date()
    ) -> (string: String, number: Double) {
        let processed = card.newCard
        let time = processed.state != .new
        ? max(Date.dateDiff(now: now, pre: processed.lastReview, unit: .days), 0)
        : 0
        let retrievability = processed.state != .new
        ? forgettingCurve(elapsedDays: time, stability: processed.stability.toFixedNumber(8))
        : 0
        return ("\((retrievability * 100).toFixed(2))%", retrievability)
    }
    
    func rollback(
        card: Card,
        log: ReviewLog,
        completion: ((Card) -> Card)? = nil
    ) throws -> Card {
        let processdCard = card.newCard
        let processedLog = log.newLog
        
        guard processedLog.rating != .manual else {
            throw FSRSError(.invalidRating, "Cannot rollback a manual rating")
        }
        var lastDue: Date, lastReview: Date?, lastLapses: Int
        guard let state = processedLog.state else {
            throw FSRSError(.invalidParam, "Rollback card must have a state")
        }
        switch state {
        case .new:
            guard let due = processedLog.due else {
                throw FSRSError(.invalidParam, "Rollback card must have a due date")
            }
            lastDue = due
            lastReview = nil
            lastLapses = 0
        case .learning, .review, .relearning:
            lastDue = processedLog.review
            lastReview = processedLog.due
            lastLapses = processdCard.lapses - (
                (processedLog.rating == .again && processedLog.state == .review) ? 1 : 0
            )
        }
        var previousCard = processdCard.newCard
        previousCard.due = lastDue
        previousCard.stability = processedLog.stability ?? 0
        previousCard.difficulty = processedLog.difficulty ?? 0
        previousCard.elapsedDays = processedLog.lastElapsedDays
        previousCard.scheduledDays = processedLog.scheduledDays
        previousCard.reps = max(0, processdCard.reps - 1)
        previousCard.lapses = max(0, lastLapses)
        previousCard.state = state
        previousCard.lastReview = lastReview
        
        if let completion = completion {
            return completion(previousCard)
        } else {
            return previousCard
        }
    }
    
    func forget(
        card: Card,
        now: Date,
        resetCount: Bool = false,
        _ completion: ((_ recordLogItem: RecordLogItem) -> RecordLogItem)? = nil
    ) -> RecordLogItem {
        let processedCard = card.newCard
        let scheduledDay = processedCard.state == .new
        ? 0
        : Date.dateDiff(now: now, pre: processedCard.lastReview, unit: .days)
        let forgetLog = ReviewLog(
            rating: .manual,
            state: processedCard.state,
            due: processedCard.due,
            stability: processedCard.stability,
            difficulty: processedCard.difficulty,
            elapsedDays: 0,
            lastElapsedDays: processedCard.elapsedDays,
            scheduledDays: scheduledDay,
            review: now
        )
        let forgetCard = Card(
            due: now,
            reps: resetCount ? 0 : processedCard.reps,
            lapses: resetCount ? 0 : processedCard.lapses,
            state: .new,
            lastReview: processedCard.lastReview
        )
        let log = RecordLogItem(card: forgetCard, log: forgetLog)
        if let completion = completion {
            return completion(log)
        } else {
            return log
        }
    }


    func reschedule(
        currentCard: Card,
        reviews: [ReviewLog],
        options: RescheduleOptions
    ) throws -> IReschedule {
        var reviews = reviews
        if let sortOrder = options.reviewsOrderBy {
            reviews.sort(by: sortOrder)
        }
        if options.skipManual {
            reviews = reviews.filter({ $0.rating != .manual })
        }
        let rescheduleSvc = FSRSReschedule(fsrs: self)
        let items = try rescheduleSvc.reschedule(
            currentCard: options.firstCard ?? FSRSDefaults().createEmptyCard(),
            reviews: reviews
        )
        
        let curCard = currentCard.newCard
        let manualItem = try rescheduleSvc.calculateManualRecord(
            currentCard: curCard,
            now: options.now,
            recordLogItem: items.last ?? nil,
            updateMemory: options.updateMemoryState
        )
        if let handler = options.recordLogHandler {
            return .init(
                collections: items.map(handler),
                rescheduleItem: manualItem == nil ? nil : handler(manualItem)
            )
        } else {
            return .init(collections: items, rescheduleItem: manualItem)
        }
    }
}
