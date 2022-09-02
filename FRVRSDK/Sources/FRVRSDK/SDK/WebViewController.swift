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

    private let pageName: String
    private let pageLifecycleHandler: ScriptMessageHandler<PageLifecyclePayload>

    public let webView: WKWebView

    public init(pageName: String) {

        self.pageName = pageName
        self.pageLifecycleHandler = ScriptMessageHandler(name: "PageLifecycle")
        self.webView = WKWebView()

        super.init(nibName: nil, bundle: nil)

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

    public override func viewDidLoad() {

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

        webPageLoadFileURL()
    }

    private func webPageDidReceiveEvent(event: PageLifecycleEvent) {

        switch event {
        case .didLoad:
            webPageDidLoad()
        }
    }

    open func webPageLoadFileURL() {

        let appBundleURL = Bundle.main.resourceURL!.absoluteURL
        let html = appBundleURL.appendingPathComponent("WebPages/\(pageName)/index.html")
        let webPages = appBundleURL.appendingPathComponent("WebPages", isDirectory: true)

        webView.loadFileURL(html, allowingReadAccessTo: webPages)
    }

    open func webPageDidLoad() {
        Logger.log(tag: "PageLifecycle", "didLoad")
    }
}
