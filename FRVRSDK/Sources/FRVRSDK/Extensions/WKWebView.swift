import WebKit

public extension WKWebView {

    func postMessage<T: Encodable>(_ handlerName: String, _ message: T) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(message)

            guard let json = String(data: data, encoding: .utf8) else { return }

            DispatchQueue.main.async {
                self.evaluateJavaScript("frvr.didReceiveMessage('\(handlerName)', \(json))")
            }
        } catch {
            Logger.error(tag: handlerName, "Unable to encode: \(message)")
        }
    }
}
