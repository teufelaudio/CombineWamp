public enum WebSocketCloseCodes: Int {
    case normal = 1000
    case error = 3002
}

public struct WampClose: CaseIterable, Equatable {
    public let uri: URI
    public let code: WebSocketCloseCodes
    public let isAck: Bool
    public var needsReply: Bool { !isAck }

    private init(uri: String, isAck: Bool) {
        self.init(uri: .init(unverified: uri), code: .normal, isAck: isAck)
    }

    private init(error: WampError) {
        self.init(uri: error.uri, code: .error, isAck: false)
    }

    init(uri: URI, code: WebSocketCloseCodes, isAck: Bool) {
        self.uri = uri
        self.code = code
        self.isAck = isAck
    }

    /// Please don't use it. It's not properly documented. Only mention says:
    /// The keyword arguments are optional, and if not provided the reason defaults to wamp.close.normal and the message
    /// is omitted from the GOODBYE sent to the closed session.
    ///
    /// However, Crossbar.io examples send this message as acknowledgement, instead of expected "wamp.close.goodbye_and_out".
    /// Not clear if this is a bug on Crossbar. but this will be not publicly available for use, only as a ACK fallback.
    static let normal = WampClose(uri: "wamp.close.normal", isAck: true)

    public static let systemShutdown = WampClose(uri: "wamp.close.system_shutdown", isAck: false)
    public static let closeRealm = WampClose(uri: "wamp.close.close_realm", isAck: false)
    public static let goodbyeAndOut = WampClose(uri: "wamp.close.goodbye_and_out", isAck: true)
    public static let protocolViolation = WampClose(error: WampError.protocolViolation)

    public static var allCases: [WampClose] {
        [.normal, .systemShutdown, .closeRealm, .goodbyeAndOut, .protocolViolation]
    }
}
