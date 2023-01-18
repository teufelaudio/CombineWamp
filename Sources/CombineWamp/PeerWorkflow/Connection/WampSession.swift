import Combine
import Foundation
import FoundationExtensions

/// A Session is a transient conversation between two Peers attached to a Realm and running over a Transport.
/// https://wamp-proto.org/_static/gen/wamp_latest.html#realms-sessions-and-transports
public class WampSession: Cancellable {
    private let transport: WampTransport
    private let serialization: WampSerializing
    let messageBus = PassthroughSubject<Message, Never>()
    var cancellables = Set<AnyCancellable>()
    let idGenerator = WampID.createGlobalScopeIDs()
    private let clientFactory: (WampSession) -> WampClient
    public var client: WampClient {
        clientFactory(self)
    }

    /// A Session is a transient conversation between two Peers attached to a Realm and running over a Transport.
    public init(transport: WampTransport, serialization: WampSerializing, client: @escaping (WampSession) -> WampClient) {
        self.transport = transport
        self.serialization = serialization
        self.clientFactory = client
    }

    public func connect() -> AnyPublisher<Message.Welcome, ModuleError> {
        return transport
            .autoconnect()
            .handleEvents(
                receiveOutput: { [weak self] event in
                    switch event {
                    case let .incomingMessage(message):
                        self?.gotPossibleMessage(message)
                    case .connected:
                        self?.didConnect()
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
            .flatMap { [weak self] event -> AnyPublisher<Message.Welcome, ModuleError> in
                guard let self = self else { return Fail(error: ModuleError.sessionIsNotValid).eraseToAnyPublisher() }
                switch event {
                case .connected:
                    return self.client.sayHello().eraseToAnyPublisher()
                case .incomingMessage:
                    return Empty().eraseToAnyPublisher()
                }
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

    public func cancel() {
        cancellables = []
    }
}

extension WampSession {
    private func didConnect() {
    }

    private func gotPossibleMessage(_ possibleMessage: String) {
        switch serialization.deserialize(possibleMessage) {
        case let .success(message):
            messageBus.send(message)
            replyIfNeeded(message)
        case let .failure(error):
            cantParseMessage(error: error)
        }
    }

    private func replyIfNeeded(_ message: Message) {
        switch message {
        case let .goodbye(goodbye) where !goodbye.reason.isAck:
            replyGoodbye()
        default:
            break
        }
    }

    private func didDisconnect() {
    }

    private func didDisconnect(with error: Error) {
    }

    private func cantParseMessage(error: Error) {
    }
}

extension WampSession {
    private func replyGoodbye() {
        client
            .replyGoodbye()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        print("Error on replying GOODBYE with ACK. \(error)")
                    case .finished:
                        print("Bye!")
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
