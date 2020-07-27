import Foundation

/// Routers messages
extension Message {
    internal enum Broker {
        internal enum Output {
            case welcome(Welcome)
            case abort(Abort)
            case goodbye(Goodbye)
            case error(WampError)
            case published(Published)
            case subscribed(Subscribed)
            case unsubscribed(Unsubscribed)
            case event(Event)

            internal func toMessage() -> Message {
                switch self {
                case let .welcome(welcome): return .welcome(welcome)
                case let .abort(abort): return .abort(abort)
                case let .goodbye(goodbye): return .goodbye(goodbye)
                case let .error(error): return .error(error)
                case let .published(published): return .published(published)
                case let .subscribed(subscribed): return .subscribed(subscribed)
                case let .unsubscribed(unsubscribed): return .unsubscribed(unsubscribed)
                case let .event(event): return .event(event)
                }
            }
        }

        internal enum Input {
            case hello(Hello)
            case abort(Abort)
            case goodbye(Goodbye)
            case publish(Publish)
            case subscribe(Subscribe)
            case unsubscribe(Unsubscribe)

            internal init?(from message: Message) {
                switch message {
                case let .hello(hello): self = .hello(hello)
                case let .abort(abort): self = .abort(abort)
                case let .goodbye(goodbye): self = .goodbye(goodbye)
                case let .publish(publish): self = .publish(publish)
                case let .subscribe(subscribe): self = .subscribe(subscribe)
                case let .unsubscribe(unsubscribe): self = .unsubscribe(unsubscribe)
                default: return nil
                }
            }
        }
    }

    internal enum Dealer {
        internal enum Output {
            case welcome(Welcome)
            case abort(Abort)
            case goodbye(Goodbye)
            case error(WampError)
            case result(Result)
            case registered(Registered)
            case unregistered(Unregistered)
            case invocation(Invocation)

            internal func toMessage() -> Message {
                switch self {
                case let .welcome(welcome): return .welcome(welcome)
                case let .abort(abort): return .abort(abort)
                case let .goodbye(goodbye): return .goodbye(goodbye)
                case let .error(error): return .error(error)
                case let .result(result): return .result(result)
                case let .registered(registered): return .registered(registered)
                case let .unregistered(unregistered): return .unregistered(unregistered)
                case let .invocation(invocation): return .invocation(invocation)
                }
            }
        }

        internal enum Input {
            case hello(Hello)
            case abort(Abort)
            case goodbye(Goodbye)
            case error(WampError)
            case call(Call)
            case register(Register)
            case unregister(Unregister)
            case yield(Yield)

            internal init?(from message: Message) {
                switch message {
                case let .hello(hello): self = .hello(hello)
                case let .abort(abort): self = .abort(abort)
                case let .goodbye(goodbye): self = .goodbye(goodbye)
                case let .error(error): self = .error(error)
                case let .call(call): self = .call(call)
                case let .register(register): self = .register(register)
                case let .unregister(unregister): self = .unregister(unregister)
                case let .yield(yield): self = .yield(yield)
                default: return nil
                }
            }
        }
    }
}
