import Combine
import CombineWebSocket
import Foundation
import FoundationExtensions

/// A Session is a transient conversation between two Peers attached to a Realm and running over a Transport.
/// https://wamp-proto.org/_static/gen/wamp_latest.html#realms-sessions-and-transports
public class WampSession {
    public let realm: URI
    public let transport: WampTransport
    public let serialization: WampSerializing
    public let me: WampClient
    private let messageBus = PassthroughSubject<Message, Never>()

    /// A Session is a transient conversation between two Peers attached to a Realm and running over a Transport.
    public init(transport: WampTransport, serialization: WampSerializing, realm: URI, me: WampClient) {
        self.transport = transport
        self.serialization = serialization
        self.realm = realm
        self.me = me
    }

    public func connect() -> AnyPublisher<Message.Welcome, ModuleError> {
        let client = self.me
        let serializer = self.serialization
        let messageBus = self.messageBus

        return transport
            .autoconnect()
            .handleEvents(
                receiveOutput: { event in
                    switch event {
                    case let .incomingMessage(message):
                        self.gotPossibleMessage(serializer.deserialize(message))
                    case .connected:
                        self.didConnect()
                    }
                },
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.didDisconnect()
                    case let .failure(error):
                        self?.didDisconnect(with: error)
                    }
                }
            )
            .mapError { _ in .wampError(WampError.networkFailure) }
            .flatMap { event -> AnyPublisher<Void, ModuleError> in
                switch event {
                case .connected:
                    return client.sayHello(session: self).eraseToAnyPublisher()
                case .incomingMessage:
                    return Empty().eraseToAnyPublisher()
                }
            }
            .flatMap { _ -> AnyPublisher<Message.Welcome, ModuleError> in
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
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func send(_ message: Message) -> Publishers.Promise<Void, ModuleError> {
        serialization
            .serialize(message)
            .mapError { ModuleError.serializingError($0) }
            .promise
            .flatMap { [weak self] message -> Publishers.Promise<Void, ModuleError> in
                guard let self = self else { return .init(error: .sessionIsNotValid) }
                return self.transport
                    .send(message: message)
                    .mapError { _ in ModuleError.wampError(.networkFailure) }
                    .promise
            }
            .promise
    }
}

extension WampSession {
    private func didConnect() {
    }

    private func gotPossibleMessage(_ possibleMessage: Result<Message, Error>) {
        switch possibleMessage {
        case let .success(message):
            messageBus.send(message)
        case let .failure(error):
            cantParseMessage(error: error)
        }
    }

    private func didDisconnect() {
    }

    private func didDisconnect(with error: Error) {
    }

    private func cantParseMessage(error: Error) {
    }
}
