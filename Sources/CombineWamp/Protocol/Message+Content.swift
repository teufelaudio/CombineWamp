import Foundation
import FoundationExtensions

public enum WampRole: String, CaseIterable {
    case publisher
    case subscriber
    case caller
    case callee
    case broker
    case dealer
}

extension Collection where Element == WampRole {
    public static var allClientRoles: Set<WampRole> {
        [.publisher, .subscriber, .caller, .callee]
    }

    public static var allRouterRoles: Set<WampRole> {
        [.dealer, .broker]
    }
}

extension Dictionary where Key == String, Value == ElementType {
    public static func roles(_ roles: Set<WampRole>) -> [String: ElementType] {
        [
            "roles": .dict(
                Dictionary(
                    uniqueKeysWithValues:
                        roles
                        .lazy
                        .map(\.rawValue)
                        .map { ($0, ElementType.dict([:])) }
                )
            )
        ]
    }
}

extension Message {
    public struct Hello: ElementTypeConvertible, Equatable {
        public init(realm: URI, details: [String: ElementType]) {
            self.realm = realm
            self.details = details
        }

        // [HELLO, Realm|uri, Details|dict]
        public static let type: MessageType = 1
        public let realm: URI
        public let details: [String: ElementType]

        public var asList: [ElementType] { [.integer(Self.type), .string(realm.description), .dict(details)] }
        public static func from(list: [ElementType]) -> Message.Hello? {
            guard list[safe: 0]?.integer == Self.type,
                  let realm = list[safe: 1]?.string.flatMap(URI.init(_:)),
                  let details = list[safe: 2]?.dict
            else { return nil }
            return .init(realm: realm, details: details)
        }
    }

    public struct Welcome: ElementTypeConvertible, Equatable {
        public init(session: WampID, details: [String : ElementType]) {
            self.session = session
            self.details = details
        }

        // [WELCOME, Session|id, Details|dict]
        public static let type: MessageType = 2
        public let session: WampID
        public let details: [String: ElementType]

        public var asList: [ElementType] { [.integer(Self.type), .integer(session.value), .dict(details)] }
        public static func from(list: [ElementType]) -> Message.Welcome? {
            guard list[safe: 0]?.integer == Self.type,
                  let session = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let details = list[safe: 2]?.dict
            else { return nil }
            return .init(session: session, details: details)
        }
    }

    public struct Abort: ElementTypeConvertible, Equatable {
        public init(details: [String : ElementType], reason: URI) {
            self.details = details
            self.reason = reason
        }

        // [ABORT, Details|dict, Reason|uri]
        public static let type: MessageType = 3
        public let details: [String: ElementType]
        public let reason: URI

        public var asList: [ElementType] { [.integer(Self.type), .dict(details), .string(reason.description)] }
        public static func from(list: [ElementType]) -> Message.Abort? {
            guard list[safe: 0]?.integer == Self.type,
                  let details = list[safe: 1]?.dict,
                  let reason = list[safe: 2]?.string.map({ URI.init(unverified: $0, isWildcard: false) })
            else { return nil }
            return .init(details: details, reason: reason)
        }
    }

    public struct Goodbye: ElementTypeConvertible, Equatable {
        public init(details: [String : ElementType], reason: WampClose) {
            self.details = details
            self.reason = reason
        }

        // [GOODBYE, Details|dict, Reason|uri]
        public static let type: MessageType = 6
        public let details: [String: ElementType]
        public let reason: WampClose

        public var asList: [ElementType] { [.integer(Self.type), .dict(details), .string(reason.uri.description)] }
        public static func from(list: [ElementType]) -> Message.Goodbye? {
            guard list[safe: 0]?.integer == Self.type,
                  let details = list[safe: 1]?.dict,
                  let reasonURI = list[safe: 2]?.string.map({ URI.init(unverified: $0, isWildcard: false) })
            else { return nil }
            let reason = WampClose.allCases.first(where: { $0.uri == reasonURI }) ?? WampClose(uri: reasonURI, code: .normal, isAck: false)
            return .init(details: details, reason: reason)
        }
    }

