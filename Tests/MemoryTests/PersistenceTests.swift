import Foundation
import SwiftData
import XCTest
@testable import Memory

final class PersistenceTests: XCTestCase {
    @MainActor
    func testNotesAndFlashcardsSurviveContainerReopen() throws {
        let storeDirectory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(
            at: storeDirectory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: storeDirectory) }

        let storeURL = storeDirectory.appending(path: "Memory.store")

        do {
            let container = try makeContainer(at: storeURL)
            let context = ModelContext(container)
            context.insert(MemoryNote(slot: 3, markdown: "Persistent note"))
            context.insert(MemoryCard(
                questionMarkdown: "Persistent question",
                answerMarkdown: "Persistent answer"
            ))
            try context.save()
        }

        let reopenedContainer = try makeContainer(at: storeURL)
        let reopenedContext = ModelContext(reopenedContainer)
        let notes = try reopenedContext.fetch(FetchDescriptor<MemoryNote>())
        let cards = try reopenedContext.fetch(FetchDescriptor<MemoryCard>())

        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.slot, 3)
        XCTAssertEqual(notes.first?.markdown, "Persistent note")
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards.first?.questionMarkdown, "Persistent question")
        XCTAssertEqual(cards.first?.answerMarkdown, "Persistent answer")
    }

    @MainActor
    private func makeContainer(at url: URL) throws -> ModelContainer {
        let configuration = ModelConfiguration(url: url)
        return try ModelContainer(
            for: MemoryNote.self,
            MemoryCard.self,
            CardReviewLog.self,
            configurations: configuration
        )
    }
}
