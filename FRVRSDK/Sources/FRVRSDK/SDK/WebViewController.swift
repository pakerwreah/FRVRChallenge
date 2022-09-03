import UIKit
import WebKit

private enum PageLifecycleEvent: String, Decodable {
    case didLoad
    // prepared for adding more events
}

private struct PageLifecyclePayload: Decodable {
    let event: PageLifecycleEvent
}

open class WebViewController: UIViewController {

    public let pageName: String
    public let webView: WKWebView

    private let pageLifecycleHandler: ScriptMessageHandler<PageLifecyclePayload>

    public init(pageName: String, configuration: WKWebViewConfiguration? = nil) {

        self.pageName = pageName
        self.webView = configuration.map { WKWebView(frame: .zero, configuration: $0) } ?? WKWebView()

        self.pageLifecycleHandler = ScriptMessageHandler(name: "PageLifecycle")

        super.init(nibName: nil, bundle: nil)

        webView.uiDelegate = self

        pageLifecycleHandler.onSuccess = { [weak self] payload in
            self?.webPageDidReceiveEvent(event: payload.event)
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = webView
    }

    open override func viewDidLoad() {

        super.viewDidLoad()

        let userContentController = webView.configuration.userContentController

        userContentController.add(pageLifecycleHandler)

        let sdkBundleURL = Bundle.module.resourceURL!.absoluteURL

        let script = WKUserScript(
            source: try! String(contentsOf: sdkBundleURL.appendingPathComponent("FRVR.js")),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )

        userContentController.addUserScript(script)

        webPageLoad()
    }

    private func webPageDidReceiveEvent(event: PageLifecycleEvent) {

        switch event {
        case .didLoad:
            webPageDidLoad()
        }
    }

    open func webPageLoad() {

        let appBundleURL = Bundle.main.resourceURL!.absoluteURL

        let html = appBundleURL.appendingPathComponent("WebPages/\(pageName)/index.html")
        assert(FileManager.default.fileExists(atPath: html.path), "Missing \"\(pageName)\" HTML file")

        let webPages = appBundleURL.appendingPathComponent("WebPages", isDirectory: true)

        webView.loadFileURL(html, allowingReadAccessTo: webPages)
    }

    open func webPageDidLoad() {
        Logger.log(tag: pageName, "didLoad")
    }
}

extension WebViewController: WKUIDelegate {

    public func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)

        alertController.addAction(
            UIAlertAction(title: "OK", style: .cancel) { _ in completionHandler() }
        )

        present(alertController, animated: true)
    }
}
