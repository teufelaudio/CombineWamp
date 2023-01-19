// Copyright © 2023 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation

public class WampCallerMock: WampCallerProtocol {

    public var onReceiveCall: (URI, [ElementType]?, [String : ElementType]?) -> Publishers.Promise<Message.Result, ModuleError> = { _, _, _ in fatalError() }

    public init() {
    }

    public func call(procedure: URI, positionalArguments: [ElementType]?, namedArguments: [String : ElementType]?) -> Publishers.Promise<Message.Result, ModuleError> {
        onReceiveCall(procedure, positionalArguments, namedArguments)
    }
}
