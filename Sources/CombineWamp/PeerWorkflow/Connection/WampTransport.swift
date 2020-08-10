import Combine
import CombineWebSocket
import Foundation
import FoundationExtensions

public enum WampTransportEvent {
    case connected
    case incomingMessage(String)
}

public struct WampTransport: ConnectablePublisher {
    public typealias Output = WampTransportEvent
    public typealias Failure = Error

    private let _connect: () -> AnyPublisher<String, Error>
    private let _send: (String) -> Publishers.Promise<Void, Error>
    private let events = PassthroughSubject<WampTransportEvent, Error>()

    public init(
        connect: @escaping () -> AnyPublisher<String, Error>,
        send: @escaping (String) -> Publishers.Promise<Void, Error>) {
        self._connect = connect
        self._send = send
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        events.subscribe(subscriber)
    }

    public func connect() -> Cancellable {
        _connect()
            .handleEvents(receiveRequest: { _ in
                self.events.send(.connected)
            })
            .sink(
                receiveCompletion: { completion in
                    self.events.send(completion: completion)
                },
                receiveValue: { message in
                    self.events.send(.incomingMessage(message))
                }
            )
    }

    public func send(message: String) -> Publishers.Promise<Void, Error> {
        _send(message)
    }
}

// Implementations (Protocol witnesses)
extension WampTransport {
    public static func webSocket(wsURL: URL, urlSession: WebSocketSessionProtocol, serializationFormat: URI.SerializationFormat) -> WampTransport {
        let webSocket = urlSession.webSocket(with: wsURL, protocols: [serializationFormat.uri.description])

        return WampTransport(
            connect: {
                webSocket.publisher.map { message -> String in
                    switch message {
                    case let .string(text):
                        return text
                    case let .data(data):
                        return String(data: data, encoding: .utf8)!
                    @unknown default:
                        return ""
                    }
                }.eraseToAnyPublisher()
            },
            send: { message in
                Publishers.Promise { webSocket.send(message) }
            }
        )
    }
}
