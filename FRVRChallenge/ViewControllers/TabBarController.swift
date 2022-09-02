import UIKit
import FRVRSDK

class TabBarController: UITabBarController {

    override func viewDidLoad() {

        super.viewDidLoad()

        tabBar.backgroundColor = .systemGroupedBackground
        tabBar.barTintColor = .systemGroupedBackground

        viewControllers = [
            NativeLogViewController(),
            WebViewController(pageName: "LocalNotification"),
            WebViewController(pageName: "AppLifecycle")
        ]
    }
}
