export function flashUpMessage(msg) {
    let flashed = $('#flashed')
    flashed.html(msg)
    setTimeout(() => {flashed.html('&nbsp;')}, 5000)
}
