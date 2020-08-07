import Combine
import CombineWamp
import Foundation
import XCTest

// https://wamp-proto.org/_static/gen/wamp_latest.html#session-establishment
final class SessionEstablishmentTests: IntegrationTestBase {
    func testSayHelloReceiveWelcome() throws {
        let realm = URI("realm1")!
        let session = WampSession(transport: transport(), serialization: serialization, realm: realm, roles: .allClientRoles)

        let welcomeReceived = expectation(description: "it should receive welcome")

        session.connect()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        break
                    }
                },
                receiveValue: { welcome in
                    welcomeReceived.fulfill()
                }
            ).store(in: &cancellables)

        wait(for: [welcomeReceived], timeout: 0.5)
    }

    func testSayHelloReceiveAbort() throws {
        let realm = URI("invalid_realm_dude")!
        let session = WampSession(transport: transport(), serialization: serialization, realm: realm, roles: .allClientRoles)

        let abortReceived = expectation(description: "it should receive abort")

        session.connect()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        switch error {
                        case let .abort(abort):
                            XCTAssertEqual(abort.reason, WampError.noSuchRealm.uri)
                            abortReceived.fulfill()
                        default:
                            XCTFail("Unexpected error received: \(error)")
                        }
                    case .finished:
                        break
                    }
                },
                receiveValue: { welcome in
                    XCTFail("Welcome was not expected in this test")
                }
            ).store(in: &cancellables)

        wait(for: [abortReceived], timeout: 0.5)
    }
}
