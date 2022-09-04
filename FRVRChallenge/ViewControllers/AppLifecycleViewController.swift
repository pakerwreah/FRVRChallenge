import UIKit
import FRVRSDK

private struct AppEvent: Codable {
    let datetime: Date
    let name: String
}

final class AppLifecycleViewController: WebViewController {

    init() {

        super.init(pageName: "AppLifecycle")

        tabBarItem = UITabBarItem(
            title: "Application Lifecycle",
            image: UIImage(systemName: "clock.arrow.2.circlepath"),
            tag: 0
        )

        addObserver(for: UIApplication.willTerminateNotification)
        addObserver(for: UIApplication.willResignActiveNotification)
        addObserver(for: UIApplication.willEnterForegroundNotification)
        addObserver(for: UIApplication.didEnterBackgroundNotification)
        addObserver(for: UIApplication.didBecomeActiveNotification)
        addObserver(for: UIApplication.didFinishLaunchingNotification)
    }

    private func addObserver(for name: NSNotification.Name) {

        NotificationCenter.default.addObserver(self, selector: #selector(listAppEvents), name: name, object: nil)
    }

    @objc private func listAppEvents(_ notification: Notification? = nil) {

        var events: [AppEvent] = []

        do {
            if let data = UserDefaults.standard.data(forKey: pageName) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                events = try decoder.decode([AppEvent].self, from: data)
            }
        } catch {
            Logger.error(tag: pageName, String(describing: error))
        }

        if let notification = notification {
            events.insert(AppEvent(datetime: Date(), name: notification.name.description), at: 0)
            events = Array(events.prefix(20))
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let encodedData = try encoder.encode(events)
                UserDefaults.standard.set(encodedData, forKey: pageName)
            } catch {
                Logger.error(tag: pageName, String(describing: error))
            }
        }

        if notification == nil || notification?.name == UIApplication.willEnterForegroundNotification {
            webView.postMessage("ListAppEvents", events)
        }
    }

    override func webPageDidLoad() {

        super.webPageDidLoad()

        listAppEvents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NSNotification.Name {

    var description: String {
        switch self {
        case UIApplication.willTerminateNotification:
            return "Will terminate"
        case UIApplication.willResignActiveNotification:
            return "Will resign active"
        case UIApplication.willEnterForegroundNotification:
            return "Will enter foreground"
        case UIApplication.didEnterBackgroundNotification:
            return "Did enter background"
        case UIApplication.didBecomeActiveNotification:
            return "Did become active"
        case UIApplication.didFinishLaunchingNotification:
            return "Did finish launching"
        default:
            return "Unknown"
        }
    }
}