    public struct WampError: ElementTypeConvertible, Equatable {
        public init(requestType: MessageType, request: WampID, details: [String : ElementType], error: URI, positionalArguments: [ElementType]?, namedArguments: [String : ElementType]?) {
            self.requestType = requestType
            self.request = request
            self.details = details
            self.error = error
            self.positionalArguments = positionalArguments
            self.namedArguments = namedArguments
        }

        // [ERROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri]
        // [ERROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri, Arguments|list]
        // [ERROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri, Arguments|list, ArgumentsKw|dict]
        public static let type: MessageType = 8
        public let requestType: MessageType
        public let request: WampID
        public let details: [String: ElementType]
        public let error: URI
        public let positionalArguments: [ElementType]?
        public let namedArguments: [String: ElementType]?

        public var asList: [ElementType] {
            [.integer(Self.type), .integer(requestType), .integer(request.value), .dict(details), .string(error.description)]
                + parseArguments(positional: positionalArguments, named: namedArguments)
        }
        public static func from(list: [ElementType]) -> Message.WampError? {
            guard list[safe: 0]?.integer == Self.type,
                  let requestType = list[safe: 1]?.integer,
                  let request = list[safe: 2]?.integer.map(WampID.init(rawValue:)),
                  let details = list[safe: 3]?.dict,
                  let error = list[safe: 4]?.string.map({ URI.init(unverified: $0, isWildcard: false) })
            else { return nil }
            let positionalArguments = list[safe: 5]?.list ?? list[safe: 6]?.list
            let namedArguments = list[safe: 5]?.dict ?? list[safe: 6]?.dict
            return .init(requestType: requestType, request: request, details: details, error: error, positionalArguments: positionalArguments, namedArguments: namedArguments)
        }
    }

    public struct Publish: ElementTypeConvertible, Equatable {
        public init(request: WampID, options: [String : ElementType], topic: URI, positionalArguments: [ElementType]?, namedArguments: [String : ElementType]?) {
            self.request = request
            self.options = options
            self.topic = topic
            self.positionalArguments = positionalArguments
            self.namedArguments = namedArguments
        }

        // [PUBLISH, Request|id, Options|dict, Topic|uri]
        // [PUBLISH, Request|id, Options|dict, Topic|uri, Arguments|list]
        // [PUBLISH, Request|id, Options|dict, Topic|uri, Arguments|list, ArgumentsKw|dict]
        public static let type: MessageType = 16
        public let request: WampID
        public let options: [String: ElementType]
        public let topic: URI
        public let positionalArguments: [ElementType]?
        public let namedArguments: [String: ElementType]?

