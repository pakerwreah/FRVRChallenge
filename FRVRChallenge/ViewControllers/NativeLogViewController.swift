import UIKit
import FRVRSDK

private struct NativeLogPayload: Decodable {
    let text: String
}

final class NativeLogViewController: WebViewController {

    private let nativeLogHandler: ScriptMessageHandler<NativeLogPayload>

    init() {

        nativeLogHandler = ScriptMessageHandler(name: "NativeLog")

        super.init(pageName: "NativeLog")

        tabBarItem = UITabBarItem(title: "Native Logs", image: UIImage(systemName: "doc.plaintext"), tag: 0)

        nativeLogHandler.onSuccess = { payload in
            Logger.log(tag: "NativeLog", payload.text)
        }

        webView.configuration.userContentController.add(nativeLogHandler)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
