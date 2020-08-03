import Foundation
import FoundationExtensions

extension Message {
    internal struct Hello: ElementTypeConvertible, Equatable {
        internal init(realm: URI, details: [String : ElementType]) {
            self.realm = realm
            self.details = details
        }

        // [HELLO, Realm|uri, Details|dict]
        internal static let type: MessageType = 1
        internal let realm: URI
        internal let details: [String: ElementType]

        internal var asList: [ElementType] { [.integer(Self.type), .string(realm.description), .dict(details)] }
        internal static func from(list: [ElementType]) -> Message.Hello? {
            guard list[safe: 0]?.integer == Self.type,
                  let realm = list[safe: 1]?.string.flatMap(URI.init(_:)),
                  let details = list[safe: 2]?.dict
            else { return nil }
            return .init(realm: realm, details: details)
        }
    }

    internal struct Welcome: ElementTypeConvertible, Equatable {
        internal init(session: WampID, details: [String : ElementType]) {
            self.session = session
            self.details = details
        }

        // [WELCOME, Session|id, Details|dict]
        internal static let type: MessageType = 2
        internal let session: WampID
        internal let details: [String: ElementType]

        internal var asList: [ElementType] { [.integer(Self.type), .integer(session.value), .dict(details)] }
        internal static func from(list: [ElementType]) -> Message.Welcome? {
            guard list[safe: 0]?.integer == Self.type,
                  let session = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let details = list[safe: 2]?.dict
            else { return nil }
            return .init(session: session, details: details)
        }
    }

    internal struct Abort: ElementTypeConvertible, Equatable {
        internal init(details: [String : ElementType], reason: URI) {
            self.details = details
            self.reason = reason
        }

        // [ABORT, Details|dict, Reason|uri]
        internal static let type: MessageType = 3
        internal let details: [String: ElementType]
        internal let reason: URI

        internal var asList: [ElementType] { [.integer(Self.type), .dict(details), .string(reason.description)] }
        internal static func from(list: [ElementType]) -> Message.Abort? {
            guard list[safe: 0]?.integer == Self.type,
                  let details = list[safe: 1]?.dict,
                  let reason = list[safe: 2]?.string.map({ URI.init(unverified: $0, isWildcard: false) })
            else { return nil }
            return .init(details: details, reason: reason)
        }
    }

    internal struct Goodbye: ElementTypeConvertible, Equatable {
        internal init(details: [String : ElementType], reason: URI) {
            self.details = details
            self.reason = reason
        }

        // [GOODBYE, Details|dict, Reason|uri]
        internal static let type: MessageType = 6
        internal let details: [String: ElementType]
        internal let reason: URI

        internal var asList: [ElementType] { [.integer(Self.type), .dict(details), .string(reason.description)] }
        internal static func from(list: [ElementType]) -> Message.Goodbye? {
            guard list[safe: 0]?.integer == Self.type,
                  let details = list[safe: 1]?.dict,
                  let reason = list[safe: 2]?.string.map({ URI.init(unverified: $0, isWildcard: false) })
            else { return nil }
            return .init(details: details, reason: reason)
        }
    }

    internal struct WampError: ElementTypeConvertible, Equatable {
        internal init(requestType: MessageType, request: WampID, details: [String : ElementType], error: URI, arguments: [ElementType]?, argumentsKw: [String : ElementType]?) {
            self.requestType = requestType
            self.request = request
            self.details = details
            self.error = error
            self.arguments = arguments
            self.argumentsKw = argumentsKw
        }

        // [ERROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri]
        // [ERROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri, Arguments|list]
        // [ERROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri, Arguments|list, ArgumentsKw|dict]
        internal static let type: MessageType = 8
        internal let requestType: MessageType
        internal let request: WampID
        internal let details: [String: ElementType]
        internal let error: URI
        internal let arguments: [ElementType]?
        internal let argumentsKw: [String: ElementType]?

        internal var asList: [ElementType] { [.integer(Self.type), .integer(requestType), .integer(request.value), .dict(details), .string(error.description), arguments.map(ElementType.list), argumentsKw.map(ElementType.dict)].compactMap(identity) }
        internal static func from(list: [ElementType]) -> Message.WampError? {
            guard list[safe: 0]?.integer == Self.type,
                  let requestType = list[safe: 1]?.integer,
                  let request = list[safe: 2]?.integer.map(WampID.init(rawValue:)),
                  let details = list[safe: 3]?.dict,
                  let error = list[safe: 4]?.string.map({ URI.init(unverified: $0, isWildcard: false) })
            else { return nil }
            let arguments = list[safe: 5]?.list ?? list[safe: 6]?.list
            let argumentsKw = list[safe: 5]?.dict ?? list[safe: 6]?.dict
            return .init(requestType: requestType, request: request, details: details, error: error, arguments: arguments, argumentsKw: argumentsKw)
        }
    }

