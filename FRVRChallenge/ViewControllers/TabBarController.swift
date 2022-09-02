import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {

        super.viewDidLoad()

        tabBar.backgroundColor = .systemGroupedBackground
        tabBar.barTintColor = .systemGroupedBackground

        viewControllers = [
            NativeLogViewController(),
            WebViewController(page: "LocalNotification"),
            WebViewController(page: "AppLifecycle")
        ]
    }
}
