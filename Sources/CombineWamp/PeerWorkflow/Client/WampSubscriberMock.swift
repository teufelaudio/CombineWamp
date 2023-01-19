// Copyright © 2023 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation

class WampSubscriberMock: WampSubscriberProtocol {
    var onReceiveSubscribe: (CombineWamp.URI, @escaping (Result<CombineWamp.Message.Unsubscribed, CombineWamp.ModuleError>) -> Void) -> AnyPublisher<CombineWamp.Message.Event, CombineWamp.ModuleError> = { _, _ in fatalError() }
    func subscribe(topic: CombineWamp.URI, onUnsubscribe: @escaping (Result<CombineWamp.Message.Unsubscribed, CombineWamp.ModuleError>) -> Void) -> AnyPublisher<CombineWamp.Message.Event, CombineWamp.ModuleError> {
        onReceiveSubscribe(topic, onUnsubscribe)
    }
}
