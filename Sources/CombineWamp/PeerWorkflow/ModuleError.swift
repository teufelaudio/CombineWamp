import Foundation

public enum ModuleError: Error {
    case wampError(WampError)
    case serializingError(Error)
    case deserializingError(Error)
    case unknownError(Error)
    case sessionIsNotValid
    case abort(Message.Abort)
}
