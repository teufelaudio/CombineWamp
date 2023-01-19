// Copyright © 2023 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation

#if DEBUG
extension WampSession {
    static public func mock(
        publisher: @escaping () -> WampPublisherProtocol = { fatalError() },
        subscriber: @escaping () -> WampSubscriberProtocol = { fatalError() },
        caller: @escaping () -> WampCallerProtocol = { fatalError() },
        callee: @escaping () -> WampCalleeProtocol = { fatalError() }
    ) -> WampSession {
        WampSession(
            transport: .init(connect: { Empty().eraseToAnyPublisher() }, send: { _ in .init(value: ())}),
            serialization: WampSerializing.json(decoder: JSONDecoder.init, encoder: JSONEncoder.init),
            client: { session in
                WampClient(
                    session: session,
                    roles: [.caller, .subscriber],
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
