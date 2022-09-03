class FRVR {

    constructor() {
        window.addEventListener('load', (event) => {
            this.postMessage('PageLifecycle', { event: 'didLoad' })
        })
    }

    postMessage(handlerID, message = {}) {
        let handler = window.webkit.messageHandlers[handlerID]
        if(handler) {
            handler.postMessage(message)
        } else {
            console.error(`Message handler "${handlerID}" not found`)
        }
    }
}

const frvr = new FRVR()
