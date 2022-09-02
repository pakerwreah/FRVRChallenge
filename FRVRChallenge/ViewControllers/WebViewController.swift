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
    private let lifecycle = ScriptMessageHandler<PageLifecyclePayload>(name: "PageLifecycle")
    private let webView = WKWebView()

    init(page: String) {

        self.page = page

        super.init(nibName: nil, bundle: nil)

        lifecycle.handler = { [weak self] result in
            switch result {
            case .success(let payload):
                self?.webPageDidReceiveEvent(event: payload.event)

            case .failure(let error):
                assertionFailure("Unable to decode message, error: \(error)")
            }
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

        webView.configuration.userContentController.add(lifecycle)

        let bundleURL = Bundle.main.resourceURL!.absoluteURL
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
        print("Success: didLoad")
    }
}
