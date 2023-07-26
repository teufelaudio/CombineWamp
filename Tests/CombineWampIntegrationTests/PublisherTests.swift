import Combine
@testable import CombineWamp
import Foundation
import XCTest

// https://wamp-proto.org/_static/gen/wamp_latest.html#publishing-and-events
final class PublisherTests: IntegrationTestBase {
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

    func testPublishAndReceivePublished() throws {
        wait(for: [connected], timeout: 0.5)

        let publishedReceived = expectation(description: "Published should have been received")
        session
            .client
            .asPublisher!
            .publish(topic: URI("com.myapp.hello")!, positionalArguments: [.string("Hello World 42")], namedArguments: nil)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { published in
                    XCTAssertTrue(published.publication.value > 0)
                    publishedReceived.fulfill()
                }
            ).store(in: &cancellables)

        wait(for: [publishedReceived], timeout: 0.5)
        XCTAssertNotNil(connection)
    }

    func testPublishWithoutAck() throws {
        wait(for: [connected], timeout: 0.5)

        let publishedReceived = expectation(description: "Published should have been received")
        session
            .client
            .asPublisher!
            .publish(topic: URI("com.myapp.hello")!, positionalArguments: [.string("Hello World 42")], namedArguments: nil)
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
                    publishedReceived.fulfill()
                }
            ).store(in: &cancellables)

        wait(for: [publishedReceived], timeout: 0.5)
        XCTAssertNotNil(connection)
    }

    func testPublishAndReceiveError() throws {
        wait(for: [connected], timeout: 0.5)

        let errorReceived = expectation(description: "Error should have been received")
        session
            .client
            .asPublisher!
            .publish(topic: URI(unverified: ".myapp.hello..a"), positionalArguments: [.string("Hello World 42")], namedArguments: nil)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        guard case let .commandError(commandError) = error else { return }
                        XCTAssertEqual(commandError.error, WampError.invalidURI.uri)
                        errorReceived.fulfill()
                    case .finished:
                        break
                    }
                },
                receiveValue: { published in
                    XCTFail("Success was not expected")
                }
            ).store(in: &cancellables)

        wait(for: [errorReceived], timeout: 0.5)
        XCTAssertNotNil(connection)
    }
}
