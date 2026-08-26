import Foundation

class AbstractScheduler: IScheduler {
    var preview: IPreview {
        .init(recordLog: [
            .again: review(.again),
            .hard: review(.hard),
            .good: review(.good),
            .easy: review(.easy)
        ])
    }
    var last: Card
    var current: Card
    var reviewTime: Date
    var next: [Rating: RecordLogItem] = [:]
    var algorithm: FSRSAlgorithm

    init(
        card: Card,
        reviewTime: Date,
        algorithm: FSRSAlgorithm
    ) {
        self.algorithm = algorithm
        self.last = card.newCard
        self.current = card.newCard
        self.reviewTime = reviewTime

        var interval = 0.0
        if current.state != .new && current.lastReview != nil {
            interval = Date.dateDiff(
                now: reviewTime,
                pre: current.lastReview,
                unit: .days
            )
        }
        self.current.lastReview = reviewTime
        self.current.elapsedDays = interval
        self.current.reps += 1
        self.algorithm.seed = "\(reviewTime.timeIntervalSince1970)_\(current.reps)_\(current.difficulty * current.stability)"
    }

    var seed: String {
        get { algorithm.seed ?? "" }
        set { algorithm.seed = newValue }
    }

    func review(_ g: Rating) -> RecordLogItem {
        switch last.state {
        case .new:
            return newState(grade: g)
        case .learning, .relearning:
            return learningState(grade: g)
        case .review:
            return reviewState(grade: g)
        }
    }

    func newState(grade: Rating) -> RecordLogItem {
        preconditionFailure("Subclasses must override newState(grade:)")
    }

    func learningState(grade: Rating) -> RecordLogItem {
        preconditionFailure("Subclasses must override learningState(grade:)")
    }

    func reviewState(grade: Rating) -> RecordLogItem {
        preconditionFailure("Subclasses must override reviewState(grade:)")
    }
    
    func buildLog(rating: Rating) -> ReviewLog {
        .init(rating: rating,
              state: current.state,
              due: last.lastReview ?? last.due,
              stability: current.stability,
              difficulty: current.difficulty,
              elapsedDays: current.elapsedDays,
              lastElapsedDays: last.elapsedDays,
              scheduledDays: current.scheduledDays,
              review: reviewTime
        )
    }
}
