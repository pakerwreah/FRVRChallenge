import UIKit
import FRVRSDK
import UserNotifications

private struct LocalNotification: Codable {
    let id: Int
    let datetime: Date
    let title: String
    let message: String
}

final class LocalNotificationViewController: WebViewController {

    private let scheduleNotificationHandler: ScriptMessageHandler<LocalNotification>
    private let listNotificationsHandler: ScriptMessageHandler<Empty>
    private let deleteNotificationsHandler: ScriptMessageHandler<[Int]>

    init() {

        scheduleNotificationHandler = ScriptMessageHandler(name: "ScheduleNotification")
        listNotificationsHandler = ScriptMessageHandler(name: "ListNotifications")
        deleteNotificationsHandler = ScriptMessageHandler(name: "DeleteNotifications")

        super.init(pageName: "LocalNotification")

        tabBarItem = UITabBarItem(
            title: "Local Notifications",
            image: UIImage(systemName: "envelope"),
            tag: 0
        )

        scheduleNotificationHandler.onSuccess = { [weak self] payload in
            self?.scheduleNotification(payload)
        }

        listNotificationsHandler.onSuccess = { [weak self] _ in
            self?.listPendingNotifications()
        }

        deleteNotificationsHandler.onSuccess = { [weak self] ids in
            self?.deleteNotifications(ids)
        }

        webView.configuration.userContentController.add(scheduleNotificationHandler)
        webView.configuration.userContentController.add(listNotificationsHandler)
        webView.configuration.userContentController.add(deleteNotificationsHandler)
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        requestAuthorization()

        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    override func webPageDidLoad() {

        super.webPageDidLoad()

        listPendingNotifications()
    }

    private func scheduleNotification(_ payload: LocalNotification) {

        Logger.log(tag: pageName, "\(payload)")

        let content = UNMutableNotificationContent()
        content.title = payload.title
        content.body = payload.message
        content.sound = .default

        let components = Calendar.utc.dateComponents([.year, .month, .day, .hour, .minute], from: payload.datetime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: payload.id.description,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)

        listPendingNotifications()
    }

    private func listPendingNotifications() {

        UNUserNotificationCenter.current().getPendingNotificationRequests {
            [pageName, webView, handlerName = listNotificationsHandler.name] requests in

            let notifications: [LocalNotification] = requests.compactMap { req in
                guard
                    let trigger = req.trigger as? UNCalendarNotificationTrigger,
                    let datetime = Calendar.utc.date(from: trigger.dateComponents),
                    let id = Int(req.identifier)
                else {
                    Logger.error(
                        tag: pageName,
                        "Could not parse notification with identifier: \(req.identifier), date: \(req.trigger!)"
                    )
                    return nil
                }

                return LocalNotification(
                    id: id,
                    datetime: datetime,
                    title: req.content.title,
                    message: req.content.body
                )
            }

            webView.postMessage(handlerName, notifications)
        }
    }

    private func deleteNotifications(_ ids: [Int]) {

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids.map(String.init))

        listPendingNotifications()
    }

    private func requestAuthorization() {

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [pageName] success, error in
            if let error = error {
                Logger.error(tag: pageName, String(describing: error))
            } else if !success {
                Logger.log(tag: pageName, "⚠️ Notifications not allowed!")
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Calendar {

    static var utc: Self {
        var calendar = Calendar.current
        calendar.timeZone = .init(identifier: "UTC")!
        return calendar
    }
}
