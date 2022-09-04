class FRVR {

    constructor() {

        this.nativeMessageHandlers = {}

        window.addEventListener('load', () => {
            this.postMessage('PageLifecycle', { event: 'didLoad' })
        })
    }

    postMessage(handlerName, message = {}) {

        let handler = window.webkit.messageHandlers[handlerName]

        if(handler) {
            handler.postMessage(message)
        } else {
            console.error(`Message handler "${handlerName}" not found`)
        }
    }

    didReceiveMessage(handlerName, message) {

        let handler = this.nativeMessageHandlers[handlerName]

        if(handler) {
            handler(message)
        } else {
            console.error(`Native message handler "${handlerName}" not found`)
        }
    }

    registerMessageHandler(handlerName, handler) {
        this.nativeMessageHandlers[handlerName] = handler
    }

    // MARK: - Native Logs

    nativeLog(text) {
        this.postMessage('NativeLog', text)
    }

    // MARK: - Local Notifications

    listPendingNotifications() {
        this.postMessage('ListNotifications')
    }

    registerPendingNotificationsHandler(handler) {
        this.registerMessageHandler('ListNotifications', handler)
    }

    deleteNotifications(ids) {
        this.postMessage('DeleteNotifications', ids)
    }

    // MARK: - Application Lifecycle

    registerAppEventsHandler(handler) {
        this.registerMessageHandler('ListAppEvents', handler)
    }
}

const frvr = new FRVR()
