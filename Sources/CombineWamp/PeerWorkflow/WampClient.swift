import Combine
import Foundation
import FoundationExtensions

/// Client is a peer in WAMP protocol that defines one or more of the following roles:
/// - publisher: a peer that announces events in one of more topics
/// - subscriber: a peer that subscribes for events in one of more topics
/// - caller: a peer that calls RPC procedures
/// - callee: a peer that register and executes RPC procedures
public struct WampClient: WampPeer {
    public init(
        publish: ((URI) -> AnySubscriber<String, Error>)?,
        subscribe: ((URI) -> AnyPublisher<String, Error>)?,
        call: ((URI) -> Publishers.Promise<String, Error>)?,
        respond: ((URI) -> Publishers.Promise<String, Error>)?
    ) {
        self.publish = publish
        self.subscribe = subscribe
        self.call = call
        self.respond = respond
    }

    private let publish: ((URI) -> AnySubscriber<String, Error>)?
    private let subscribe: ((URI) -> AnyPublisher<String, Error>)?
    private let call: ((URI) -> Publishers.Promise<String, Error>)?
    private let respond: ((URI) -> Publishers.Promise<String, Error>)?

    private var roles: Set<WampRole> {
        Set<WampRole>.init(
            [
                publish != nil ? WampRole.publisher : nil,
                subscribe != nil ? WampRole.subscriber : nil,
                call != nil ? WampRole.caller : nil,
                respond != nil ? WampRole.callee : nil
            ].compactMap(identity)
        )
    }
}

extension WampClient {
    /// Client says HELLO, Router says WELCOME:
    ///
    /// ,------.          ,------.
    /// |Client|          |Router|
    /// `--+---'          `--+---'
    ///    |      HELLO      |
    ///    | ---------------->
    ///    |                 |
    ///    |     WELCOME     |
    ///    | <----------------
    /// ,--+---.          ,--+---.
    /// |Client|          |Router|
    /// `------'          `------'
    func sayHello(session: WampSession) -> Publishers.Promise<Void, ModuleError> {
        session.send(
            Message.hello(.init(realm: session.realm, details: .roles(roles)))
        )
    }
}