        public var asList: [ElementType] {
            [.integer(Self.type), .integer(request.value), .dict(options), .string(topic.description)]
                + parseArguments(positional: positionalArguments, named: namedArguments)
        }
        public static func from(list: [ElementType]) -> Message.Publish? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let options = list[safe: 2]?.dict,
                  let topic = list[safe: 3]?.string.flatMap(URI.init(_:))
            else { return nil }
            let positionalArguments = list[safe: 4]?.list ?? list[safe: 5]?.list
            let namedArguments = list[safe: 4]?.dict ?? list[safe: 5]?.dict
            return .init(request: request, options: options, topic: topic, positionalArguments: positionalArguments, namedArguments: namedArguments)
        }
    }

    public struct Published: ElementTypeConvertible, Equatable {
        public init(request: WampID, publication: WampID) {
            self.request = request
            self.publication = publication
        }

        // [PUBLISHED, PUBLISH.Request|id, Publication|id]
        public static let type: MessageType = 17
        public let request: WampID
        public let publication: WampID

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(publication.value)] }
        public static func from(list: [ElementType]) -> Message.Published? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let publication = list[safe: 2]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request, publication: publication)
        }
    }

    public struct Subscribe: ElementTypeConvertible, Equatable {
        public init(request: WampID, options: [String : ElementType], topic: URI) {
            self.request = request
            self.options = options
            self.topic = topic
        }

        // [SUBSCRIBE, Request|id, Options|dict, Topic|uri]
        public static let type: MessageType = 32
        public let request: WampID
        public let options: [String: ElementType]
        public let topic: URI

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .dict(options), .string(topic.description)] }
        public static func from(list: [ElementType]) -> Message.Subscribe? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let options = list[safe: 2]?.dict,
                  let topic = list[safe: 3]?.string.flatMap(URI.init(_:))
            else { return nil }
            return .init(request: request, options: options, topic: topic)
        }
    }

    public struct Subscribed: ElementTypeConvertible, Equatable {
        public init(request: WampID, subscription: WampID) {
            self.request = request
            self.subscription = subscription
        }

        // [SUBSCRIBED, SUBSCRIBE.Request|id, Subscription|id]
        public static let type: MessageType = 33
        public let request: WampID
        public let subscription: WampID

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(subscription.value)] }
        public static func from(list: [ElementType]) -> Message.Subscribed? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let subscription = list[safe: 2]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request, subscription: subscription)
        }
    }

    public struct Unsubscribe: ElementTypeConvertible, Equatable {
        public init(request: WampID, subscription: WampID) {
            self.request = request
            self.subscription = subscription
        }

        // [UNSUBSCRIBE, Request|id, SUBSCRIBED.Subscription|id]
        public static let type: MessageType = 34
        public let request: WampID
        public let subscription: WampID

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(subscription.value)] }
        public static func from(list: [ElementType]) -> Message.Unsubscribe? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let subscription = list[safe: 2]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request, subscription: subscription)
        }
    }

    public struct Unsubscribed: ElementTypeConvertible, Equatable {
        public init(request: WampID) {
            self.request = request
        }

        // [UNSUBSCRIBED, UNSUBSCRIBE.Request|id]
        public static let type: MessageType = 35
        public let request: WampID

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value)] }
        public static func from(list: [ElementType]) -> Message.Unsubscribed? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request)
        }
    }

    public struct Event: ElementTypeConvertible, Equatable {
        public init(subscription: WampID, publication: WampID, details: [String : ElementType], positionalArguments: [ElementType]?, namedArguments: [String : ElementType]?) {
            self.subscription = subscription
            self.publication = publication
            self.details = details
            self.positionalArguments = positionalArguments
            self.namedArguments = namedArguments
        }

        // [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict]
        // [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict, PUBLISH.Arguments|list]
        // [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict, PUBLISH.Arguments|list, PUBLISH.ArgumentsKw|dict]
        public static let type: MessageType = 36
        public let subscription: WampID
        public let publication: WampID
        public let details: [String: ElementType]
        public let positionalArguments: [ElementType]?
        public let namedArguments: [String: ElementType]?

        public var asList: [ElementType] {
            [.integer(Self.type), .integer(subscription.value), .integer(publication.value), .dict(details)]
                + parseArguments(positional: positionalArguments, named: namedArguments)
        }
        public static func from(list: [ElementType]) -> Message.Event? {
            guard list[safe: 0]?.integer == Self.type,
                  let subscription = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let publication = list[safe: 2]?.integer.map(WampID.init(rawValue:)),
                  let details = list[safe: 3]?.dict
            else { return nil }
            let positionalArguments = list[safe: 4]?.list ?? list[safe: 5]?.list
            let namedArguments = list[safe: 4]?.dict ?? list[safe: 5]?.dict
            return .init(subscription: subscription, publication: publication, details: details, positionalArguments: positionalArguments, namedArguments: namedArguments)
        }
    }

    public struct Call: ElementTypeConvertible, Equatable {
        public init(request: WampID, options: [String : ElementType], procedure: URI, positionalArguments: [ElementType]?, namedArguments: [String : ElementType]?) {
            self.request = request
            self.options = options
            self.procedure = procedure
            self.positionalArguments = positionalArguments
            self.namedArguments = namedArguments
        }

        // [CALL, Request|id, Options|dict, Procedure|uri]
        // [CALL, Request|id, Options|dict, Procedure|uri, Arguments|list]
        // [CALL, Request|id, Options|dict, Procedure|uri, Arguments|list, ArgumentsKw|dict]
        public static let type: MessageType = 48
        public let request: WampID
        public let options: [String: ElementType]
        public let procedure: URI
        public let positionalArguments: [ElementType]?
        public let namedArguments: [String: ElementType]?

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .dict(options), .string(procedure.description)]
            + parseArguments(positional: positionalArguments, named: namedArguments)
        }
        public static func from(list: [ElementType]) -> Message.Call? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let options = list[safe: 2]?.dict,
                  let procedure = list[safe: 3]?.string.flatMap(URI.init(_:))
            else { return nil }
            let positionalArguments = list[safe: 4]?.list ?? list[safe: 5]?.list
            let namedArguments = list[safe: 4]?.dict ?? list[safe: 5]?.dict
            return .init(request: request, options: options, procedure: procedure, positionalArguments: positionalArguments, namedArguments: namedArguments)
        }
    }

    public struct Result: ElementTypeConvertible, Equatable {
        public init(request: WampID, details: [String : ElementType], positionalArguments: [ElementType]?, namedArguments: [String : ElementType]?) {
            self.request = request
            self.details = details
            self.positionalArguments = positionalArguments
            self.namedArguments = namedArguments
        }

        // [RESULT, CALL.Request|id, Details|dict]
        // [RESULT, CALL.Request|id, Details|dict, YIELD.Arguments|list]
        // [RESULT, CALL.Request|id, Details|dict, YIELD.Arguments|list, YIELD.ArgumentsKw|dict]
        public static let type: MessageType = 50
        public let request: WampID
        public let details: [String: ElementType]
        public let positionalArguments: [ElementType]?
        public let namedArguments: [String: ElementType]?

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .dict(details)]
            + parseArguments(positional: positionalArguments, named: namedArguments)
        }
        public static func from(list: [ElementType]) -> Message.Result? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let details = list[safe: 2]?.dict
            else { return nil }
            let positionalArguments = list[safe: 3]?.list ?? list[safe: 4]?.list
            let namedArguments = list[safe: 3]?.dict ?? list[safe: 4]?.dict
            return .init(request: request, details: details, positionalArguments: positionalArguments, namedArguments: namedArguments)
        }
    }

    public struct Register: ElementTypeConvertible, Equatable {
        public init(request: WampID, options: [String : ElementType], procedure: URI) {
            self.request = request
            self.options = options
            self.procedure = procedure
        }

        // [REGISTER, Request|id, Options|dict, Procedure|uri]
        public static let type: MessageType = 64
        public let request: WampID
        public let options: [String: ElementType]
        public let procedure: URI

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .dict(options), .string(procedure.description)] }
        public static func from(list: [ElementType]) -> Message.Register? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let options = list[safe: 2]?.dict,
                  let procedure = list[safe: 3]?.string.flatMap(URI.init(_:))
            else { return nil }
            return .init(request: request, options: options, procedure: procedure)
        }
    }

    public struct Registered: ElementTypeConvertible, Equatable {
        public init(request: WampID, registration: WampID) {
            self.request = request
            self.registration = registration
        }

        // [REGISTERED, REGISTER.Request|id, Registration|id]
        public static let type: MessageType = 65
        public let request: WampID
        public let registration: WampID

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(registration.value)] }
        public static func from(list: [ElementType]) -> Message.Registered? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let registration = list[safe: 2]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request, registration: registration)
        }
    }

    public struct Unregister: ElementTypeConvertible, Equatable {
        public init(request: WampID, registration: WampID) {
            self.request = request
            self.registration = registration
        }

        // [UNREGISTER, Request|id, REGISTERED.Registration|id]
        public static let type: MessageType = 66
        public let request: WampID
        public let registration: WampID

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(registration.value)] }
        public static func from(list: [ElementType]) -> Message.Unregister? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let registration = list[safe: 2]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request, registration: registration)
        }
    }

    public struct Unregistered: ElementTypeConvertible, Equatable {
        public init(request: WampID) {
            self.request = request
        }

        // [UNREGISTERED, UNREGISTER.Request|id]
        public static let type: MessageType = 67
        public let request: WampID

        public var asList: [ElementType] { [.integer(Self.type), .integer(request.value)] }
        public static func from(list: [ElementType]) -> Message.Unregistered? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request)
        }
    }

    public struct Invocation: ElementTypeConvertible, Equatable {
        public init(request: WampID, registration: WampID, details: [String : ElementType], positionalArguments: [ElementType]?, namedArguments: [String : ElementType]?) {
            self.request = request
            self.registration = registration
            self.details = details
            self.positionalArguments = positionalArguments
            self.namedArguments = namedArguments
        }

        // [INVOCATION, Request|id, REGISTERED.Registration|id, Details|dict]
        // [INVOCATION, Request|id, REGISTERED.Registration|id, Details|dict, C* Arguments|list]
        // [INVOCATION, Request|id, REGISTERED.Registration|id, Details|dict, CALL.Arguments|list, CALL.ArgumentsKw|dict]
        public static let type: MessageType = 68
        public let request: WampID
        public let registration: WampID
        public let details: [String: ElementType]
        public let positionalArguments: [ElementType]?
        public let namedArguments: [String: ElementType]?

        public var asList: [ElementType] {
            [.integer(Self.type), .integer(request.value), .integer(registration.value), .dict(details)]
                + parseArguments(positional: positionalArguments, named: namedArguments)
        }
        public static func from(list: [ElementType]) -> Message.Invocation? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let registration = list[safe: 2]?.integer.map(WampID.init(rawValue:)),
                  let details = list[safe: 3]?.dict
            else { return nil }
            let positionalArguments = list[safe: 4]?.list ?? list[safe: 5]?.list
            let namedArguments = list[safe: 4]?.dict ?? list[safe: 5]?.dict
            return .init(request: request, registration: registration, details: details, positionalArguments: positionalArguments, namedArguments: namedArguments)
        }
    }

    public struct Yield: ElementTypeConvertible, Equatable {
        public init(request: WampID, options: [String : ElementType], positionalArguments: [ElementType]?, namedArguments: [String : ElementType]?) {
            self.request = request
            self.options = options
            self.positionalArguments = positionalArguments
            self.namedArguments = namedArguments
        }

        // [YIELD, INVOCATION.Request|id, Options|dict]
        // [YIELD, INVOCATION.Request|id, Options|dict, Arguments|list]
        // [YIELD, INVOCATION.Request|id, Options|dict, Arguments|list, ArgumentsKw|dict]
        public static let type: MessageType = 70
        public let request: WampID
        public let options: [String: ElementType]
        public let positionalArguments: [ElementType]?
        public let namedArguments: [String: ElementType]?

        public var asList: [ElementType] {
            [.integer(Self.type), .integer(request.value), .dict(options)]
                + parseArguments(positional: positionalArguments, named: namedArguments)
        }

        public static func from(list: [ElementType]) -> Message.Yield? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let options = list[safe: 2]?.dict
            else { return nil }
            let positionalArguments = list[safe: 3]?.list ?? list[safe: 4]?.list
            let namedArguments = list[safe: 3]?.dict ?? list[safe: 4]?.dict
            return .init(request: request, options: options, positionalArguments: positionalArguments, namedArguments: namedArguments)
        }
    }
}

func parseArguments(positional: [ElementType]?, named: [String: ElementType]?) -> [ElementType] {
    // If both are nil, we send no parameter
    if positional == nil, named == nil { return [] }
    // If any of them is not nil, positional is required
    // But name is sent only if it's not nil
    return [ElementType.list(positional ?? [])] + [named.map(ElementType.dict)].compactMap(identity)
}
