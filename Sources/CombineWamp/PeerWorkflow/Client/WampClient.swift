import Combine
import Foundation
import FoundationExtensions

/// Client is a peer in WAMP protocol that defines one or more of the following roles:
/// - publisher: a peer that announces events in one of more topics
/// - subscriber: a peer that subscribes for events in one of more topics
/// - caller: a peer that calls RPC procedures
/// - callee: a peer that register and executes RPC procedures
public struct WampClient {
    let session: WampSession
    let roles: Set<WampRole>

    init(session: WampSession, roles: Set<WampRole>) {
        self.session = session
        self.roles = roles
    }

    public var asPublisher: WampPublisher? {
        roles.contains(.publisher) ? WampPublisher(session: session) : nil
    }

    public var asSubscriber: WampSubscriber? {
        roles.contains(.subscriber) ? WampSubscriber(session: session) : nil
    }

    public var asCaller: WampCaller? {
        roles.contains(.caller) ? WampCaller(session: session) : nil
    }

    public var asCallee: Void? {
        roles.contains(.callee) ? { fatalError("Not implemented") }() : nil
    }

    /// Client says HELLO, Router says WELCOME:
    /// (https://wamp-proto.org/_static/gen/wamp_latest.html#hello-0)
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
    ///
    /// The unhappy path happens when, after sending a HELLO, the client gets back an ABORT from the Router.
    /// In that case, this Promise is expected to return a `.failure(ModuleError.abort(Message.Abort))`
    /// (https://wamp-proto.org/_static/gen/wamp_latest.html#abort-0)
    /// ,------.          ,------.
    /// |Client|          |Router|
    /// `--+---'          `--+---'
    ///    |      HELLO      |
    ///    | ---------------->
    ///    |                 |
    ///    |      ABORT      |
    ///    | <----------------
    /// ,--+---.          ,--+---.
    /// |Client|          |Router|
    /// `------'          `------'
    public func sayHello() -> Publishers.Promise<Message.Welcome, ModuleError> {
        let messageBus = session.messageBus

        return session.send(
            Message.hello(.init(realm: session.realm, details: .roles(roles)))
        )
        .flatMap { _ in
            messageBus
                .first()
                .mapError(absurd)
                .flatMapResult { message in
                    switch message {
                    case let .welcome(welcome):
                        return .init(value: welcome)
                    case let .abort(abort):
                        return .init(error: ModuleError.abort(abort))
                    default:
                        return .init(error: ModuleError.wampError(.protocolViolation))
                    }
                }
                .promise
        }
        .promise
    }

    /// Client says GOODBYE, Router says GOODBYE:
    /// (https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing)
    /// ,------.          ,------.
    /// |Client|          |Router|
    /// `--+---'          `--+---'
    ///    |     GOODBYE     |
    ///    | ---------------->
    ///    |                 |
    ///    |     GOODBYE     |
    ///    | <----------------
    /// ,--+---.          ,--+---.
    /// |Client|          |Router|
    /// `------'          `------'
    public func sayGoodbye() -> Publishers.Promise<Message.Goodbye, ModuleError> {
        let messageBus = session.messageBus

        return session.send(
            Message.goodbye(.init(details: [:], reason: .systemShutdown))
        )
        .mapError { _ in .wampError(WampError.networkFailure) }
        .flatMap { _ -> Publishers.Promise<Message.Goodbye, ModuleError> in
            messageBus
                .compactMap { message in
                    guard case let .goodbye(goodbye) = message,
                          goodbye.reason.isAck
                    else { return nil }
                    return goodbye
                }
                .first()
                .setFailureType(to: ModuleError.self)
                .promise
        }
        .promise
    }

    /// Router says GOODBYE, we as Client must reply GOODBYE:
    /// (https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing)
    /// ,------.          ,------.
    /// |Client|          |Router|
    /// `--+---'          `--+---'
    ///    |     GOODBYE     |
    ///    | <----------------
    ///    |                 |
    ///    |     GOODBYE     |
    ///    | ---------------->
    /// ,--+---.          ,--+---.
    /// |Client|          |Router|
    /// `------'          `------'
    func replyGoodbye() -> Publishers.Promise<Void, ModuleError> {
        session.send(
            Message.goodbye(.init(details: [:], reason: .goodbyeAndOut))
        )
    }
}
