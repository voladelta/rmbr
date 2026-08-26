import Foundation

public struct IPreview {
    var recordLog: RecordLog
    
    init(recordLog: RecordLog) {
        self.recordLog = recordLog
    }
    
    subscript(rating: Rating) -> RecordLogItem? {
        get {
            recordLog[rating]
        }
        set {
            recordLog[rating] = newValue
        }
    }
}

public protocol IScheduler {
    var preview: IPreview { get }
    func review(_ g: Rating) -> RecordLogItem
}

public struct RescheduleOptions {
    var recordLogHandler: ((_ recordLog: RecordLogItem?) -> RecordLogItem?)?

    var reviewsOrderBy: ((_ a: ReviewLog, _ b: ReviewLog) -> Bool)?

    var skipManual: Bool = true

    var updateMemoryState: Bool = false

    var now: Date = Date()

    var firstCard: Card?
}

public struct IReschedule: Equatable {
    var collections: [RecordLogItem?]
    var rescheduleItem: RecordLogItem?
}
