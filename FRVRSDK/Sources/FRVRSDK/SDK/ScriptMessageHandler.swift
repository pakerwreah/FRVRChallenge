import WebKit

public struct ScriptMessageHandlerError: LocalizedError {
    let reason: String
    let details: String

    public var errorDescription: String? { String(describing: self) }
}

public struct Empty: Decodable {}

public class ScriptMessageHandler<Payload: Decodable>: NSObject, WKScriptMessageHandler {

    public let name: String

    public lazy var onSuccess: (Payload) -> Void = { [weak self] _ in
        guard let self = self else { return }
        assertionFailure("No success handler configured for \(self.name)")
    }

    public lazy var onError: (ScriptMessageHandlerError) -> Void = { [weak self] error in
        guard let self = self else { return }
        Logger.error(tag: self.name, String(describing: error))
    }

    public init(name: String) {

        self.name = name

        super.init()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        guard message.name == name else { return }

        if let payload = message.body as? Payload {
            onSuccess(payload)
            return
        }

        guard JSONSerialization.isValidJSONObject(message.body) else {
            onError(.init(reason: "Invalid JSON", details: "\(message.body)"))
            return
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: message.body, options: [])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let payload = try decoder.decode(Payload.self, from: data)
            onSuccess(payload)
        } catch {
            onError(.init(reason: String(describing: error), details: "\(message.body)"))
        }
    }
}

public extension WKUserContentController {

    func add<T>(_ scriptMessageHandler: ScriptMessageHandler<T>) {
        add(scriptMessageHandler, name: scriptMessageHandler.name)
    }
}
