import XCTest
@testable import Memory

final class FSRSAleaTests: XCTestCase {
    func testSeededSequenceMatchesAlea() {
        assertSequence(
            seed: "test",
            expected: [
                0.54422832140699029,
                0.7071346458978951,
                0.72471046820282936,
                0.18215877166949213,
                0.40387626527808607,
            ]
        )
        assertSequence(
            seed: "1720000000.0_1_0.0",
            expected: [
                0.019391815410926938,
                0.67677710251882672,
                0.062126339413225651,
                0.67762478091754019,
                0.38194481981918216,
            ]
        )
    }

    private func assertSequence(seed: String, expected: [Double]) {
        let generator = FSRSAlea(seed: seed)
        XCTAssertEqual((0..<expected.count).map { _ in generator.next() }, expected)
    }
}
