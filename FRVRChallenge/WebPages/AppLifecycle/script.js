function formatDateTime(datetime) {
    let options = {
        dateStyle: 'short',
        timeStyle: 'medium',
        hour12: false
    }
    return new Date(datetime).toLocaleString(window.navigator.language, options)
}

function recentClass(datetime) {
    return (new Date() - new Date(datetime) <= 3000) ? "recent" : ""
}

function listAppEvents(events) {

    let rows = events.map(item => `
        <tr class='${recentClass(item.datetime)}'>
            <td class='center nowrap'>${formatDateTime(item.datetime)}</td>
            <td>${item.name}</td>
        </tr>
    `).join('')

    document.getElementById("events").innerHTML = rows
}


window.addEventListener('load', () => {

    frvr.registerAppEventsHandler(listAppEvents)
})
