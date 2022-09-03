function sendText() {

    let textarea = document.getElementById("log-text")
    let text = textarea.value

    if(!text.trim().length) return;

    frvr.postMessage('NativeLog', text)

    textarea.value = ""
}
