// Copyright © 2023 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation

public class WampSubscriberMock: WampSubscriberProtocol {
    public var onReceiveSubscribe: (URI, @escaping (Result<Message.Unsubscribed, ModuleError>) -> Void) -> AnyPublisher<Message.Event, ModuleError> = { _, _ in fatalError() }

    public init() {
    }

    public func subscribe(topic: URI, onUnsubscribe: @escaping (Result<Message.Unsubscribed, ModuleError>) -> Void) -> AnyPublisher<Message.Event, ModuleError> {
        onReceiveSubscribe(topic, onUnsubscribe)
    }
}
