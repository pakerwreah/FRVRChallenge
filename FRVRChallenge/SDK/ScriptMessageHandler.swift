import WebKit

enum ScriptMessageHandlerError: Error {
    case invalidJSON(String)
    case decodeError(String)
}

class ScriptMessageHandler<ScriptMessageModel: Decodable>: NSObject, WKScriptMessageHandler {

    typealias Handler = (Result<ScriptMessageModel, ScriptMessageHandlerError>) -> Void

    let name: String
    var handler: Handler?

    init(name: String) {

        self.name = name

        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        guard message.name == name else { return }

        guard let handler = handler else {
            assertionFailure("No script message handler configured for \(name)")
            return
        }

        do {
            guard JSONSerialization.isValidJSONObject(message.body) else {
                handler(.failure(.invalidJSON("\(message.body)")))
                return
            }
            let data = try JSONSerialization.data(withJSONObject: message.body, options: [])
            let model = try JSONDecoder().decode(ScriptMessageModel.self, from: data)
            handler(.success(model))
        } catch {
            handler(.failure(.decodeError(error.localizedDescription)))
        }
    }
}

extension WKUserContentController {

    func add<T>(_ scriptMessageHandler: ScriptMessageHandler<T>) {
        add(scriptMessageHandler, name: scriptMessageHandler.name)
    }
}
