# CombineWamp
Implementation of WAMP protocol (https://wamp-proto.org/) using native Swift 5.3 and Combine (iOS >= 13, macOS >= 10.15, watchOS >= 6, tvOS >= 13).

# Connection infrastructure
The connection infrastructure is composed by 3 main elements:
- Serialization
- Transport
- Realm
- Session

## Serialization
`WampSerializing` defines how the messages will be serialized or deserialized from String.
By default, WAMP uses JSON, so this serialization mode can be easily created by calling:
```swift
let serialization = WampSerializing.json(
    decoder: JSONDecoder.init,
    encoder: JSONEncoder.init
)
```
Other serialization protocols can be easily implemented by you.

## Transport
`WampTransport` defines how the messages will be sent and received over the network.
By default, WAMP uses WebSockets, so this transport mode can be easily created by calling:
```swift
let transport = WampTransport.webSocket(
    wsURL: URL(string: "ws://localhost:8080/ws")!, 
    urlSession: URLSession.shared,
    serializationFormat: serialization.serializationFormat
)
```
Other transport methods can be easily implemented by you.

## Realm
A WAMP system may have one or more registered realms. They can even have different authentication or authorization rules.
Realms are usually created by Routers, so to establish a session all you have to do is to provide a valid Realm URI:
```swift
let realm = URI("de.teufel.my_app.public_realm")!
```
Please notice that CombineWamp works with strict URI rules (https://wamp-proto.org/_static/gen/wamp_latest.html#strict-uris).

## Session
A session glues all these things together. You can think of it as a client connection. The same session can be reused by certain client to perform different actions, such as publishing, subscribing, calling RPC procedures or responding RPC procedures. A client, if it wants, may also create more than a session, although this is not usually required.
```swift
let session = WampSession(transport: transport, serialization: serialization, realm: realm, roles: .allClientRoles)
```
Routers also have open sessions, but this is not implemented yet on CombineWamp.

# Client

A WAMP Client is the peer responsible for the actual messaging handling.

It may implement one or more of the following roles:
- Publisher: in the PubSub communication, this client will be able to publish events related to certain topic;
- Subscriber: in the PubSub communication, this client will be able to subscribe for events related to certain topic;
- Caller: in the RPC communication, this client will be able to call remote procedures registered by other clients;
- Callee: in the RPC communication, this client will be able to register procedures and respond when they are called by other clients.

After you created the session as demonstrated earlier, you can now connect to it. This will make your client say HELLO to the router and receive a WELCOME message, or an error:
```swift
session.connect()
    .sink(
        receiveCompletion: { [weak self] completion in
            self?.handleCompletion(completion)
        },
        receiveValue: { [weak self] welcome in
            self?.onJoin()
        }
    ).store(in: &cancellables)
```

From that point, we can access the `client` property from the session object. With that, we can, for example, leave the session by saying GOODBYE.
```swift
session
    .client
    .sayGoodbye()
    .sink(
        receiveCompletion: { [weak self] completion in
            self?.handleCompletion(completion)
        },
        receiveValue: { [weak self] goodbye in
            self?.onLeave()
        }
    ).store(in: &cancellables)
```

More interesting commands are available when you lift your Client to a specific role, such as Subscriber or Caller.
For that, please notice that your session must have been open with those roles set, or all client roles enabled (`roles: .allClientRoles`).

## As Publisher
Lifts a Client to a Publisher and allows publishing to topics in the WAMP Realm.
```swift
session
    .client
    .asPublisher?
    .publish(
        topic: URI("de.teufel.my_app.hello_topic")!, 
        positionalArguments: [
            .string("Answer to the Ultimate Question of Life, The Universe, and Everything!"), 
            .integer(42)
        ]
    )
    .sink(
        receiveCompletion: { [weak self] completion in
            self?.handleCompletion(completion)
        },
        receiveValue: { published in
            self?.onPublishedSuccessfully()
        }
    ).store(in: &cancellables)
```

Please notice that `session.client.asPublisher` returns an Optional `WampPublisher`. This will be nil in case you didn't set `.publisher` role on creating the `WampSession`.

Instead of calling `publish`, you may also consider calling `publishWithoutAck`. This one won't receive the acknowledgement from the router that the message was received by it, however not all routers will support this acknowledgements and in case you don't get it, you must fallback to the option without ack.

Also, instead of `positionalArguments` you may also consider `namedArguments`, which will expect a dictionary such as:
```swift
namedArguments: [
    "Answer to the Ultimate Question of Life, The Universe, and Everything!": .integer(42)
]
```

For the possible element types, please check [Element Types](#element-types) section below.

## As Subscriber
Lifts a Client to a Subscriber and allows subscribing to topics in the WAMP Realm.
```swift
session
    .client
    .asSubscriber?
    .subscribe(topic: URI("de.teufel.my_app.hello_topic")!, onUnsubscribe: { [weak self] unsubscribing in
        guard let self = self else { return }
        unsubscribing
            .run(
                onSuccess: { unsubscribed in
                    // Successfully unsubscribed
                },
                onFailure: { error in
                    // Handle unsubscribe error
                }
            )
            .store(in: &self.cancellables)
    })
    .sink(
        receiveCompletion: { [weak self] completion in
            self?.handleCompletion(completion)
        },
        receiveValue: { [weak self] event in
            self?.handleHelloTopicEvent(
                positionalArguments: event.positionalArguments,
                namedArguments: event.namedArguments
            )
        }
    ).store(in: &cancellables)
```

Please notice that `session.client.asSubscriber` returns an Optional `WampSubscriber`. This will be nil in case you didn't set `.subscriber` role on creating the `WampSession`.

It's important to provide a `onUnsubscribe` closure that in fact uses the promise given to you. This will ensure that an UNSUBSCRIBE message is sent to the router when this Combine subscription is cancelled. Be sure to use a valid `Set<AnyCancellable>`, and not one that was already disposed, or the UNSUBSCRIBE message won't be sent.

For the possible element types, please check [Element Types](#element-types) section below.

## As Caller
Lifts a Client to a Caller and allows calling remote procedures (RPC) in the WAMP Realm.
```swift
session
    .client
    .asCaller?
    .call(procedure: URI("de.teufel.my_app.sum")!, positionalArguments: [.integer(11), .integer(31)])
    .sink(
        receiveCompletion: { [weak self] completion in
            self?.handleCompletion(completion)
        },
        receiveValue: { [weak self] result in
            guard let sumResult = result.positionalArguments?[safe: 0]?.integer else { return }
            self?.handleSumResult(sumResult)
        }
    ).store(in: &cancellables)
```

Please notice that `session.client.asCaller` returns an Optional `WampCaller`. This will be nil in case you didn't set `.caller` role on creating the `WampSession`.

Instead of `positionalArguments` you may also consider `namedArguments`, which will expect a dictionary such as:
```swift
namedArguments: [
    "sum_left_side": .integer(11),
    "sum_right_side": .integer(31)
]
```

For the possible element types, please check [Element Types](#element-types) section below.

## As Callee
Lifts a Client to a Callee and allows registering remote procedures (RPC) in the WAMP Realm and be called by other clients.
```swift
session
    .client
    .asCallee?
    .register(procedure: URI("de.teufel.my_app.sum")!, onUnregister: { unregistering in
        unregistering
            .run(
                onSuccess: { unregistered in
                    // Successfully unregistered
                },
                onFailure: { error in
                    // Handle unregister error
                }
            )
            .store(in: &cancellables)
    })
    .sink(
        receiveCompletion: { [weak self] completion in
            self?.handleCompletion(completion)
        },
        receiveValue: { (invocation, responder) in
            let first = invocation.positionalArguments?[safe: 0]?.integer ?? 0
            let second = invocation.positionalArguments?[safe: 1]?.integer ?? 0
            let response = first - second
            responder([.integer(response)])
                .run(
                    onSuccess: { _ in
                    },
                    onFailure: { 
                        // Handle response error
                    }
                )
                .store(in: &cancellables)
        }
    ).store(in: &cancellables)
```

Please notice that `session.client.asCallee` returns an Optional `WampCallee`. This will be nil in case you didn't set `.callee` role on creating the `WampSession`.

It's important to provide a `onUnregister` closure that in fact uses the promise given to you. This will ensure that an UNREGISTER message is sent to the router when this Combine subscription is cancelled. Be sure to use a valid `Set<AnyCancellable>`, and not one that was already disposed, or the UNREGISTER message won't be sent.

For the possible element types, please check [Element Types](#element-types) section below.

## Element Types
The possible element types when sending arguments are:
```swift
public enum ElementType: Equatable {
    case integer(Int)
    case string(String)
    case bool(Bool)
    case double(Double)
    indirect case dict([String: ElementType])
    indirect case list([ElementType])
}
```
Please notice that `.double` is not part of standard WAMP protocol and may not be understood by other peers and certain languages. Be sure to validate it works in your environment before using it.

Optionally you can implement `ElementTypeConvertible` protocol in your structs to easily converted from and to WAMP Element Types. Otherwise you can easily write this manually.

Extracting values from this enum is easier thanks to calculated properties for each of the enum cases. For example:
```swift
let integer = element.integer ?? 0
let string = element.string ?? ""
let thirdInteger = element.list?[safe: 2]?.integer ?? 0
let userName = element.dict?["name"]?.string ?? ""
let userAddressStreet = element.dict?["address"]?.dict?["street"]?.string ?? ""
```

# Router
A WAMP Router is the peer responsible for coordinating, routing and proxying all clients communication

__Not implemented yet__