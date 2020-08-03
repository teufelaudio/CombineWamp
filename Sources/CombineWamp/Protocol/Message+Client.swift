import Foundation

/// Clients messages
extension Message {
    internal enum Publisher: Equatable {
        internal enum Output: Equatable {
            case hello(Hello)
            case goodbye(Goodbye)
            case publish(Publish)

            internal func toMessage() -> Message {
                switch self {
                case let .hello(hello): return .hello(hello)
                case let .goodbye(goodbye): return .goodbye(goodbye)
                case let .publish(publish): return .publish(publish)
                }
            }
        }

        internal enum Input: Equatable {
            case welcome(Welcome)
            case abort(Abort)
            case goodbye(Goodbye)
            case error(WampError)
            case published(Published)

            internal init?(from message: Message) {
                switch message {
                case let .welcome(welcome): self = .welcome(welcome)
                case let .abort(abort): self = .abort(abort)
                case let .goodbye(goodbye): self = .goodbye(goodbye)
                case let .error(error): self = .error(error)
                case let .published(published): self = .published(published)
                default: return nil
                }
            }
        }
    }

    internal enum Subscriber: Equatable {
        internal enum Output: Equatable {
            case hello(Hello)
            case goodbye(Goodbye)
            case subscribe(Subscribe)
            case unsubscribe(Unsubscribe)

            internal func toMessage() -> Message {
                switch self {
                case let .hello(hello): return .hello(hello)
                case let .goodbye(goodbye): return .goodbye(goodbye)
                case let .subscribe(subscribe): return .subscribe(subscribe)
                case let .unsubscribe(unsubscribe): return .unsubscribe(unsubscribe)
                }
            }
        }

        internal enum Input: Equatable {
            case welcome(Welcome)
            case abort(Abort)
            case goodbye(Goodbye)
            case error(WampError)
            case subscribed(Subscribed)
            case unsubscribed(Unsubscribed)
            case event(Event)

            internal init?(from message: Message) {
                switch message {
                case let .welcome(welcome): self = .welcome(welcome)
                case let .abort(abort): self = .abort(abort)
                case let .goodbye(goodbye): self = .goodbye(goodbye)
                case let .error(error): self = .error(error)
                case let .subscribed(subscribed): self = .subscribed(subscribed)
                case let .unsubscribed(unsubscribed): self = .unsubscribed(unsubscribed)
                case let .event(event): self = .event(event)
                default: return nil
                }
            }
        }
    }

    internal enum Caller: Equatable {
        internal enum Output {
            case hello(Hello)
            case goodbye(Goodbye)
            case call(Call)

            internal func toMessage() -> Message {
                switch self {
                case let .hello(hello): return .hello(hello)
                case let .goodbye(goodbye): return .goodbye(goodbye)
                case let .call(call): return .call(call)
                }
            }
        }

        internal enum Input: Equatable {
            case welcome(Welcome)
            case abort(Abort)
            case goodbye(Goodbye)
            case error(WampError)
            case result(Result)

            internal init?(from message: Message) {
                switch message {
                case let .welcome(welcome): self = .welcome(welcome)
                case let .abort(abort): self = .abort(abort)
                case let .goodbye(goodbye): self = .goodbye(goodbye)
                case let .error(error): self = .error(error)
                case let .result(result): self = .result(result)
                default: return nil
                }
            }
        }
    }

    internal enum Callee: Equatable {
        internal enum Output: Equatable {
            case hello(Hello)
            case goodbye(Goodbye)
            case error(WampError)
            case register(Register)
            case unregister(Unregister)
            case yield(Yield)

            internal func toMessage() -> Message {
                switch self {
                case let .hello(hello): return .hello(hello)
                case let .goodbye(goodbye): return .goodbye(goodbye)
                case let .error(error): return .error(error)
                case let .register(register): return .register(register)
                case let .unregister(unregister): return .unregister(unregister)
                case let .yield(yield): return .yield(yield)
                }
            }
        }

        internal enum Input: Equatable {
            case welcome(Welcome)
            case abort(Abort)
            case goodbye(Goodbye)
            case error(WampError)
            case registered(Registered)
            case unregistered(Unregistered)
            case invocation(Invocation)

            internal init?(from message: Message) {
                switch message {
                case let .welcome(welcome): self = .welcome(welcome)
                case let .abort(abort): self = .abort(abort)
                case let .goodbye(goodbye): self = .goodbye(goodbye)
                case let .error(error): self = .error(error)
                case let .registered(registered): self = .registered(registered)
                case let .unregistered(unregistered): self = .unregistered(unregistered)
                case let .invocation(invocation): self = .invocation(invocation)
                default: return nil
                }
            }
        }
    }
}
