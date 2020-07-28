public enum WebSocketCloseCodes: Int {
    case normal = 1000
    case error = 3002
}

public struct WampClose {
    public let uri: URI
    public let code: WebSocketCloseCodes

    private init(uri: String) {
        self.uri = .init(unverified: uri)
        self.code = .normal
    }

    private init(error: WampError) {
        self.uri = error.uri
        self.code = .error
    }

    public static let systemShutdown = WampClose(uri: "wamp.close.system_shutdown")
    public static let closeRealm = WampClose(uri: "wamp.close.close_realm")
    public static let goodbyeAndOut = WampClose(uri: "wamp.close.goodbye_and_out")
    public static let protocolViolation = WampClose(error: WampError.protocolViolation)
}
