import Combine
@testable import CombineWamp
import Foundation
import XCTest

// https://wamp-proto.org/_static/gen/wamp_latest.html#subscribing-and-unsubscribing
// Apart from the Router, in order to run this test you also must run the publishing Docker
// https://crossbar.io/docs/Getting-Started/#publishing-client
// `docker run -v $PWD:/app -e CBURL="ws://crossbar:8080/ws" -e CBREALM="realm1" --link=crossbar --rm -it crossbario/autobahn-python:cpy3 python /app/1.hello-world/client_component_publish.py`
// All of this will eventually be automated.
final class SubscriberTests: IntegrationTestBase {
    var connected: XCTestExpectation!
    var session: WampSession!
    let realm = URI("realm1")!
    var connection: AnyCancellable?

    override func setUp() {
        super.setUp()

        connected = expectation(description: "Connected")
        session = WampSession(transport: transport(), serialization: serialization, realm: realm, roles: .allClientRoles)
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

    func testSubscribeAndReceiveEvents() throws {
        wait(for: [connected], timeout: 0.5)

        let receiveEventsExpectation = expectation(description: "3 events should have been received")
        receiveEventsExpectation.expectedFulfillmentCount = 3
        var receivedEvents = [Message.Event]()

        session
            .client
            .asSubscriber!
            .subscribe(topic: URI("com.myapp.hello")!, onUnsubscribe: { _ in })
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { event in
                    receivedEvents.append(event)
                    receiveEventsExpectation.fulfill()
                }
            ).store(in: &cancellables)

        wait(for: [receiveEventsExpectation], timeout: 5.0)
        XCTAssertEqual(receivedEvents.count, 3)
        for i in 0..<3 {
            XCTAssertNil(receivedEvents[safe: i]?.namedArguments)
            XCTAssertEqual(receivedEvents[safe: i]?.positionalArguments?.count, 1)
            XCTAssertTrue(receivedEvents[safe: i]?.positionalArguments?.first?.string?.hasPrefix("Hello World ") == true)
        }
        XCTAssertNotNil(connection)
    }

    func testSubscribeAndUnsubscribe() throws {
        wait(for: [connected], timeout: 0.5)

        let receiveEventsExpectation = expectation(description: "Events should have been received")
        let unsubscribingExpectation = expectation(description: "Unsubscribed ack should have been received")
        receiveEventsExpectation.assertForOverFulfill = false

        let subscription = session
            .client
            .asSubscriber!
            .subscribe(topic: URI("com.myapp.hello")!, onUnsubscribe: { [weak self] unsubscribing in
                guard let self = self else { return }
                unsubscribing
                    .run(
                        onSuccess: { unsubscribed in
                            unsubscribingExpectation.fulfill()
                        },
                        onFailure: { error in
                            XCTFail(error.localizedDescription)
                        }
                    )
                    .store(in: &self.cancellables)
            })
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { _ in
                    receiveEventsExpectation.fulfill()
                }
            )

        wait(for: [receiveEventsExpectation], timeout: 2.0)

        subscription?.cancel()
        wait(for: [unsubscribingExpectation], timeout: 1.0)
    }
}
