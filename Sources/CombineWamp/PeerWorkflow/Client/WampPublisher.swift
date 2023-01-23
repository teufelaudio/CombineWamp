import Combine
import Foundation
import FoundationExtensions

public protocol WampPublisherProtocol {
    func publish(topic: URI, positionalArguments: [ElementType]?, namedArguments: [String : ElementType]?)
    -> Publishers.Promise<Message.Published, ModuleError>
}

/// WAMP Publisher is a WAMP Client role that allows this Peer to publish messages into a topic
public struct WampPublisher: WampPublisherProtocol {
    let session: WampSession

    public init(session: WampSession) {
        self.session = session
    }

    public func publish(topic: URI, positionalArguments: [ElementType]? = nil, namedArguments: [String : ElementType]? = nil)
    -> Publishers.Promise<Message.Published, ModuleError> {
        guard let id = session.idGenerator.next() else { return .init(error: .sessionIsNotValid) }
        let messageBus = session.messageBus

        return session.send(
            Message.publish(.init(request: id, options: .acknowledge, topic: topic, positionalArguments: positionalArguments, namedArguments: namedArguments))
        )
        .flatMap { () -> Publishers.Promise<Message.Published, ModuleError> in
            messageBus
                .setFailureType(to: ModuleError.self)
                .flatMap { message -> AnyPublisher<Message.Published, ModuleError> in
                    if case let .published(published) = message, published.request == id {
                        return Just<Message.Published>(published).setFailureType(to: ModuleError.self).eraseToAnyPublisher()
                    }

                    if case let .error(error) = message, error.requestType == Message.Published.type, error.request == id {
                        return Fail<Message.Published, ModuleError>(error: .commandError(error)).eraseToAnyPublisher()
                    }

                    return Empty().eraseToAnyPublisher()
                }
                .promise(onEmpty: { .failure(.sessionIsNotValid) })
        }
        .promise
    }

    public func publishWithoutAck(topic: URI, positionalArguments: [ElementType]? = nil, namedArguments: [String : ElementType]? = nil)
    -> Publishers.Promise<Void, ModuleError> {
        guard let id = session.idGenerator.next() else { return .init(error: .sessionIsNotValid) }
        return session.send(
            Message.publish(.init(request: id, options: [:], topic: topic, positionalArguments: positionalArguments, namedArguments: namedArguments))
        )
    }
}
