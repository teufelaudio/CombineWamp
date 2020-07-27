import Foundation

/// https://wamp-proto.org/_static/gen/wamp_latest.html#ids
public class RandomNumericID {
    public enum OverflowStrategy {
        case stop
        case resetList
    }

    private var list: [Int]
    private let range: ClosedRange<Int>
    private let overflowStrategy: OverflowStrategy
    private let lock = NSRecursiveLock()

    public init(range: ClosedRange<Int>, overflowStrategy: OverflowStrategy = .resetList) {
        self.range = range
        self.overflowStrategy = overflowStrategy
        self.list = []
    }
}

extension RandomNumericID: IteratorProtocol {
    public typealias Element = WampID

    public func next() -> WampID? {
        lock.lock()
        defer { lock.unlock() }

        if list.count >= (range.upperBound - range.lowerBound) {
            switch overflowStrategy {
            case .stop:
                return nil
            case .resetList:
                list = []
            }
        }

        while true {
            let value = Int.random(in: range)
            // TODO: Hipothetically slow after billions of IDs generated, it could be improved
            // When odds to raffle an available number are tiny, this can be really slow
            // Better algorithms are possibly available
            if list.contains(value) { continue }
            list.append(value)
            return .init(integerLiteral: value)
        }
    }
}

/// https://wamp-proto.org/_static/gen/wamp_latest.html#ids
public class AutoIncrementID {
    public enum OverflowStrategy {
        case stop
        case resetToZero
        case resetToMin
        case resetToSmallestNegative
    }

    private var current: Int
    private let min: Int
    private let max: Int
    private let overflowStrategy: OverflowStrategy
    private let lock = NSRecursiveLock()

    public init(range: ClosedRange<Int>, overflowStrategy: OverflowStrategy = .resetToMin) {
        self.min = range.lowerBound
        self.max = range.upperBound
        self.current = min
        self.overflowStrategy = overflowStrategy
    }
}

extension AutoIncrementID: IteratorProtocol {
    public typealias Element = WampID

    public func next() -> WampID? {
        lock.lock()
        defer { lock.unlock() }

        current += 1

        guard current <= max else {
            switch overflowStrategy {
            case .stop:
                return nil
            case .resetToMin:
                current = min
                return .init(integerLiteral: current)
            case .resetToZero:
                current = 0
                return .init(integerLiteral: current)
            case .resetToSmallestNegative:
                current = Int.min
                return .init(integerLiteral: current)
            }
        }

        return .init(integerLiteral: current)
    }
}
