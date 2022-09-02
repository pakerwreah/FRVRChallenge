import WebKit

enum ScriptMessageHandlerError: Error {
    case invalidJSON(String)
    case decodeError(String)
}

class ScriptMessageHandler<ScriptMessageModel: Decodable>: NSObject, WKScriptMessageHandler {

    typealias Handler = (Result<ScriptMessageModel, ScriptMessageHandlerError>) -> Void

    let name: String

    lazy var onSuccess: (ScriptMessageModel) -> Void = { [weak self] _ in
        guard let self = self else { return }
        assertionFailure("No success handler configured for \(self.name)")
    }

    lazy var onError: (ScriptMessageHandlerError) -> Void = { [weak self] error in
        assertionFailure(error.localizedDescription)
    }

    init(name: String) {

        self.name = name

        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        guard message.name == name else { return }

        do {
            guard JSONSerialization.isValidJSONObject(message.body) else {
                onError(.invalidJSON("\(message.body)"))
                return
            }
            let data = try JSONSerialization.data(withJSONObject: message.body, options: [])
            let model = try JSONDecoder().decode(ScriptMessageModel.self, from: data)
            onSuccess(model)
        } catch {
            onError(.decodeError(error.localizedDescription))
        }
    }
}

extension WKUserContentController {

    func add<T>(_ scriptMessageHandler: ScriptMessageHandler<T>) {
        add(scriptMessageHandler, name: scriptMessageHandler.name)
    }
}
