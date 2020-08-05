import Combine
import CombineWamp
import Foundation
import XCTest

// https://wamp-proto.org/_static/gen/wamp_latest.html#call-0
// For testing this, please edit
// ./crossbar-examples/getting-started/3.rpc/rpc_callee.js
// and change it to:

/*
```
// Example WAMP client for AutobahnJS connecting to a Crossbar.io WAMP router.
// AutobahnJS, the WAMP client library to connect and talk to Crossbar.io:
var isBrowser = false;
try {
    var autobahn = require('autobahn');
} catch (e) {
    // when running in browser, AutobahnJS will
    // be included without a module system
    isBrowser = true;
}
console.log("Running AutobahnJS " + autobahn.version);

if (isBrowser) {
    url = 'ws://127.0.0.1:8080/ws';
    realm = 'realm1';
}
else {
    url = process.env.CBURL;
    realm = process.env.CBREALM;
}
var connection = new autobahn.Connection({ url: url, realm: realm });
console.log("Running AutobahnJS " + url+ "  "+realm);

// .. and fire this code when we got a session
connection.onopen = function (session, details) {
    console.log("session open!", details);
    // Your code goes here: use WAMP via the session you got to
    // call, register, subscribe and publish ..
    function utcnow() {
        console.log("Someone is calling com.myapp.date");
        now = new Date();
        return now.toISOString();
    }
    function sum(args) {
        console.log("Sum has been called with " + args[0] + " and " + args[1]);
        return args[0] + args[1];
    }
    function subtract(args, argsKw) {
        console.log("Subtract has been called with " + argsKw["first"] + " and " + argsKw["second"]);
        return argsKw["first"] - argsKw["second"];
    }
    session.register('com.myapp.date', utcnow).then(
        function (registration) {
            console.log("Procedure registered:", registration.id);
        },
        function (error) {
            console.log("Registration failed:", error);
        }
    );
    session.register('de.teufel.tests.sum', sum).then(
        function (registration) {
            console.log("Procedure registered:", registration.id);
        },
        function (error) {
            console.log("Registration failed:", error);
        }
    );
    session.register('de.teufel.tests.subtract', subtract).then(
        function (registration) {
            console.log("Procedure registered:", registration.id);
        },
        function (error) {
            console.log("Registration failed:", error);
        }
    );
};

// .. and fire this code when our session has gone
connection.onclose = function (reason, details) {
    console.log("session closed: " + reason, details);
}

// Don't forget to actually trigger the opening of the connection!
connection.open();
```
*/
// Then, from the same folder, open rpc_callee.html in your webbrowser and run the test
final class CallerTests: IntegrationTestBase {
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

    func testCallPositionalArgumentsAndReceiveResult() throws {
        wait(for: [connected], timeout: 0.5)

        let resultReceived = expectation(description: "Result should have been received")
        session
            .client
            .asCaller!
            .call(procedure: URI("de.teufel.tests.sum")!, positionalArguments: [.integer(13), .integer(17)])
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
                    XCTAssertEqual(result.positionalArguments?[0], .integer(30))
                    XCTAssertNil(result.namedArguments)
                    resultReceived.fulfill()
                }
            ).store(in: &cancellables)

        wait(for: [resultReceived], timeout: 0.5)
        XCTAssertNotNil(connection)
    }

    func testCallNamedArgumentsAndReceiveResult() throws {
        wait(for: [connected], timeout: 0.5)

        let resultReceived = expectation(description: "Result should have been received")
        session
            .client
            .asCaller!
            .call(procedure: URI("de.teufel.tests.subtract")!, namedArguments: ["first": .integer(53), "second": .integer(11)])
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

        wait(for: [resultReceived], timeout: 0.5)
        XCTAssertNotNil(connection)
    }
}
