import Foundation

/// https://wamp-proto.org/_static/gen/wamp_latest.html#uris
public struct URI: Equatable, RawRepresentable, CustomStringConvertible, LosslessStringConvertible, Codable {
    public let rawValue: String
    public let isWildcard: Bool

    public init?(_ description: String) {
        self.init(rawValue: description)
    }

    /// Used as an identifier. In this mode, wildcards are not allowed.
    /// Using strict URI as defined here: https://wamp-proto.org/_static/gen/wamp_latest.html#strict-uris
    /// More information about wildcards here: https://wamp-proto.org/_static/gen/wamp_latest.html#relaxed-loose-uris
    public init?(rawValue: String) {
        guard !rawValue.starts(with: "wamp.") else { return nil }
        let pattern = #"^([0-9a-z_]+\.)*([0-9a-z_]+)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(rawValue.startIndex..<rawValue.endIndex, in: rawValue)
        let matches = regex.matches(in: rawValue, options: .anchored, range: range)
        guard matches.count == 1 else { return nil }
        guard matches[0].range == range else { return nil }
        self.rawValue = rawValue
        self.isWildcard = false
    }

    /// Used for subscribing to topics using wildcards. In this mode, an empty URI component will be a wildcard
    /// Using strict URI as defined here: https://wamp-proto.org/_static/gen/wamp_latest.html#strict-uris
    /// More information about wildcards here: https://wamp-proto.org/_static/gen/wamp_latest.html#relaxed-loose-uris
    public init?(wildcard: String) {
        guard !wildcard.starts(with: "wamp.") else { return nil }
        let pattern = #"^(([0-9a-z_]+\.)|\.)*([0-9a-z_]+)?$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(wildcard.startIndex..<wildcard.endIndex, in: wildcard)
        let matches = regex.matches(in: wildcard, options: .anchored, range: range)
        guard matches.count == 1 else { return nil }
        guard matches[0].range == range else { return nil }
        self.rawValue = wildcard
        self.isWildcard = wildcard.contains("..") || wildcard.hasPrefix(".") || wildcard.hasSuffix(".")
    }

    init(unverified: String, isWildcard: Bool = false) {
        self.rawValue = unverified
        self.isWildcard = isWildcard
    }

    public var description: String { rawValue }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let uri = URI(value) else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value \(value) for URI") }
        self = uri
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension URI {
    enum WebSocketSubprotocol {
        static var json = URI(unverified: "wamp.2.json")
        static var msgpack = URI(unverified: "wamp.2.msgpack")
    }
}
