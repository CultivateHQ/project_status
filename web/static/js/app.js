import {Socket} from "phoenix"
import {initProjectEmailRecipient} from "web/static/js/project_email_recipient"

let socket = new Socket("/ws")
socket.connect()

initProjectEmailRecipient(socket)

let App = {
}

export default App
