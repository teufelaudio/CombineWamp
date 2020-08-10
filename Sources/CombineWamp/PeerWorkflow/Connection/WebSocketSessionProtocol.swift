import CombineWebSocket
import Foundation

public protocol WebSocketSessionProtocol {
    func webSocket(with url: URL) -> WebSocket
    func webSocket(with urlRequest: URLRequest) -> WebSocket
    func webSocket(with url: URL, protocols: [String]) -> WebSocket
}

extension URLSession: WebSocketSessionProtocol { }
