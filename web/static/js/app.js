import {Socket} from "phoenix"

let socket = new Socket("/ws")
socket.connect()

let App = {
    init: () => {
        if ($('#new_project_email_recipient').length > 0) App.init_new_email_recipients()
    },
    init_new_email_recipients: () => {
        let chan = socket.chan("project_email_recipients:123", {})
        chan.join().receive("ok", chan => {
            console.log("Wat! Success!")
        })

        $('#new_project_email_recipient').submit(e => {
            let name = $('#project_email_recipient_name').val()
            let email = $('#project_email_recipient_email').val()
            console.log(name, email, "yar!")
            e.preventDefault()
        })
    }
}

export default App
App.init()
