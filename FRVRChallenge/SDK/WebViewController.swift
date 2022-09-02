import UIKit
import WebKit

private enum PageLifecycleEvent: String, Decodable {
    case didLoad
    // prepared for adding more events
}

private struct PageLifecyclePayload: Decodable {
    let event: PageLifecycleEvent
}

class WebViewController: UIViewController {

    private let page: String
    private let pageLifecycle = ScriptMessageHandler<PageLifecyclePayload>(name: "PageLifecycle")

    let webView = WKWebView()

    init(page: String) {

        self.page = page

        super.init(nibName: nil, bundle: nil)

        pageLifecycle.onSuccess = { [weak self] payload in
            self?.webPageDidReceiveEvent(event: payload.event)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        let userContentController = webView.configuration.userContentController

        userContentController.add(pageLifecycle)

        let bundleURL = Bundle.main.resourceURL!.absoluteURL

        let script = WKUserScript(
            source: try! String(contentsOf: bundleURL.appendingPathComponent("FRVR.js")),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )

        userContentController.addUserScript(script)

        let html = bundleURL.appendingPathComponent("WebPages/\(page)/index.html")
        let webPages = bundleURL.appendingPathComponent("WebPages", isDirectory: true)
        webView.loadFileURL(html, allowingReadAccessTo: webPages)
    }

    private func webPageDidReceiveEvent(event: PageLifecycleEvent) {

        switch event {
        case .didLoad:
            webPageDidLoad()
        }
    }

    func webPageDidLoad() {
        Logger.log(tag: "PageLifecycle", "didLoad")
    }
}
