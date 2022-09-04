import UIKit
import FRVRSDK

final class NativeLogViewController: WebViewController {

    private let nativeLogHandler: ScriptMessageHandler<String>

    init() {

        let pageName = "NativeLog"

        nativeLogHandler = ScriptMessageHandler(name: pageName)

        super.init(pageName: pageName)

        tabBarItem = UITabBarItem(
            title: "Native Logs",
            image: UIImage(systemName: "doc.plaintext"),
            tag: 0
        )

        nativeLogHandler.onSuccess = { text in
            Logger.log(tag: pageName, text)
        }

        webView.configuration.userContentController.add(nativeLogHandler)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
