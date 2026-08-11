import Foundation
import SwiftData

@Model
final class MemoryCard {
    @Attribute(.unique) var id: UUID

    var questionMarkdown: String
    var answerMarkdown: String

    var createdAt: Date
    var updatedAt: Date

    var dueAt: Date?
    var lastReviewedAt: Date?

    var stability: Double?
    var difficulty: Double?
    var elapsedDays: Int
    var scheduledDays: Int

    var reps: Int
    var lapses: Int

    var stateRaw: String

    init(
        id: UUID = UUID(),
        questionMarkdown: String,
        answerMarkdown: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        dueAt: Date? = .now,
        lastReviewedAt: Date? = nil,
        stability: Double? = nil,
        difficulty: Double? = nil,
        elapsedDays: Int = 0,
        scheduledDays: Int = 0,
        reps: Int = 0,
        lapses: Int = 0,
        stateRaw: String = MemoryCardState.new.rawValue
    ) {
        self.id = id
        self.questionMarkdown = questionMarkdown
        self.answerMarkdown = answerMarkdown
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.dueAt = dueAt
        self.lastReviewedAt = lastReviewedAt
        self.stability = stability
        self.difficulty = difficulty
        self.elapsedDays = elapsedDays
        self.scheduledDays = scheduledDays
        self.reps = reps
        self.lapses = lapses
        self.stateRaw = stateRaw
    }
}

enum MemoryCardState: String, Codable, CaseIterable {
    case new
    case learning
    case review
    case relearning
}

enum ReviewRating: Int, CaseIterable, Identifiable {
    case again = 1
    case hard = 2
    case good = 3
    case easy = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .again: "Again"
        case .hard: "Hard"
        case .good: "Good"
        case .easy: "Easy"
        }
    }
}
