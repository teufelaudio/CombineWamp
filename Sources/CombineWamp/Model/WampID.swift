import Foundation
import Combine

public struct WampID: Codable, Equatable, ExpressibleByIntegerLiteral, RawRepresentable {
    public typealias RawValue = Int
    public typealias IntegerLiteralType = Int

    public let value: Int
    public var rawValue: Int { value }

    public init(integerLiteral value: Int) {
        self.value = value
    }

    public init(rawValue: Int) {
        self.value = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        self = .init(integerLiteral: value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension WampID {
    /// https://wamp-proto.org/_static/gen/wamp_latest.html#global-scope-ids
    /// WELCOME.Session
    /// PUBLISHED.Publication
    /// EVENT.Publication
    public static func createSessionScopeIDs() -> AutoIncrementID {
        AutoIncrementID(range: 1...2^53, overflowStrategy: .resetToMin)
    }
}

extension WampID {
    /// https://wamp-proto.org/_static/gen/wamp_latest.html#session-scope-ids
    /// ERROR.Request
    /// PUBLISH.Request
    /// PUBLISHED.Request
    /// SUBSCRIBE.Request
    /// SUBSCRIBED.Request
    /// UNSUBSCRIBE.Request
    /// UNSUBSCRIBED.Request
    /// CALL.Request
    /// CANCEL.Request
    /// RESULT.Request
    /// REGISTER.Request
    /// REGISTERED.Request
    /// UNREGISTER.Request
    /// UNREGISTERED.Request
    /// INVOCATION.Request
    /// INTERRUPT.Request
    /// YIELD.Request
    public static func createGlobalScopeIDs() -> RandomNumericID {
        RandomNumericID(range: 1...2^53, overflowStrategy: .resetList)
    }
}
