import Foundation

public struct WampRouter: WampPeer {
    public init(url: URL) {
        self.url = url
    }
    
    public let url: URL
}
