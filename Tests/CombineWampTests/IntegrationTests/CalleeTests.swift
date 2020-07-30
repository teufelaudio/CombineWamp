import Combine
@testable import CombineWamp
import Foundation
import XCTest

final class CalleeTests: IntegrationTestBase {
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

    func testRegisterAndReceiveInvocationsThenUnregister() throws {
        wait(for: [connected], timeout: 0.5)

        let registrationExpectation = expectation(description: "Registered should have been received")
        let invocationExpectation = expectation(description: "Invocation should have been received")
        let successfulYieldExpectation = expectation(description: "Yield should have been sent")
        let resultReceived = expectation(description: "Result should have been received")
        let unregistrationExpectation = expectation(description: "Unregister ack should have been received")
        var cancellables = Set<AnyCancellable>()

        let registration = session
            .client
            .asCallee?
            .register(procedure: URI("com.teufel.tests.sum_from_the_app")!, onUnregister: { unregistering in
                unregistering
                    .run(
                        onSuccess: { unsubscribed in
                            unregistrationExpectation.fulfill()
                        },
                        onFailure: { error in
                            XCTFail(error.localizedDescription)
                        }
                    )
                    .store(in: &cancellables)
            })
            .handleEvents(receiveSubscription: { _ in registrationExpectation.fulfill() })
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { (invocation, responder) in
                    let first = invocation.positionalArguments?[safe: 0]?.integer ?? 0
                    let second = invocation.positionalArguments?[safe: 1]?.integer ?? 0
                    XCTAssertEqual(first, 99)
                    XCTAssertEqual(second, 57)
                    invocationExpectation.fulfill()
                    responder([.integer(first - second)])
                        .run(onSuccess: { _ in successfulYieldExpectation.fulfill() },
                             onFailure: { error in XCTFail(error.localizedDescription) }
                        )
                        .store(in: &cancellables)
                }
            )

        wait(for: [registrationExpectation], timeout: 2.0)

        session
            .client
            .asCaller?
            .call(procedure: URI("com.teufel.tests.sum_from_the_app")!, positionalArguments: [.integer(99), .integer(57)])
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { result in
                    XCTAssertEqual(result.positionalArguments?.count, 1)
                    XCTAssertEqual(result.positionalArguments?[0], .integer(42))
                    XCTAssertNil(result.namedArguments)
                    resultReceived.fulfill()
                }
            ).store(in: &cancellables)

        wait(for: [invocationExpectation, successfulYieldExpectation, resultReceived], timeout: 2.0, enforceOrder: true)

        registration?.cancel()
        wait(for: [unregistrationExpectation], timeout: 1.0)
        XCTAssertNotNil(connection)
    }
}
