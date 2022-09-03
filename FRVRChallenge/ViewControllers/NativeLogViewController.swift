import UIKit
import FRVRSDK

private struct NativeLog: Decodable {
    let text: String
}

final class NativeLogViewController: WebViewController {

    private let nativeLogHandler: ScriptMessageHandler<NativeLog>

    init() {

        let pageName = "NativeLog"

        nativeLogHandler = ScriptMessageHandler(name: pageName)

        super.init(pageName: pageName)

        tabBarItem = UITabBarItem(title: "Native Logs", image: UIImage(systemName: "doc.plaintext"), tag: 0)

        nativeLogHandler.onSuccess = { payload in
            Logger.log(tag: pageName, payload.text)
        }

        webView.configuration.userContentController.add(nativeLogHandler)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
