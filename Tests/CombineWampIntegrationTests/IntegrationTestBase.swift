import Combine
import CombineWamp
import Foundation
import XCTest

// Run these tests against the Crossbar.io getting-started sample, after modifying the crossbar-examples/getting-started/.crossbar/config.json file
// according to the tutorial found in here: https://crossbar.io/docs/Getting-Started/
// docker run -v  $PWD:/node -u 0 --rm --name=crossbar -it -p 8080:8080 crossbario/crossbar
class IntegrationTestBase: XCTestCase {
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

    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        super.tearDown()
        cancellables = []
    }
}
