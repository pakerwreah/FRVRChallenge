function sendText() {

    let textarea = document.getElementById("text")
    let text = textarea.value

    if(!text.trim().length) return;

    frvr.nativeLog(text)

    textarea.value = ""
}

window.addEventListener('load', () => {

    document.getElementById("send").onclick = sendText
})
