import WebKit

public extension WKUserContentController {

    func add<T>(_ scriptMessageHandler: ScriptMessageHandler<T>) {
        add(scriptMessageHandler, name: scriptMessageHandler.name)
    }
}