    internal struct Publish: ElementTypeConvertible, Equatable {
        internal init(request: WampID, options: [String : ElementType], topic: URI, arguments: [ElementType]?, argumentsKw: [String : ElementType]?) {
            self.request = request
            self.options = options
            self.topic = topic
            self.arguments = arguments
            self.argumentsKw = argumentsKw
        }

        // [PUBLISH, Request|id, Options|dict, Topic|uri]
        // [PUBLISH, Request|id, Options|dict, Topic|uri, Arguments|list]
        // [PUBLISH, Request|id, Options|dict, Topic|uri, Arguments|list, ArgumentsKw|dict]
        internal static let type: MessageType = 16
        internal let request: WampID
        internal let options: [String: ElementType]
        internal let topic: URI
        internal let arguments: [ElementType]?
        internal let argumentsKw: [String: ElementType]?

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .dict(options), .string(topic.description), arguments.map(ElementType.list), argumentsKw.map(ElementType.dict)].compactMap(identity) }
        internal static func from(list: [ElementType]) -> Message.Publish? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let options = list[safe: 2]?.dict,
                  let topic = list[safe: 3]?.string.flatMap(URI.init(_:))
            else { return nil }
            let arguments = list[safe: 4]?.list ?? list[safe: 5]?.list
            let argumentsKw = list[safe: 4]?.dict ?? list[safe: 5]?.dict
            return .init(request: request, options: options, topic: topic, arguments: arguments, argumentsKw: argumentsKw)
        }
    }

    internal struct Published: ElementTypeConvertible, Equatable {
        internal init(request: WampID, publication: WampID) {
            self.request = request
            self.publication = publication
        }

        // [PUBLISHED, PUBLISH.Request|id, Publication|id]
        internal static let type: MessageType = 17
        internal let request: WampID
        internal let publication: WampID

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(publication.value)] }
        internal static func from(list: [ElementType]) -> Message.Published? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let publication = list[safe: 2]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request, publication: publication)
        }
    }

    internal struct Subscribe: ElementTypeConvertible, Equatable {
        internal init(request: WampID, options: [String : ElementType], topic: URI) {
            self.request = request
            self.options = options
            self.topic = topic
        }

        // [SUBSCRIBE, Request|id, Options|dict, Topic|uri]
        internal static let type: MessageType = 32
        internal let request: WampID
        internal let options: [String: ElementType]
        internal let topic: URI

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .dict(options), .string(topic.description)] }
        internal static func from(list: [ElementType]) -> Message.Subscribe? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let options = list[safe: 2]?.dict,
                  let topic = list[safe: 3]?.string.flatMap(URI.init(_:))
            else { return nil }
            return .init(request: request, options: options, topic: topic)
        }
    }

    internal struct Subscribed: ElementTypeConvertible, Equatable {
        internal init(request: WampID, subscription: WampID) {
            self.request = request
            self.subscription = subscription
        }

        // [SUBSCRIBED, SUBSCRIBE.Request|id, Subscription|id]
        internal static let type: MessageType = 33
        internal let request: WampID
        internal let subscription: WampID

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(subscription.value)] }
        internal static func from(list: [ElementType]) -> Message.Subscribed? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let subscription = list[safe: 2]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request, subscription: subscription)
        }
    }

    internal struct Unsubscribe: ElementTypeConvertible, Equatable {
        internal init(request: WampID, subscription: WampID) {
            self.request = request
            self.subscription = subscription
        }

        // [UNSUBSCRIBE, Request|id, SUBSCRIBED.Subscription|id]
        internal static let type: MessageType = 34
        internal let request: WampID
        internal let subscription: WampID

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(subscription.value)] }
        internal static func from(list: [ElementType]) -> Message.Unsubscribe? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let subscription = list[safe: 2]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request, subscription: subscription)
        }
    }

    internal struct Unsubscribed: ElementTypeConvertible, Equatable {
        internal init(request: WampID) {
            self.request = request
        }

        // [UNSUBSCRIBED, UNSUBSCRIBE.Request|id]
        internal static let type: MessageType = 35
        internal let request: WampID

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value)] }
        internal static func from(list: [ElementType]) -> Message.Unsubscribed? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request)
        }
    }

    internal struct Event: ElementTypeConvertible, Equatable {
        internal init(subscription: WampID, publication: WampID, details: [String : ElementType], arguments: [ElementType]?, argumentsKw: [String : ElementType]?) {
            self.subscription = subscription
            self.publication = publication
            self.details = details
            self.arguments = arguments
            self.argumentsKw = argumentsKw
        }

        // [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict]
        // [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict, PUBLISH.Arguments|list]
        // [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict, PUBLISH.Arguments|list, PUBLISH.ArgumentsKw|dict]
        internal static let type: MessageType = 36
        internal let subscription: WampID
        internal let publication: WampID
        internal let details: [String: ElementType]
        internal let arguments: [ElementType]?
        internal let argumentsKw: [String: ElementType]?

        internal var asList: [ElementType] { [.integer(Self.type), .integer(subscription.value), .integer(publication.value), .dict(details), arguments.map(ElementType.list), argumentsKw.map(ElementType.dict)].compactMap(identity) }
        internal static func from(list: [ElementType]) -> Message.Event? {
            guard list[safe: 0]?.integer == Self.type,
                  let subscription = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let publication = list[safe: 2]?.integer.map(WampID.init(rawValue:)),
                  let details = list[safe: 3]?.dict
            else { return nil }
            let arguments = list[safe: 4]?.list ?? list[safe: 5]?.list
            let argumentsKw = list[safe: 4]?.dict ?? list[safe: 5]?.dict
            return .init(subscription: subscription, publication: publication, details: details, arguments: arguments, argumentsKw: argumentsKw)
        }
    }

    internal struct Call: ElementTypeConvertible, Equatable {
        internal init(request: WampID, options: [String : ElementType], procedure: URI, arguments: [ElementType]?, argumentsKw: [String : ElementType]?) {
            self.request = request
            self.options = options
            self.procedure = procedure
            self.arguments = arguments
            self.argumentsKw = argumentsKw
        }

        // [CALL, Request|id, Options|dict, Procedure|uri]
        // [CALL, Request|id, Options|dict, Procedure|uri, Arguments|list]
        // [CALL, Request|id, Options|dict, Procedure|uri, Arguments|list, ArgumentsKw|dict]
        internal static let type: MessageType = 48
        internal let request: WampID
        internal let options: [String: ElementType]
        internal let procedure: URI
        internal let arguments: [ElementType]?
        internal let argumentsKw: [String: ElementType]?

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .dict(options), .string(procedure.description), arguments.map(ElementType.list), argumentsKw.map(ElementType.dict)].compactMap(identity) }
        internal static func from(list: [ElementType]) -> Message.Call? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let options = list[safe: 2]?.dict,
                  let procedure = list[safe: 3]?.string.flatMap(URI.init(_:))
            else { return nil }
            let arguments = list[safe: 4]?.list ?? list[safe: 5]?.list
            let argumentsKw = list[safe: 4]?.dict ?? list[safe: 5]?.dict
            return .init(request: request, options: options, procedure: procedure, arguments: arguments, argumentsKw: argumentsKw)
        }
    }

    internal struct Result: ElementTypeConvertible, Equatable {
        internal init(request: WampID, details: [String : ElementType], arguments: [ElementType]?, argumentsKw: [String : ElementType]?) {
            self.request = request
            self.details = details
            self.arguments = arguments
            self.argumentsKw = argumentsKw
        }

        // [RESULT, CALL.Request|id, Details|dict]
        // [RESULT, CALL.Request|id, Details|dict, YIELD.Arguments|list]
        // [RESULT, CALL.Request|id, Details|dict, YIELD.Arguments|list, YIELD.ArgumentsKw|dict]
        internal static let type: MessageType = 50
        internal let request: WampID
        internal let details: [String: ElementType]
        internal let arguments: [ElementType]?
        internal let argumentsKw: [String: ElementType]?

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .dict(details), arguments.map(ElementType.list), argumentsKw.map(ElementType.dict)].compactMap(identity) }
        internal static func from(list: [ElementType]) -> Message.Result? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let details = list[safe: 2]?.dict
            else { return nil }
            let arguments = list[safe: 3]?.list ?? list[safe: 4]?.list
            let argumentsKw = list[safe: 3]?.dict ?? list[safe: 4]?.dict
            return .init(request: request, details: details, arguments: arguments, argumentsKw: argumentsKw)
        }
    }

    internal struct Register: ElementTypeConvertible, Equatable {
        internal init(request: WampID, options: [String : ElementType], procedure: URI) {
            self.request = request
            self.options = options
            self.procedure = procedure
        }

        // [REGISTER, Request|id, Options|dict, Procedure|uri]
        internal static let type: MessageType = 64
        internal let request: WampID
        internal let options: [String: ElementType]
        internal let procedure: URI

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .dict(options), .string(procedure.description)] }
        internal static func from(list: [ElementType]) -> Message.Register? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let options = list[safe: 2]?.dict,
                  let procedure = list[safe: 3]?.string.flatMap(URI.init(_:))
            else { return nil }
            return .init(request: request, options: options, procedure: procedure)
        }
    }

    internal struct Registered: ElementTypeConvertible, Equatable {
        internal init(request: WampID, registration: WampID) {
            self.request = request
            self.registration = registration
        }

        // [REGISTERED, REGISTER.Request|id, Registration|id]
        internal static let type: MessageType = 65
        internal let request: WampID
        internal let registration: WampID

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(registration.value)] }
        internal static func from(list: [ElementType]) -> Message.Registered? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let registration = list[safe: 2]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request, registration: registration)
        }
    }

    internal struct Unregister: ElementTypeConvertible, Equatable {
        internal init(request: WampID, registration: WampID) {
            self.request = request
            self.registration = registration
        }

        // [UNREGISTER, Request|id, REGISTERED.Registration|id]
        internal static let type: MessageType = 66
        internal let request: WampID
        internal let registration: WampID

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(registration.value)] }
        internal static func from(list: [ElementType]) -> Message.Unregister? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let registration = list[safe: 2]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request, registration: registration)
        }
    }

    internal struct Unregistered: ElementTypeConvertible, Equatable {
        internal init(request: WampID) {
            self.request = request
        }

        // [UNREGISTERED, UNREGISTER.Request|id]
        internal static let type: MessageType = 67
        internal let request: WampID

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value)] }
        internal static func from(list: [ElementType]) -> Message.Unregistered? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:))
            else { return nil }
            return .init(request: request)
        }
    }

    internal struct Invocation: ElementTypeConvertible, Equatable {
        internal init(request: WampID, registration: WampID, details: [String : ElementType], arguments: [ElementType]?, argumentsKw: [String : ElementType]?) {
            self.request = request
            self.registration = registration
            self.details = details
            self.arguments = arguments
            self.argumentsKw = argumentsKw
        }

        // [INVOCATION, Request|id, REGISTERED.Registration|id, Details|dict]
        // [INVOCATION, Request|id, REGISTERED.Registration|id, Details|dict, C* Arguments|list]
        // [INVOCATION, Request|id, REGISTERED.Registration|id, Details|dict, CALL.Arguments|list, CALL.ArgumentsKw|dict]
        internal static let type: MessageType = 68
        internal let request: WampID
        internal let registration: WampID
        internal let details: [String: ElementType]
        internal let arguments: [ElementType]?
        internal let argumentsKw: [String: ElementType]?

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .integer(registration.value), .dict(details), arguments.map(ElementType.list), argumentsKw.map(ElementType.dict)].compactMap(identity) }
        internal static func from(list: [ElementType]) -> Message.Invocation? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let registration = list[safe: 2]?.integer.map(WampID.init(rawValue:)),
                  let details = list[safe: 3]?.dict
            else { return nil }
            let arguments = list[safe: 4]?.list ?? list[safe: 5]?.list
            let argumentsKw = list[safe: 4]?.dict ?? list[safe: 5]?.dict
            return .init(request: request, registration: registration, details: details, arguments: arguments, argumentsKw: argumentsKw)
        }
    }

    internal struct Yield: ElementTypeConvertible, Equatable {
        internal init(request: WampID, options: [String : ElementType], arguments: [ElementType]?, argumentsKw: [String : ElementType]?) {
            self.request = request
            self.options = options
            self.arguments = arguments
            self.argumentsKw = argumentsKw
        }

        // [YIELD, INVOCATION.Request|id, Options|dict]
        // [YIELD, INVOCATION.Request|id, Options|dict, Arguments|list]
        // [YIELD, INVOCATION.Request|id, Options|dict, Arguments|list, ArgumentsKw|dict]
        internal static let type: MessageType = 70
        internal let request: WampID
        internal let options: [String: ElementType]
        internal let arguments: [ElementType]?
        internal let argumentsKw: [String: ElementType]?

        internal var asList: [ElementType] { [.integer(Self.type), .integer(request.value), .dict(options), arguments.map(ElementType.list), argumentsKw.map(ElementType.dict)].compactMap(identity) }
        internal static func from(list: [ElementType]) -> Message.Yield? {
            guard list[safe: 0]?.integer == Self.type,
                  let request = list[safe: 1]?.integer.map(WampID.init(rawValue:)),
                  let options = list[safe: 2]?.dict
            else { return nil }
            let arguments = list[safe: 3]?.list ?? list[safe: 4]?.list
            let argumentsKw = list[safe: 3]?.dict ?? list[safe: 4]?.dict
            return .init(request: request, options: options, arguments: arguments, argumentsKw: argumentsKw)
        }
    }
}
