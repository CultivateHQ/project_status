let TIMEOUT = 5000;

let trelloProjectId = null,
    socket = null,
    chan = null

function createChannel(){
    chan = socket.channel(`trellos:${trelloProjectId}`)
    chan.join().receive("ok", chan => {
        console.log(`Joined trellos channel ${trelloProjectId}`)
    })
    chan.on("trello_totals", payload => {
        populateTrelloTotals(payload.totals)
    })
    chan.on("trello_totals_error", payload => {
        trelloTotalsError(payload.error)
    })
}

function trelloTotalsError(error) {
    $('#trello_totals thead').html("<th>Trello totals error</th>")
    $('#trello_totals tbody').html("<tr><td/></tr>")
    $('#trello_totals tbody tr td').text(error)
    console.log(error)
}

function populateTrelloTotals(totals) {
    let headers = ""
    let row = "<tr>"
    totals.forEach(total => {
        headers += `<td>${total[0]}</td>`
        row += `<td>${total[1]}</td>`
    })
    row += "</tr>"
    $('#trello_totals thead').html(headers)
    $('#trello_totals tbody').html(row)
    console.log(row)
}

export function initTrellos(socket_){
    if($('form#new_status_email').length == 0) return
    trelloProjectId = $('#project').data().trelloProjectId
    if(trelloProjectId == "") return


    socket = socket_
    createChannel()
    // bindSendStatusEmail()
    // bindStatusEmailPreview()
}
