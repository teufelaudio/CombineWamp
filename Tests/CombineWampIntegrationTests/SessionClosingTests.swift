import Combine
import CombineWamp
import Foundation
import XCTest

// https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing
final class SessionClosingTests: IntegrationTestBase {
    var connected: XCTestExpectation!
    var session: WampSession!
    let realm = URI("realm1")!
    var connection: AnyCancellable?

    override func setUp() {
        super.setUp()

        connected = expectation(description: "Connected")
        session = WampSession(transport: transport(), serialization: serialization, client: { session in
            WampClient(
                session: session,
                realm: self.realm,
                publisherRole: { WampPublisher(session: session) },
                subscriberRole: { WampSubscriber(session: session) },
                callerRole: { WampCaller(session: session) },
                calleeRole: { WampCallee(session: session) }
            )
        })
        connection = session.connect()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] welcome in
                    self?.connected.fulfill()
                }
            )
    }

    func testSayGoodbyeReceiveGoodbye() throws {
        wait(for: [connected], timeout: 0.5)

        let goodbyeReceived = expectation(description: "Goodbye should have been received")
        session
            .client
            .sayGoodbye()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { goodbye in
                    XCTAssertTrue(goodbye.reason.isAck)
                    goodbyeReceived.fulfill()
                }
            ).store(in: &cancellables)

        wait(for: [goodbyeReceived], timeout: 0.5)
        XCTAssertNotNil(connection)
    }
}
