import UIKit

private struct NativeLogPayload: Decodable {
    let text: String
}

final class NativeLogViewController: WebViewController {

    private let nativeLog = ScriptMessageHandler<NativeLogPayload>(name: "NativeLog")

    init() {

        super.init(page: "NativeLog")

        tabBarItem = UITabBarItem(title: "Native Logs", image: UIImage(systemName: "doc.plaintext"), tag: 0)

        nativeLog.onSuccess = { payload in
            Logger.log(tag: "NativeLog", payload.text)
        }

        webView.configuration.userContentController.add(nativeLog)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
