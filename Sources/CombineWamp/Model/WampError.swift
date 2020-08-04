public struct WampError: Error {
    public let uri: URI

    private init(string: String) {
        self.uri = URI(unverified: string)
    }

    private init(uri: URI) {
        self.uri = uri
    }

    // Peer provided an incorrect URI for any URI-based attribute of WAMP message, such as realm, topic or procedure
    public static let invalidURI = WampError(string: "wamp.error.invalid_uri")

    // A Dealer could not perform a call, since no procedure is currently registered under the given URI.
    public static let noSuchProcedure = WampError(string: "wamp.error.no_such_procedure")

    // A procedure could not be registered, since a procedure with the given URI is already registered.
    public static let procedureAlreadyExists = WampError(string: "wamp.error.procedure_already_exists")

    // A Dealer could not perform an unregister, since the given registration is not active.
    public static let noSuchRegistration = WampError(string: "wamp.error.no_such_registration")

    // A Broker could not perform an unsubscribe, since the given subscriptionId is not active.
    public static let noSuchSubscription = WampError(string: "wamp.error.no_such_subscription")

    // A call failed since the given argument types or values are not acceptable to the called procedure.
    public static let invalidArgument = WampError(string: "wamp.error.invalid_argument")

    // A Peer received invalid WAMP protocol message (e.g. HELLO message after session was already established) - used as a ABORT reply reason.
    public static let protocolViolation = WampError(string: "wamp.error.protocol_violation")

    // A join, call, register, publish or subscribe failed, since the Peer is not authorized to perform the operation.
    public static let notAuthorized = WampError(string: "wamp.error.not_authorized")

    // A Dealer or Broker could not determine if the Peer is authorized to perform a join, call, register, publish or subscribe, since the authorization operation itself failed. E.g. a custom authorizer did run into an error.
    public static let authorizationFailed = WampError(string: "wamp.error.authorization_failed")

    // Peer wanted to join a non-existing realm (and the Router did not allow to auto-create the realm).
    public static let noSuchRealm = WampError(string: "wamp.error.no_such_realm")

    // A Peer was to be authenticated under a Role that does not (or no longer) exists on the Router. For example, the Peer was successfully authenticated, but the Role configured does not exists - hence there is some misconfiguration in the Router.
    public static let noSuchRole = WampError(string: "wamp.error.no_such_role")

    // A Dealer or Callee canceled a call previously issued
    public static let canceled = WampError(string: "wamp.error.canceled")

    // A Peer requested an interaction with an option that was disallowed by the Router
    public static let optionNotAllowed = WampError(string: "wamp.error.option_not_allowed")

    // A Dealer could not perform a call, since a procedure with the given URI is registered, but Callee Black- and Whitelisting and/or Caller Exclusion lead to the exclusion of (any) Callee providing the procedure.
    public static let noEligibleCallee = WampError(string: "wamp.error.no_eligible_callee")

    // A Router rejected client request to disclose its identity
    public static let optionDisallowedDiscloseMe = WampError(string: "wamp.error.option_disallowed.disclose_me")

    // A Router encountered a network failure
    public static let networkFailure = WampError(string: "wamp.error.network_failure")

    public static func applicationError(uri: URI) -> WampError {
        WampError(uri: uri)
    }
}
