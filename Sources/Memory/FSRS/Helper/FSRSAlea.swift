import Foundation

final class FSRSAlea {
    private var carry = 1
    private var s0: Double
    private var s1: Double
    private var s2: Double

    init(seed: String? = nil) {
        let mash = Mash()
        s0 = mash.hash(" ")
        s1 = mash.hash(" ")
        s2 = mash.hash(" ")

        let seedValue = seed ?? String(Date().timeIntervalSince1970)
        s0 = Self.wrappedUnit(s0 - mash.hash(seedValue))
        s1 = Self.wrappedUnit(s1 - mash.hash(seedValue))
        s2 = Self.wrappedUnit(s2 - mash.hash(seedValue))
    }

    func next() -> Double {
        let value = 2_091_639 * s0 + Double(carry) * 2.3283064365386963e-10
        let integer = value.rounded(.down)
        s0 = s1
        s1 = s2
        carry = Int(integer)
        s2 = value - integer
        return s2
    }

    private static func wrappedUnit(_ value: Double) -> Double {
        value < 0 ? value + 1 : value
    }
}

private final class Mash {
    private static let modulus = 4_294_967_296.0
    private static let scale = 2.3283064365386963e-10

    private var state = Double(0xefc8249d)

    func hash(_ value: String) -> Double {
        for codeUnit in value.utf16 {
            state += Double(codeUnit)
            var hash = 0.02519603282416938 * state
            state = uint32(hash)
            hash -= state
            hash *= state
            state = uint32(hash)
            hash -= state
            state += hash * Self.modulus
        }
        return uint32(state) * Self.scale
    }

    private func uint32(_ value: Double) -> Double {
        let remainder = value.rounded(.towardZero).truncatingRemainder(dividingBy: Self.modulus)
        return remainder < 0 ? remainder + Self.modulus : remainder
    }
}
