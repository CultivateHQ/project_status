import {Socket} from "phoenix"
import {initProjectEmailRecipient} from "web/static/js/project_email_recipient"
import {initProjectEmailStatus} from "web/static/js/project_email_status"

let socket = new Socket("/ws")
socket.connect()

initProjectEmailRecipient(socket)
initProjectEmailStatus(socket)

let App = {
}

export default App
