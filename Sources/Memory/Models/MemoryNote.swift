import Foundation
import SwiftData

@Model
final class MemoryNote {
    @Attribute(.unique) var id: UUID
    var slot: Int = 0
    var markdown: String
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        slot: Int = 0,
        markdown: String = "# Today\n\n- ",
        updatedAt: Date = .now
    ) {
        self.id = id
        self.slot = slot
        self.markdown = markdown
        self.updatedAt = updatedAt
    }
}
