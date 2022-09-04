function futureDateTime() {
    let date = new Date()
    date.setSeconds(0)
    date.setMilliseconds(0)
    date.setMinutes(date.getMinutes() + 1)
    return date
}

function futureISODateTimeString() {
    let tzoffset = (new Date()).getTimezoneOffset() * 60000
    let date = new Date(futureDateTime().getTime() - tzoffset)
    return date.toISOString().substring(0, 16)
}

function scheduleNotification() {

    let input_datetime = document.getElementById("datetime")
    let input_id = document.getElementById("id")
    let input_title = document.getElementById("title")
    let textarea_message = document.getElementById("message")

    let payload = {
        datetime: input_datetime.value.trim(),
        id: input_id.value.trim(),
        title: input_title.value.trim(),
        message: textarea_message.value.trim()
    }

    if (
          !payload.datetime.length
       || !payload.id.length
       || !payload.title.length
       || !payload.message.length
    ) {
        alert("All fields are required!")
        return;
    }

    if (new Date(payload.datetime) < futureDateTime()) {
        alert("Display time must be in the future")
        return;
    }

    payload.id = parseInt(payload.id)

    if (isNaN(payload.id)) {
        alert("Notification ID must be an integer")
        return;
    }

    payload.datetime += ":00Z"

    frvr.postMessage('ScheduleNotification', payload)

    input_datetime.value = futureISODateTimeString()
    input_id.value = ""
    input_title.value = ""
    textarea_message.value = ""
}

function formatDateTime(datetime) {
    let options = {
        dateStyle: 'short',
        timeStyle: 'short',
        hour12: false,
        timeZone: 'UTC'
    }
    return new Date(datetime).toLocaleString(window.navigator.language, options)
}

function listPendingNotifications(notifications) {

    let rows = notifications.map(item => `
        <tr>
            <td><input onchange='checkDeleteButton()' type='checkbox' value='${item.id}' /></td>
            <td class='center'>${item.id}</td>
            <td class='center nowrap'>${formatDateTime(item.datetime)}</td>
            <td class='nowrap'>${item.title}</td>
            <td>${item.message}</td>
        </tr>
    `).join('')

    document.getElementById("notifications").innerHTML = rows

    checkDeleteButton()
}

function checkDeleteButton() {

    let checked = document.querySelectorAll('input[type=checkbox]:checked').length
    document.getElementById('delete').style.visibility = checked ? 'visible' : 'hidden'
}

function deleteNotifications() {

    let items = Array.from(document.querySelectorAll('input[type=checkbox]:checked'))
    let ids = items.map(it => parseInt(it.value))

    frvr.deleteNotifications(ids)
}

function refreshNotifications() {

    frvr.listPendingNotifications()
}

window.addEventListener('load', () => {

    document.getElementById("datetime").value = futureISODateTimeString()
    document.getElementById("schedule").onclick = scheduleNotification
    document.getElementById("refresh").onclick = refreshNotifications
    document.getElementById("delete").onclick = deleteNotifications

    frvr.registerPendingNotificationsHandler(listPendingNotifications)
})
