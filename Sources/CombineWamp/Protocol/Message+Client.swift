import Foundation

/// Clients messages
extension Message {
    internal enum Client: Equatable {
        internal enum Output: Equatable {
            case hello(Hello)
            case goodbye(Goodbye)

            internal func toMessage() -> Message {
                switch self {
                case let .hello(hello): return .hello(hello)
                case let .goodbye(goodbye): return .goodbye(goodbye)
                }
            }
        }

        internal enum Input: Equatable {
            case welcome(Welcome)
            case abort(Abort)
            case goodbye(Goodbye)
            case error(WampError)

            internal init?(from message: Message) {
                switch message {
                case let .welcome(welcome): self = .welcome(welcome)
                case let .abort(abort): self = .abort(abort)
                case let .goodbye(goodbye): self = .goodbye(goodbye)
                case let .error(error): self = .error(error)
                default: return nil
                }
            }
        }
    }
}

extension Dictionary where Key == String, Value == ElementType {
    public static var acknowledge: [String: ElementType] {
        ["acknowledge": .bool(true)]
    }
}

extension Message {
    internal enum Publisher: Equatable {
        internal enum Output: Equatable {
            case client(Message.Client.Output)
            case publish(Publish)

            internal func toMessage() -> Message {
                switch self {
                case let .client(client): return client.toMessage()
                case let .publish(publish): return .publish(publish)
                }
            }
        }

        internal enum Input: Equatable {
            case client(Message.Client.Input)
            case published(Published)

            internal init?(from message: Message) {
                switch message {
                case let .published(published): self = .published(published)
                default:
                    guard let client = Message.Client.Input.init(from: message) else { return nil }
                    self = .client(client)
                }
            }
        }
    }

    internal enum Subscriber: Equatable {
        internal enum Output: Equatable {
            case client(Message.Client.Output)
            case subscribe(Subscribe)
            case unsubscribe(Unsubscribe)

            internal func toMessage() -> Message {
                switch self {
                case let .client(client): return client.toMessage()
                case let .subscribe(subscribe): return .subscribe(subscribe)
                case let .unsubscribe(unsubscribe): return .unsubscribe(unsubscribe)
                }
            }
        }

        internal enum Input: Equatable {
            case client(Message.Client.Input)
            case subscribed(Subscribed)
            case unsubscribed(Unsubscribed)
            case event(Event)

            internal init?(from message: Message) {
                switch message {
                case let .subscribed(subscribed): self = .subscribed(subscribed)
                case let .unsubscribed(unsubscribed): self = .unsubscribed(unsubscribed)
                case let .event(event): self = .event(event)
                default:
                    guard let client = Message.Client.Input.init(from: message) else { return nil }
                    self = .client(client)
                }
            }
        }
    }

    internal enum Caller: Equatable {
        internal enum Output {
            case client(Message.Client.Output)
            case call(Call)

            internal func toMessage() -> Message {
                switch self {
                case let .client(client): return client.toMessage()
                case let .call(call): return .call(call)
                }
            }
        }

        internal enum Input: Equatable {
            case client(Message.Client.Input)
            case result(Result)

            internal init?(from message: Message) {
                switch message {
                case let .result(result): self = .result(result)
                default:
                    guard let client = Message.Client.Input.init(from: message) else { return nil }
                    self = .client(client)
                }
            }
        }
    }

    internal enum Callee: Equatable {
        internal enum Output: Equatable {
            case client(Message.Client.Output)
            case error(WampError)
            case register(Register)
            case unregister(Unregister)
            case yield(Yield)

            internal func toMessage() -> Message {
                switch self {
                case let .client(client): return client.toMessage()
                case let .error(error): return .error(error)
                case let .register(register): return .register(register)
                case let .unregister(unregister): return .unregister(unregister)
                case let .yield(yield): return .yield(yield)
                }
            }
        }

        internal enum Input: Equatable {
            case client(Message.Client.Input)
            case registered(Registered)
            case unregistered(Unregistered)
            case invocation(Invocation)

            internal init?(from message: Message) {
                switch message {
                case let .registered(registered): self = .registered(registered)
                case let .unregistered(unregistered): self = .unregistered(unregistered)
                case let .invocation(invocation): self = .invocation(invocation)
                default:
                    guard let client = Message.Client.Input.init(from: message) else { return nil }
                    self = .client(client)
                }
            }
        }
    }
}
