public enum WebSocketCloseCodes: Int {
    case normal = 1000
    case error = 3002
}

public struct WampClose {
    public let uri: URI
    public let code: WebSocketCloseCodes

    private init(uri: String, code: WebSocketCloseCodes) {
        self.uri = .init(unverified: uri)
        self.code = code
    }

    public static let systemShutdown = WampClose(uri: "wamp.close.system_shutdown", code: .normal)
    public static let closeRealm = WampClose(uri: "wamp.close.close_realm", code: .normal)
    public static let goodbyeAndOut = WampClose(uri: "wamp.close.goodbye_and_out", code: .normal)
    public static let protocolViolation = WampClose(uri: "wamp.error.protocol_violation", code: .error)
}
