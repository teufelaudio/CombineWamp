// Copyright © 2023 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation

#if DEBUG
extension WampSession {
    static public func mock(
        publisher: (() -> WampPublisherProtocol)? = nil,
        subscriber: (() -> WampSubscriberProtocol)? = nil,
        caller: (() -> WampCallerProtocol)? = nil,
        callee: (() -> WampCalleeProtocol)? = nil
    ) -> WampSession {
        WampSession(
            transport: .init(connect: { Empty().eraseToAnyPublisher() }, send: { _ in .init(value: ())}),
            serialization: WampSerializing.json(decoder: JSONDecoder.init, encoder: JSONEncoder.init),
            client: { session in
                WampClient(
                    session: session,
                    realm: URI("teufel") ?? { preconditionFailure("Invalid URI") }(),
                    publisherRole: publisher,
                    subscriberRole: subscriber,
                    callerRole: caller,
                    calleeRole: callee
                )
            }
        )
    }

}
#endif
