import {Socket} from "deps/phoenix/web/static/js/phoenix"
import "deps/phoenix_html/web/static/js/phoenix_html"

import {initProjectEmailRecipient} from "web/static/js/project_email_recipient"
import {initProjectEmailStatus} from "web/static/js/project_email_status"

let socket = new Socket("/ws")
let token = $("meta[name='channel_token']").attr('content')
socket.connect({token: token})

initProjectEmailRecipient(socket)
initProjectEmailStatus(socket)

let App = {
}

export default App
