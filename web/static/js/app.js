import {Socket} from "phoenix"

let socket = new Socket("/ws")
socket.connect()
let chan = socket.chan("project_email_recipients:123", {})
console.log(chan)
chan.join().receive("ok", chan => {
  console.log("Success!")
})

let App = {
}

export default App
