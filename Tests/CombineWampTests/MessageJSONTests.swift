@testable import CombineWamp
import Foundation
import XCTest

final class MessageJSONTests: XCTestCase {
}

// [HELLO, Realm|uri, Details|dict]
extension MessageJSONTests {
    func testHelloDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [1,"de.teufel.tests_realm",{"hello":"world","answer":42,"valid":true,"double_answer":42.42,"primes":[2,3,5,7,11]}]
                   """.data(using: .utf8)!
        let model = Message.hello(
            .init(
                realm: URI("de.teufel.tests_realm")!,
                details: [
                    "hello": .string("world"),
                    "answer": .integer(42),
                    "valid": .bool(true),
                    "double_answer": .double(42.42),
                    "primes": .list([.integer(2), .integer(3), .integer(5), .integer(7), .integer(11)])
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#client-role-and-feature-announcement
    func testHelloRolesDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [1, "somerealm", {
                     "roles": {
                       "publisher": {},
                       "subscriber": {}
                     }
                   }]
                   """.data(using: .utf8)!
        let model = Message.hello(
            .init(
                realm: URI("somerealm")!,
                details: [
                    "roles": .dict([
                        "publisher": .dict([:]),
                        "subscriber": .dict([:])
                    ])
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    func testHelloEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [1,"de.teufel.tests_realm",{"answer":42,"double_answer":42,"hello":"world","primes":[2,3,5,7,11],"valid":true}]
                   """
        let model = Message.hello(
            .init(
                realm: URI("de.teufel.tests_realm")!,
                details: [
                    "hello": .string("world"),
                    "answer": .integer(42),
                    "valid": .bool(true),
                    "double_answer": .double(42),
                    "primes": .list([.integer(2), .integer(3), .integer(5), .integer(7), .integer(11)])
                ]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#agent-identification
    func testHelloAgentDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [1, "somerealm", {
                     "agent": "AutobahnJS-0.9.14",
                     "roles": {
                       "subscriber": {},
                       "publisher": {}
                     }
                   }]
                   """.data(using: .utf8)!
        let model = Message.hello(
            .init(
                realm: URI("somerealm")!,
                details: [
                    "agent": .string("AutobahnJS-0.9.14"),
                    "roles": .dict([
                        "subscriber": .dict([:]),
                        "publisher": .dict([:])
                    ])
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#agent-identification
    func testHelloAgentEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [1,"somerealm",{"agent":"AutobahnJS-0.9.14","roles":{"publisher":{},"subscriber":{}}}]
                   """
        let model = Message.hello(
            .init(
                realm: URI("somerealm")!,
                details: [
                    "agent": .string("AutobahnJS-0.9.14"),
                    "roles": .dict([
                        "subscriber": .dict([:]),
                        "publisher": .dict([:])
                    ])
                ]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [WELCOME, Session|id, Details|dict]
extension MessageJSONTests {
    func testWelcomeDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [2,314,{"hello":"world","answer":42,"valid":true,"double_answer":42.42,"primes":[2,3,5,7,11]}]
                   """.data(using: .utf8)!
        let model = Message.welcome(
            .init(
                session: WampID(integerLiteral: 314),
                details: [
                    "hello": .string("world"),
                    "answer": .integer(42),
                    "valid": .bool(true),
                    "double_answer": .double(42.42),
                    "primes": .list([.integer(2), .integer(3), .integer(5), .integer(7), .integer(11)])
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#router-role-and-feature-announcement
    func testWelcomeRoles() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [2, 9129137332, {
                     "roles": {
                       "broker": {}
                     }
                   }]
                   """.data(using: .utf8)!
        let model = Message.welcome(
            .init(
                session: .init(integerLiteral: 9129137332),
                details: [
                    "roles": .dict([
                        "broker": .dict([:])
                    ])
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    func testWelcomeEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [2,314,{"answer":42,"double_answer":42,"hello":"world","primes":[2,3,5,7,11],"valid":true}]
                   """
        let model = Message.welcome(
            .init(
                session: WampID(integerLiteral: 314),
                details: [
                    "hello": .string("world"),
                    "answer": .integer(42),
                    "valid": .bool(true),
                    "double_answer": .double(42),
                    "primes": .list([.integer(2), .integer(3), .integer(5), .integer(7), .integer(11)])
                ]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#agent-identification
    func testWelcomeAgentDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [2, 9129137332, {
                     "agent": "Crossbar.io-0.10.11",
                     "roles": {
                       "broker": {}
                     }
                   }]
                   """.data(using: .utf8)!
        let model = Message.welcome(
            .init(
                session: .init(integerLiteral: 9129137332),
                details: [
                    "agent": .string("Crossbar.io-0.10.11"),
                    "roles": .dict([
                        "broker": .dict([:])
                    ])
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#agent-identification
    func testWelcomeAgentEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [2,9129137332,{"agent":"Crossbar.io-0.10.11","roles":{"broker":{}}}]
                   """
        let model = Message.welcome(
            .init(
                session: .init(integerLiteral: 9129137332),
                details: [
                    "agent": .string("Crossbar.io-0.10.11"),
                    "roles": .dict([
                        "broker": .dict([:])
                    ])
                ]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [ABORT, Details|dict, Reason|uri]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#abort-0
    func testAbortExample1Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [3, {"message": "The realm does not exist."},"wamp.error.no_such_realm"]
                   """.data(using: .utf8)!
        let model = Message.abort(
            .init(
                details: [
                    "message": .string("The realm does not exist.")
                ],
                reason: WampError.noSuchRealm.uri
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#abort-0
    func testAbortExample1Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [3,{"message":"The realm does not exist."},"wamp.error.no_such_realm"]
                   """
        let model = Message.abort(
            .init(
                details: [
                    "message": .string("The realm does not exist.")
                ],
                reason: WampError.noSuchRealm.uri
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#abort-0
    func testAbortExample2Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [3, {"message": "Received HELLO message after session was established."}, "wamp.error.protocol_violation"]
                   """.data(using: .utf8)!
        let model = Message.abort(
            .init(
                details: [
                    "message": .string("Received HELLO message after session was established.")
                ],
                reason: WampError.protocolViolation.uri
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#abort-0
    func testAbortExample2Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [3,{"message":"Received HELLO message after session was established."},"wamp.error.protocol_violation"]
                   """
        let model = Message.abort(
            .init(
                details: [
                    "message": .string("Received HELLO message after session was established.")
                ],
                reason: WampError.protocolViolation.uri
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#abort-0
    func testAbortExample3Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [3, {"message": "Received WELCOME message after session was established."}, "wamp.error.protocol_violation"]
                   """.data(using: .utf8)!
        let model = Message.abort(
            .init(
                details: [
                    "message": .string("Received WELCOME message after session was established.")
                ],
                reason: WampError.protocolViolation.uri
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#abort-0
    func testAbortExample3Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [3,{"message":"Received WELCOME message after session was established."},"wamp.error.protocol_violation"]
                   """
        let model = Message.abort(
            .init(
                details: [
                    "message": .string("Received WELCOME message after session was established.")
                ],
                reason: WampError.protocolViolation.uri
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [GOODBYE, Details|dict, Reason|uri]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing
    func testGoodbyeExample1Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [6, {"message": "The host is shutting down now."}, "wamp.close.system_shutdown"]
                   """.data(using: .utf8)!
        let model = Message.goodbye(
            .init(
                details: [
                    "message": .string("The host is shutting down now.")
                ],
                reason: WampClose.systemShutdown.uri
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing
    func testGoodbyeExample1Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [6,{"message":"The host is shutting down now."},"wamp.close.system_shutdown"]
                   """
        let model = Message.goodbye(
            .init(
                details: [
                    "message": .string("The host is shutting down now.")
                ],
                reason: WampClose.systemShutdown.uri
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing
    func testGoodbyeExample2Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [6, {}, "wamp.close.goodbye_and_out"]
                   """.data(using: .utf8)!
        let model = Message.goodbye(
            .init(
                details: [:],
                reason: WampClose.goodbyeAndOut.uri
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing
    func testGoodbyeExample2Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [6,{},"wamp.close.goodbye_and_out"]
                   """
        let model = Message.goodbye(
            .init(
                details: [:],
                reason: WampClose.goodbyeAndOut.uri
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing
    func testGoodbyeExample3Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [6, {}, "wamp.close.close_realm"]
                   """.data(using: .utf8)!
        let model = Message.goodbye(
            .init(
                details: [:],
                reason: WampClose.closeRealm.uri
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing
    func testGoodbyeExample3Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [6,{},"wamp.close.close_realm"]
                   """
        let model = Message.goodbye(
            .init(
                details: [:],
                reason: WampClose.closeRealm.uri
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing
    func testGoodbyeExample4Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [6, {}, "wamp.close.goodbye_and_out"]
                   """.data(using: .utf8)!
        let model = Message.goodbye(
            .init(
                details: [:],
                reason: WampClose.goodbyeAndOut.uri
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#session-closing
    func testGoodbyeExample4Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [6,{},"wamp.close.goodbye_and_out"]
                   """
        let model = Message.goodbye(
            .init(
                details: [:],
                reason: WampClose.goodbyeAndOut.uri
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [SUBSCRIBE, Request|id, Options|dict, Topic|uri]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#subscribe-0
    func testSubscribeDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [32, 713845233, {}, "com.myapp.mytopic1"]
                   """.data(using: .utf8)!
        let model = Message.subscribe(
            .init(
                request: .init(integerLiteral: 713845233),
                options: [:],
                topic: URI("com.myapp.mytopic1")!
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#subscribe-0
    func testSubscribeEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [32,713845233,{},"com.myapp.mytopic1"]
                   """
        let model = Message.subscribe(
            .init(
                request: .init(integerLiteral: 713845233),
                options: [:],
                topic: URI("com.myapp.mytopic1")!
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [SUBSCRIBED, SUBSCRIBE.Request|id, Subscription|id]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#subscribed-0
    func testSubscribedDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [33, 713845233, 5512315355]
                   """.data(using: .utf8)!
        let model = Message.subscribed(
            .init(
                request: .init(integerLiteral: 713845233),
                subscription: .init(integerLiteral: 5512315355)
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#subscribed-0
    func testSubscribedEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [33,713845233,5512315355]
                   """
        let model = Message.subscribed(
            .init(
                request: .init(integerLiteral: 713845233),
                subscription: .init(integerLiteral: 5512315355)
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [ERROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri]
// [ERROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri, Arguments|list]
// [ERROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri, Arguments|list, ArgumentsKw|dict]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#subscribe-error
    func testErrorOnSubscribeDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [8, 32, 713845233, {}, "wamp.error.not_authorized"]
                   """.data(using: .utf8)!
        let model = Message.error(
            .init(
                requestType: Message.Subscribe.type,
                request: .init(integerLiteral: 713845233),
                details: [:],
                error: WampError.notAuthorized.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#subscribe-error
    func testErrorOnSubscribeEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [8,32,713845233,{},"wamp.error.not_authorized"]
                   """
        let model = Message.error(
            .init(
                requestType: Message.Subscribe.type,
                request: .init(integerLiteral: 713845233),
                details: [:],
                error: WampError.notAuthorized.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#unsubscribe-error
    func testErrorOnUnsubscribeDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [8, 34, 85346237, {}, "wamp.error.no_such_subscription"]
                   """.data(using: .utf8)!
        let model = Message.error(
            .init(
                requestType: Message.Unsubscribe.type,
                request: .init(integerLiteral: 85346237),
                details: [:],
                error: WampError.noSuchSubscription.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#unsubscribe-error
    func testErrorOnUnsubscribeEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [8,34,85346237,{},"wamp.error.no_such_subscription"]
                   """
        let model = Message.error(
            .init(
                requestType: Message.Unsubscribe.type,
                request: .init(integerLiteral: 85346237),
                details: [:],
                error: WampError.noSuchSubscription.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#publish-error
    func testErrorOnPublishDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [8, 16, 239714735, {}, "wamp.error.not_authorized"]
                   """.data(using: .utf8)!
        let model = Message.error(
            .init(
                requestType: Message.Publish.type,
                request: .init(integerLiteral: 239714735),
                details: [:],
                error: WampError.notAuthorized.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#publish-error
    func testErrorOnPublishEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [8,16,239714735,{},"wamp.error.not_authorized"]
                   """
        let model = Message.error(
            .init(
                requestType: Message.Publish.type,
                request: .init(integerLiteral: 239714735),
                details: [:],
                error: WampError.notAuthorized.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#register-error
    func testErrorOnRegisterDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [8, 64, 25349185, {}, "wamp.error.procedure_already_exists"]
                   """.data(using: .utf8)!
        let model = Message.error(
            .init(
                requestType: Message.Register.type,
                request: .init(integerLiteral: 25349185),
                details: [:],
                error: WampError.procedureAlreadyExists.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#register-error
    func testErrorOnRegisterEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [8,64,25349185,{},"wamp.error.procedure_already_exists"]
                   """
        let model = Message.error(
            .init(
                requestType: Message.Register.type,
                request: .init(integerLiteral: 25349185),
                details: [:],
                error: WampError.procedureAlreadyExists.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#unregister-error
    func testErrorOnUnregisterDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [8, 66, 788923562, {}, "wamp.error.no_such_registration"]
                   """.data(using: .utf8)!
        let model = Message.error(
            .init(
                requestType: Message.Unregister.type,
                request: .init(integerLiteral: 788923562),
                details: [:],
                error: WampError.noSuchRegistration.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#unregister-error
    func testErrorOnUnregisterEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [8,66,788923562,{},"wamp.error.no_such_registration"]
                   """
        let model = Message.error(
            .init(
                requestType: Message.Unregister.type,
                request: .init(integerLiteral: 788923562),
                details: [:],
                error: WampError.noSuchRegistration.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#invocation-error
    func testErrorOnInvocationDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [8, 68, 6131533, {}, "com.myapp.error.object_write_protected", ["Object is write protected."], {"severity": 3}]
                   """.data(using: .utf8)!
        let model = Message.error(
            .init(
                requestType: Message.Invocation.type,
                request: .init(integerLiteral: 6131533),
                details: [:],
                error: WampError.applicationError(uri: URI("com.myapp.error.object_write_protected")!).uri,
                arguments: [.string("Object is write protected.")],
                argumentsKw: ["severity": .integer(3)]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#invocation-error
    func testErrorOnInvocationEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [8,68,6131533,{},"com.myapp.error.object_write_protected",["Object is write protected."],{"severity":3}]
                   """
        let model = Message.error(
            .init(
                requestType: Message.Invocation.type,
                request: .init(integerLiteral: 6131533),
                details: [:],
                error: WampError.applicationError(uri: URI("com.myapp.error.object_write_protected")!).uri,
                arguments: [.string("Object is write protected.")],
                argumentsKw: ["severity": .integer(3)]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-error
    func testErrorOnCallExample1Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [8, 48, 7814135, {}, "com.myapp.error.object_write_protected", ["Object is write protected."], {"severity": 3}]
                   """.data(using: .utf8)!
        let model = Message.error(
            .init(
                requestType: Message.Call.type,
                request: .init(integerLiteral: 7814135),
                details: [:],
                error: WampError.applicationError(uri: URI("com.myapp.error.object_write_protected")!).uri,
                arguments: [.string("Object is write protected.")],
                argumentsKw: ["severity": .integer(3)]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-error
    func testErrorOnCallExample1Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [8,48,7814135,{},"com.myapp.error.object_write_protected",["Object is write protected."],{"severity":3}]
                   """
        let model = Message.error(
            .init(
                requestType: Message.Call.type,
                request: .init(integerLiteral: 7814135),
                details: [:],
                error: WampError.applicationError(uri: URI("com.myapp.error.object_write_protected")!).uri,
                arguments: [.string("Object is write protected.")],
                argumentsKw: ["severity": .integer(3)]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-error
    func testErrorOnCallExample2Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [8, 48, 7814135, {}, "wamp.error.no_such_procedure"]
                   """.data(using: .utf8)!
        let model = Message.error(
            .init(
                requestType: Message.Call.type,
                request: .init(integerLiteral: 7814135),
                details: [:],
                error: WampError.noSuchProcedure.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-error
    func testErrorOnCallExample2Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [8,48,7814135,{},"wamp.error.no_such_procedure"]
                   """
        let model = Message.error(
            .init(
                requestType: Message.Call.type,
                request: .init(integerLiteral: 7814135),
                details: [:],
                error: WampError.noSuchProcedure.uri,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

}

// [UNSUBSCRIBE, Request|id, SUBSCRIBED.Subscription|id]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#unsubscribe-0
    func testUnsubscribeDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [34, 85346237, 5512315355]
                   """.data(using: .utf8)!
        let model = Message.unsubscribe(
            .init(
                request: .init(integerLiteral: 85346237),
                subscription: .init(integerLiteral: 5512315355)
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#unsubscribe-0
    func testUnsubscribeEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [34,85346237,5512315355]
                   """
        let model = Message.unsubscribe(
            .init(
                request: .init(integerLiteral: 85346237),
                subscription: .init(integerLiteral: 5512315355)
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [UNSUBSCRIBED, UNSUBSCRIBE.Request|id]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#unsubscribed-0
    func testUnsubscribedDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [35, 85346237]
                   """.data(using: .utf8)!
        let model = Message.unsubscribed(
            .init(
                request: .init(integerLiteral: 85346237)
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#unsubscribed-0
    func testUnsubscribedEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [35,85346237]
                   """
        let model = Message.unsubscribed(
            .init(
                request: .init(integerLiteral: 85346237)
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [PUBLISH, Request|id, Options|dict, Topic|uri]
// [PUBLISH, Request|id, Options|dict, Topic|uri, Arguments|list]
// [PUBLISH, Request|id, Options|dict, Topic|uri, Arguments|list, ArgumentsKw|dict]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#publish-0
    func testPublishExample1Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [16, 239714735, {}, "com.myapp.mytopic1"]
                   """.data(using: .utf8)!
        let model = Message.publish(
            .init(
                request: .init(integerLiteral: 239714735),
                options: [:],
                topic: URI("com.myapp.mytopic1")!,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#publish-0
    func testPublishExample1Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [16,239714735,{},"com.myapp.mytopic1"]
                   """
        let model = Message.publish(
            .init(
                request: .init(integerLiteral: 239714735),
                options: [:],
                topic: URI("com.myapp.mytopic1")!,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#publish-0
    func testPublishExample2Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [16, 239714735, {}, "com.myapp.mytopic1", ["Hello, world!"]]
                   """.data(using: .utf8)!
        let model = Message.publish(
            .init(
                request: .init(integerLiteral: 239714735),
                options: [:],
                topic: URI("com.myapp.mytopic1")!,
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#publish-0
    func testPublishExample2Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [16,239714735,{},"com.myapp.mytopic1",["Hello, world!"]]
                   """
        let model = Message.publish(
            .init(
                request: .init(integerLiteral: 239714735),
                options: [:],
                topic: URI("com.myapp.mytopic1")!,
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#publish-0
    func testPublishExample3Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [16, 239714735, {}, "com.myapp.mytopic1", [], {"color": "orange", "sizes": [23, 42, 7]}]
                   """.data(using: .utf8)!
        let model = Message.publish(
            .init(
                request: .init(integerLiteral: 239714735),
                options: [:],
                topic: URI("com.myapp.mytopic1")!,
                arguments: [],
                argumentsKw: [
                    "color": .string("orange"),
                    "sizes": .list([.integer(23),.integer(42),.integer(7)])
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#publish-0
    func testPublishExample3Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [16,239714735,{},"com.myapp.mytopic1",[],{"color":"orange","sizes":[23,42,7]}]
                   """
        let model = Message.publish(
            .init(
                request: .init(integerLiteral: 239714735),
                options: [:],
                topic: URI("com.myapp.mytopic1")!,
                arguments: [],
                argumentsKw: [
                    "color": .string("orange"),
                    "sizes": .list([.integer(23),.integer(42),.integer(7)])
                ]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [PUBLISHED, PUBLISH.Request|id, Publication|id]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#published-0
    func testPublishedDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [17, 239714735, 4429313566]
                   """.data(using: .utf8)!
        let model = Message.published(
            .init(
                request: .init(integerLiteral: 239714735),
                publication: .init(integerLiteral: 4429313566)
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#published-0
    func testPublishedEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [17,239714735,4429313566]
                   """
        let model = Message.published(
            .init(
                request: .init(integerLiteral: 239714735),
                publication: .init(integerLiteral: 4429313566)
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict]
// [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict, PUBLISH.Arguments|list]
// [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict, PUBLISH.Arguments|list, PUBLISH.ArgumentsKw|dict]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#event-0
    func testEventExample1Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [36, 5512315355, 4429313566, {}]
                   """.data(using: .utf8)!
        let model = Message.event(
            .init(
                subscription: .init(integerLiteral: 5512315355),
                publication: .init(integerLiteral: 4429313566),
                details: [:],
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#event-0
    func testEventExample1Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [36,5512315355,4429313566,{}]
                   """
        let model = Message.event(
            .init(
                subscription: .init(integerLiteral: 5512315355),
                publication: .init(integerLiteral: 4429313566),
                details: [:],
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#event-0
    func testEventExample2Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [36, 5512315355, 4429313566, {}, ["Hello, world!"]]
                   """.data(using: .utf8)!
        let model = Message.event(
            .init(
                subscription: .init(integerLiteral: 5512315355),
                publication: .init(integerLiteral: 4429313566),
                details: [:],
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#event-0
    func testEventExample2Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [36,5512315355,4429313566,{},["Hello, world!"]]
                   """
        let model = Message.event(
            .init(
                subscription: .init(integerLiteral: 5512315355),
                publication: .init(integerLiteral: 4429313566),
                details: [:],
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#event-0
    func testEventExample3Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [36, 5512315355, 4429313566, {}, [], {"color": "orange", "sizes": [23, 42, 7]}]
                   """.data(using: .utf8)!
        let model = Message.event(
            .init(
                subscription: .init(integerLiteral: 5512315355),
                publication: .init(integerLiteral: 4429313566),
                details: [:],
                arguments: [],
                argumentsKw: [
                    "color": .string("orange"),
                    "sizes": .list([.integer(23),.integer(42),.integer(7)])
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#event-0
    func testEventExample3Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [36,5512315355,4429313566,{},[],{"color":"orange","sizes":[23,42,7]}]
                   """
        let model = Message.event(
            .init(
                subscription: .init(integerLiteral: 5512315355),
                publication: .init(integerLiteral: 4429313566),
                details: [:],
                arguments: [],
                argumentsKw: [
                    "color": .string("orange"),
                    "sizes": .list([.integer(23),.integer(42),.integer(7)])
                ]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [REGISTER, Request|id, Options|dict, Procedure|uri]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#register-0
    func testRegisterDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [64, 25349185, {}, "com.myapp.myprocedure1"]
                   """.data(using: .utf8)!
        let model = Message.register(
            .init(
                request: .init(integerLiteral: 25349185),
                options: [:],
                procedure: URI("com.myapp.myprocedure1")!
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#register-0
    func testRegisterEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [64,25349185,{},"com.myapp.myprocedure1"]
                   """
        let model = Message.register(
            .init(
                request: .init(integerLiteral: 25349185),
                options: [:],
                procedure: URI("com.myapp.myprocedure1")!
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [REGISTERED, REGISTER.Request|id, Registration|id]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#registered-0
    func testRegisteredDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [65, 25349185, 2103333224]
                   """.data(using: .utf8)!
        let model = Message.registered(
            .init(
                request: .init(integerLiteral: 25349185),
                registration: .init(integerLiteral: 2103333224)
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#registered-0
    func testRegisteredEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [65,25349185,2103333224]
                   """
        let model = Message.registered(
            .init(
                request: .init(integerLiteral: 25349185),
                registration: .init(integerLiteral: 2103333224)
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [UNREGISTER, Request|id, REGISTERED.Registration|id]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#unregister-0
    func testUnregisterDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [66, 788923562, 2103333224]
                   """.data(using: .utf8)!
        let model = Message.unregister(
            .init(
                request: .init(integerLiteral: 788923562),
                registration: .init(integerLiteral: 2103333224)
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#unregister-0
    func testUnregisterEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [66,788923562,2103333224]
                   """
        let model = Message.unregister(
            .init(
                request: .init(integerLiteral: 788923562),
                registration: .init(integerLiteral: 2103333224)
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [UNREGISTERED, UNREGISTER.Request|id]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#unregistered-0
    func testUnregisteredDecoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [67, 788923562]
                   """.data(using: .utf8)!
        let model = Message.unregistered(
            .init(
                request: .init(integerLiteral: 788923562)
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#unregistered-0
    func testUnregisteredEncoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [67,788923562]
                   """
        let model = Message.unregistered(
            .init(
                request: .init(integerLiteral: 788923562)
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [CALL, Request|id, Options|dict, Procedure|uri]
// [CALL, Request|id, Options|dict, Procedure|uri, Arguments|list]
// [CALL, Request|id, Options|dict, Procedure|uri, Arguments|list, ArgumentsKw|dict]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-0
    func testCallExample1Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [48, 7814135, {}, "com.myapp.ping"]
                   """.data(using: .utf8)!
        let model = Message.call(
            .init(
                request: .init(integerLiteral: 7814135),
                options: [:],
                procedure: URI("com.myapp.ping")!,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-0
    func testCallExample1Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [48,7814135,{},"com.myapp.ping"]
                   """
        let model = Message.call(
            .init(
                request: .init(integerLiteral: 7814135),
                options: [:],
                procedure: URI("com.myapp.ping")!,
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-0
    func testCallExample2Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [48, 7814135, {}, "com.myapp.echo", ["Hello, world!"]]
                   """.data(using: .utf8)!
        let model = Message.call(
            .init(
                request: .init(integerLiteral: 7814135),
                options: [:],
                procedure: URI("com.myapp.echo")!,
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-0
    func testCallExample2Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [48,7814135,{},"com.myapp.echo",["Hello, world!"]]
                   """
        let model = Message.call(
            .init(
                request: .init(integerLiteral: 7814135),
                options: [:],
                procedure: URI("com.myapp.echo")!,
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-0
    func testCallExample3Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [48, 7814135, {}, "com.myapp.add2", [23, 7]]
                   """.data(using: .utf8)!
        let model = Message.call(
            .init(
                request: .init(integerLiteral: 7814135),
                options: [:],
                procedure: URI("com.myapp.add2")!,
                arguments: [.integer(23), .integer(7)],
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-0
    func testCallExample3Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [48,7814135,{},"com.myapp.add2",[23,7]]
                   """
        let model = Message.call(
            .init(
                request: .init(integerLiteral: 7814135),
                options: [:],
                procedure: URI("com.myapp.add2")!,
                arguments: [.integer(23), .integer(7)],
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-0
    func testCallExample4Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [48, 7814135, {}, "com.myapp.user.new", ["johnny"],{"firstname": "John", "surname": "Doe"}]
                   """.data(using: .utf8)!
        let model = Message.call(
            .init(
                request: .init(integerLiteral: 7814135),
                options: [:],
                procedure: URI("com.myapp.user.new")!,
                arguments: [.string("johnny")],
                argumentsKw: [
                    "firstname": .string("John"),
                    "surname": .string("Doe")
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#call-0
    func testCallExample4Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [48,7814135,{},"com.myapp.user.new",["johnny"],{"firstname":"John","surname":"Doe"}]
                   """
        let model = Message.call(
            .init(
                request: .init(integerLiteral: 7814135),
                options: [:],
                procedure: URI("com.myapp.user.new")!,
                arguments: [.string("johnny")],
                argumentsKw: [
                    "firstname": .string("John"),
                    "surname": .string("Doe")
                ]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [INVOCATION, Request|id, REGISTERED.Registration|id, Details|dict]
// [INVOCATION, Request|id, REGISTERED.Registration|id, Details|dict, C* Arguments|list]
// [INVOCATION, Request|id, REGISTERED.Registration|id, Details|dict, CALL.Arguments|list, CALL.ArgumentsKw|dict]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#invocation-0
    func testInvocationExample1Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [68, 6131533, 9823526, {}]
                   """.data(using: .utf8)!
        let model = Message.invocation(
            .init(
                request: .init(integerLiteral: 6131533),
                registration: .init(integerLiteral: 9823526),
                details: [:],
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#invocation-0
    func testInvocationExample1Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [68,6131533,9823526,{}]
                   """
        let model = Message.invocation(
            .init(
                request: .init(integerLiteral: 6131533),
                registration: .init(integerLiteral: 9823526),
                details: [:],
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#invocation-0
    func testInvocationExample2Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [68, 6131533, 9823527, {}, ["Hello, world!"]]
                   """.data(using: .utf8)!
        let model = Message.invocation(
            .init(
                request: .init(integerLiteral: 6131533),
                registration: .init(integerLiteral: 9823527),
                details: [:],
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#invocation-0
    func testInvocationExample2Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [68,6131533,9823527,{},["Hello, world!"]]
                   """
        let model = Message.invocation(
            .init(
                request: .init(integerLiteral: 6131533),
                registration: .init(integerLiteral: 9823527),
                details: [:],
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#invocation-0
    func testInvocationExample3Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [68, 6131533, 9823528, {}, [23, 7]]
                   """.data(using: .utf8)!
        let model = Message.invocation(
            .init(
                request: .init(integerLiteral: 6131533),
                registration: .init(integerLiteral: 9823528),
                details: [:],
                arguments: [.integer(23), .integer(7)],
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#invocation-0
    func testInvocationExample3Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [68,6131533,9823528,{},[23,7]]
                   """
        let model = Message.invocation(
            .init(
                request: .init(integerLiteral: 6131533),
                registration: .init(integerLiteral: 9823528),
                details: [:],
                arguments: [.integer(23), .integer(7)],
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#invocation-0
    func testInvocationExample4Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [68, 6131533, 9823529, {}, ["johnny"], {"firstname": "John", "surname": "Doe"}]
                   """.data(using: .utf8)!
        let model = Message.invocation(
            .init(
                request: .init(integerLiteral: 6131533),
                registration: .init(integerLiteral: 9823529),
                details: [:],
                arguments: [.string("johnny")],
                argumentsKw: [
                    "firstname": .string("John"),
                    "surname": .string("Doe")
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#invocation-0
    func testInvocationExample4Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [68,6131533,9823529,{},["johnny"],{"firstname":"John","surname":"Doe"}]
                   """
        let model = Message.invocation(
            .init(
                request: .init(integerLiteral: 6131533),
                registration: .init(integerLiteral: 9823529),
                details: [:],
                arguments: [.string("johnny")],
                argumentsKw: [
                    "firstname": .string("John"),
                    "surname": .string("Doe")
                ]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [YIELD, INVOCATION.Request|id, Options|dict]
// [YIELD, INVOCATION.Request|id, Options|dict, Arguments|list]
// [YIELD, INVOCATION.Request|id, Options|dict, Arguments|list, ArgumentsKw|dict]
extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#yield-0
    func testYieldExample1Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [70, 6131533, {}]
                   """.data(using: .utf8)!
        let model = Message.yield(
            .init(
                request: .init(integerLiteral: 6131533),
                options: [:],
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#yield-0
    func testYieldExample1Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [70,6131533,{}]
                   """
        let model = Message.yield(
            .init(
                request: .init(integerLiteral: 6131533),
                options: [:],
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#yield-0
    func testYieldExample2Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [70, 6131533, {}, ["Hello, world!"]]
                   """.data(using: .utf8)!
        let model = Message.yield(
            .init(
                request: .init(integerLiteral: 6131533),
                options: [:],
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#yield-0
    func testYieldExample2Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [70,6131533,{},["Hello, world!"]]
                   """
        let model = Message.yield(
            .init(
                request: .init(integerLiteral: 6131533),
                options: [:],
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#yield-0
    func testYieldExample3Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [70, 6131533, {}, [30]]
                   """.data(using: .utf8)!
        let model = Message.yield(
            .init(
                request: .init(integerLiteral: 6131533),
                options: [:],
                arguments: [.integer(30)],
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#yield-0
    func testYieldExample3Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [70,6131533,{},[30]]
                   """
        let model = Message.yield(
            .init(
                request: .init(integerLiteral: 6131533),
                options: [:],
                arguments: [.integer(30)],
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#yield-0
    func testYieldExample4Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [70, 6131533, {}, [], {"userid": 123, "karma": 10}]
                   """.data(using: .utf8)!
        let model = Message.yield(
            .init(
                request: .init(integerLiteral: 6131533),
                options: [:],
                arguments: [],
                argumentsKw: [
                    "userid": .integer(123),
                    "karma": .integer(10)
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#yield-0
    func testYieldExample4Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [70,6131533,{},[],{"karma":10,"userid":123}]
                   """
        let model = Message.yield(
            .init(
                request: .init(integerLiteral: 6131533),
                options: [:],
                arguments: [],
                argumentsKw: [
                    "userid": .integer(123),
                    "karma": .integer(10)
                ]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}

// [RESULT, CALL.Request|id, Details|dict]
// [RESULT, CALL.Request|id, Details|dict, YIELD.Arguments|list]
// [RESULT, CALL.Request|id, Details|dict, YIELD.Arguments|list, YIELD.ArgumentsKw|dict]

extension MessageJSONTests {
    // https://wamp-proto.org/_static/gen/wamp_latest.html#result-0
    func testResultExample1Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [50, 7814135, {}]
                   """.data(using: .utf8)!
        let model = Message.result(
            .init(
                request: .init(integerLiteral: 7814135),
                details: [:],
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#result-0
    func testResultExample1Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [50,7814135,{}]
                   """
        let model = Message.result(
            .init(
                request: .init(integerLiteral: 7814135),
                details: [:],
                arguments: nil,
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#result-0
    func testResultExample2Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [50, 7814135, {}, ["Hello, world!"]]
                   """.data(using: .utf8)!
        let model = Message.result(
            .init(
                request: .init(integerLiteral: 7814135),
                details: [:],
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#result-0
    func testResultExample2Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [50,7814135,{},["Hello, world!"]]
                   """
        let model = Message.result(
            .init(
                request: .init(integerLiteral: 7814135),
                details: [:],
                arguments: [.string("Hello, world!")],
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#result-0
    func testResultExample3Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [50, 7814135, {}, [30]]
                   """.data(using: .utf8)!
        let model = Message.result(
            .init(
                request: .init(integerLiteral: 7814135),
                details: [:],
                arguments: [.integer(30)],
                argumentsKw: nil
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#result-0
    func testResultExample3Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [50,7814135,{},[30]]
                   """
        let model = Message.result(
            .init(
                request: .init(integerLiteral: 7814135),
                details: [:],
                arguments: [.integer(30)],
                argumentsKw: nil
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#result-0
    func testResultExample4Decoding() throws {
        // given
        let decoder = JSONDecoder()
        let json = """
                   [50, 7814135, {}, [], {"userid": 123, "karma": 10}]
                   """.data(using: .utf8)!
        let model = Message.result(
            .init(
                request: .init(integerLiteral: 7814135),
                details: [:],
                arguments: [],
                argumentsKw: [
                    "userid": .integer(123),
                    "karma": .integer(10)
                ]
            )
        )

        // when
        let message = try decoder.decode(Message.self, from: json)

        // then
        XCTAssertEqual(model, message)
    }

    // https://wamp-proto.org/_static/gen/wamp_latest.html#result-0
    func testResultExample4Encoding() throws {
        // given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = """
                   [50,7814135,{},[],{"karma":10,"userid":123}]
                   """
        let model = Message.result(
            .init(
                request: .init(integerLiteral: 7814135),
                details: [:],
                arguments: [],
                argumentsKw: [
                    "userid": .integer(123),
                    "karma": .integer(10)
                ]
            )
        )

        // when
        let message = try encoder.encode(model)

        // then
        XCTAssertEqual(json, String(data: message, encoding: .utf8)!)
    }
}
