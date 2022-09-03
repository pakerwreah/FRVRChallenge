import WebKit

public struct ScriptMessageHandlerError: LocalizedError {
    let reason: String
    let details: String

    public var errorDescription: String? { String(describing: self) }
}

public class ScriptMessageHandler<Payload: Decodable>: NSObject, WKScriptMessageHandler {

    public let name: String

    public lazy var onSuccess: (Payload) -> Void = { [weak self] _ in
        guard let self = self else { return }
        assertionFailure("No success handler configured for \(self.name)")
    }

    public lazy var onError: (ScriptMessageHandlerError) -> Void = { [weak self] error in
        guard let self = self else { return }
        Logger.error(tag: self.name, error.localizedDescription)
    }

    public init(name: String) {

        self.name = name

        super.init()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        guard message.name == name else { return }

        guard JSONSerialization.isValidJSONObject(message.body) else {
            onError(.init(reason: "Invalid JSON", details: "\(message.body)"))
            return
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: message.body, options: [])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let model = try decoder.decode(Payload.self, from: data)
            onSuccess(model)
        } catch {
            onError(.init(reason: error.localizedDescription, details: "\(message.body)"))
        }
    }
}

public extension WKUserContentController {

    func add<T>(_ scriptMessageHandler: ScriptMessageHandler<T>) {
        add(scriptMessageHandler, name: scriptMessageHandler.name)
    }
}
