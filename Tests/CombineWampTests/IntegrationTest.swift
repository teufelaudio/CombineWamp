import Combine
import CombineWamp
import Foundation
import XCTest

final class IntegrationTest: XCTestCase {
    let serialization: WampSerializing = {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        return WampSerializing.json(decoder: { decoder }, encoder: { encoder })
    }()

    func transport() -> WampTransport {
        let router = URL(string: "ws://localhost:8080/ws")!
        let urlSession = URLSession.init(configuration: .ephemeral)
        return WampTransport.webSocket(wsURL: router, urlSession: urlSession, serializationFormat: serialization.serializationFormat)
    }

    func client() -> WampClient {
        WampClient(
            publish: { topic in
                AnySubscriber<String, Error>()
            },
            subscribe: { topic in
                PassthroughSubject<String, Error>().eraseToAnyPublisher()
            },
            call: nil,
            respond: nil
        )
    }

    func testSayHelloReceiveWelcome() throws {
        let realm = URI("realm1")!
        let session = WampSession(transport: transport(), serialization: serialization, realm: realm, me: client())

        let welcomeReceived = expectation(description: "it should receive welcome")

        let cancellable = session.connect()
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
            )

        wait(for: [welcomeReceived], timeout: 1.5)
        cancellable.cancel()
    }

    func testSayHelloReceiveAbord() throws {
        let realm = URI("invalid_realm_dude")!
        let session = WampSession(transport: transport(), serialization: serialization, realm: realm, me: client())

        let abortReceived = expectation(description: "it should receive abort")

        let cancellable = session.connect()
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
            )

        wait(for: [abortReceived], timeout: 1.5)
        cancellable.cancel()
    }
}
