import Foundation
import SwiftData

@Model
final class CardReviewLog {
    @Attribute(.unique) var id: UUID
    var cardID: UUID

    var reviewedAt: Date
    var ratingRaw: String

    var stabilityBefore: Double?
    var difficultyBefore: Double?
    var stabilityAfter: Double?
    var difficultyAfter: Double?

    var dueBefore: Date?
    var dueAfter: Date?

    init(
        id: UUID = UUID(),
        cardID: UUID,
        reviewedAt: Date = .now,
        ratingRaw: String,
        stabilityBefore: Double?,
        difficultyBefore: Double?,
        stabilityAfter: Double?,
        difficultyAfter: Double?,
        dueBefore: Date?,
        dueAfter: Date?
    ) {
        self.id = id
        self.cardID = cardID
        self.reviewedAt = reviewedAt
        self.ratingRaw = ratingRaw
        self.stabilityBefore = stabilityBefore
        self.difficultyBefore = difficultyBefore
        self.stabilityAfter = stabilityAfter
        self.difficultyAfter = difficultyAfter
        self.dueBefore = dueBefore
        self.dueAfter = dueAfter
    }
}
