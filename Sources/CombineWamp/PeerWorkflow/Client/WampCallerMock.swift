// Copyright © 2023 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation

class WampCallerMock: WampCallerProtocol {
    var onReceiveCall: (CombineWamp.URI, [CombineWamp.ElementType]?, [String : CombineWamp.ElementType]?) -> Publishers.Promise<CombineWamp.Message.Result, CombineWamp.ModuleError> = { _, _, _ in fatalError() }
        
    func call(procedure: CombineWamp.URI, positionalArguments: [CombineWamp.ElementType]?, namedArguments: [String : CombineWamp.ElementType]?) -> Publishers.Promise<CombineWamp.Message.Result, CombineWamp.ModuleError> {
        onReceiveCall(procedure, positionalArguments, namedArguments)
    }
}
