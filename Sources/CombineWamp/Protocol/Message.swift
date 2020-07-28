import FoundationExtensions

/*
From: https://wamp-proto.org/_static/gen/wamp_latest.html#protocol-overview
 | Cod | Message        |  Pub |  Brk | Subs |  Calr | Dealr | Callee|
 |-----|----------------|------|------|------|-------|-------|-------|
 |  1  | `HELLO`        | Tx   | Rx   | Tx   | Tx    | Rx    | Tx    |
 |  2  | `WELCOME`      | Rx   | Tx   | Rx   | Rx    | Tx    | Rx    |
 |  3  | `ABORT`        | Rx   | TxRx | Rx   | Rx    | TxRx  | Rx    |
 |  6  | `GOODBYE`      | TxRx | TxRx | TxRx | TxRx  | TxRx  | TxRx  |
 |     |                |      |      |      |       |       |       |
 |  8  | `ERROR`        | Rx   | Tx   | Rx   | Rx    | TxRx  | TxRx  |
 |     |                |      |      |      |       |       |       |
 | 16  | `PUBLISH`      | Tx   | Rx   |      |       |       |       |
 | 17  | `PUBLISHED`    | Rx   | Tx   |      |       |       |       |
 |     |                |      |      |      |       |       |       |
 | 32  | `SUBSCRIBE`    |      | Rx   | Tx   |       |       |       |
 | 33  | `SUBSCRIBED`   |      | Tx   | Rx   |       |       |       |
 | 34  | `UNSUBSCRIBE`  |      | Rx   | Tx   |       |       |       |
 | 35  | `UNSUBSCRIBED` |      | Tx   | Rx   |       |       |       |
 | 36  | `EVENT`        |      | Tx   | Rx   |       |       |       |
 |     |                |      |      |      |       |       |       |
 | 48  | `CALL`         |      |      |      | Tx    | Rx    |       |
 | 50  | `RESULT`       |      |      |      | Rx    | Tx    |       |
 |     |                |      |      |      |       |       |       |
 | 64  | `REGISTER`     |      |      |      |       | Rx    | Tx    |
 | 65  | `REGISTERED`   |      |      |      |       | Tx    | Rx    |
 | 66  | `UNREGISTER`   |      |      |      |       | Rx    | Tx    |
 | 67  | `UNREGISTERED` |      |      |      |       | Tx    | Rx    |
 | 68  | `INVOCATION`   |      |      |      |       | Tx    | Rx    |
 | 70  | `YIELD`        |      |      |      |       | Rx    | Tx    |
 */

public typealias MessageType = Int

public enum Message: Equatable {
    case hello(Hello)
    case welcome(Welcome)
    case abort(Abort)
    case goodbye(Goodbye)
    case error(WampError)
    case publish(Publish)
    case published(Published)
    case subscribe(Subscribe)
    case subscribed(Subscribed)
    case unsubscribe(Unsubscribe)
    case unsubscribed(Unsubscribed)
    case event(Event)
    case register(Register)
    case registered(Registered)
    case unregister(Unregister)
    case unregistered(Unregistered)
    case call(Call)
    case result(Result)
    case invocation(Invocation)
    case yield(Yield)
}

extension Message: Decodable {
    public init(from decoder: Decoder) throws {
        var arrayContainer = try decoder.unkeyedContainer()
        let type = try arrayContainer.decode(Int.self)
        switch type {
        case Hello.type:
            self = try .hello(Hello(from: decoder))
        case Welcome.type:
            self = try .welcome(Welcome(from: decoder))
        case Abort.type:
            self = try .abort(Abort(from: decoder))
        case Goodbye.type:
            self = try .goodbye(Goodbye(from: decoder))
        case WampError.type:
            self = try .error(WampError(from: decoder))
        case Publish.type:
            self = try .publish(Publish(from: decoder))
        case Published.type:
            self = try .published(Published(from: decoder))
        case Subscribe.type:
            self = try .subscribe(Subscribe(from: decoder))
        case Subscribed.type:
            self = try .subscribed(Subscribed(from: decoder))
        case Unsubscribe.type:
            self = try .unsubscribe(Unsubscribe(from: decoder))
        case Unsubscribed.type:
            self = try .unsubscribed(Unsubscribed(from: decoder))
        case Event.type:
            self = try .event(Event(from: decoder))
        case Register.type:
            self = try .register(Register(from: decoder))
        case Registered.type:
            self = try .registered(Registered(from: decoder))
        case Unregister.type:
            self = try .unregister(Unregister(from: decoder))
        case Unregistered.type:
            self = try .unregistered(Unregistered(from: decoder))
        case Call.type:
            self = try .call(Call(from: decoder))
        case Result.type:
            self = try .result(Result(from: decoder))
        case Invocation.type:
            self = try .invocation(Invocation(from: decoder))
        case Yield.type:
            self = try .yield(Yield(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(in: arrayContainer, debugDescription: "Unknown message type \(type)")
        }
    }
}

extension Message: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .hello(hello):
            try hello.encode(to: encoder)
        case let .welcome(welcome):
            try welcome.encode(to: encoder)
        case let .abort(abort):
            try abort.encode(to: encoder)
        case let .goodbye(goodbye):
            try goodbye.encode(to: encoder)
        case let .error(error):
            try error.encode(to: encoder)
        case let .publish(publish):
            try publish.encode(to: encoder)
        case let .published(published):
            try published.encode(to: encoder)
        case let .subscribe(subscribe):
            try subscribe.encode(to: encoder)
        case let .subscribed(subscribed):
            try subscribed.encode(to: encoder)
        case let .unsubscribe(unsubscribe):
            try unsubscribe.encode(to: encoder)
        case let .unsubscribed(unsubscribed):
            try unsubscribed.encode(to: encoder)
        case let .event(event):
            try event.encode(to: encoder)
        case let .register(register):
            try register.encode(to: encoder)
        case let .registered(registered):
            try registered.encode(to: encoder)
        case let .unregister(unregister):
            try unregister.encode(to: encoder)
        case let .unregistered(unregistered):
            try unregistered.encode(to: encoder)
        case let .call(call):
            try call.encode(to: encoder)
        case let .result(result):
            try result.encode(to: encoder)
        case let .invocation(invocation):
            try invocation.encode(to: encoder)
        case let .yield(yield):
            try yield.encode(to: encoder)
        }
    }
}
