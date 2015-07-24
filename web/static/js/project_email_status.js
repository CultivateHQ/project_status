import {flashUpMessage} from "web/static/js/flashup"
let projectId = null,
    socket = null,
    chan = null

function errorContainer(){
    return $('#new_status_email .errors')
}

function showErrors(errors){
    clearErrors()
    errors.forEach(error => {
        errorContainer().append(`<li>${error}</li>`)
    })
    formFieldSetContainer().addClass("errored")
}

function clearErrors(){
    errorContainer().html("")
    formFieldSetContainer().removeClass("errored")
}

function indicateFailure(changeset){
    let errors = []
    for (var key in changeset) {
        errors.push(`${key} ${changeset[key]}`)
    }
    showErrors(errors)
}

function indicateTimeout(){
    showErrors(["Sorry, the request timed out. Please try again."])
}

function clearForm(){
    $('#new_status_email textarea').val("")
}

function createChannel(){
    chan = socket.chan(`project_status_emails:${projectId}`)
    chan.join().receive("ok", chan => {
        console.log(`Joined status email channel ${projectId}`)
        loadStatusEmails()
    })
    chan.on("new_status_email", status_email => {
        addStatusEmailToDisplay(status_email)
    })
}

function loadStatusEmails(){
    chan.push("get_project_status_emails").
        receive("ok", payload => {
            payload.status_emails.forEach(email => {
                addStatusEmailToDisplay(email)
            })
        }).
        after(2000, () => {flashUpMessage("Can't load email recipients")})
}

function addStatusEmailToDisplay(email) {
    $('#sent_status_emails').prepend(
        "<li>" +
            `<a href="/projects/${projectId}/status_emails/${email.id}">` +
            email.subject +
            "</a>" + 
         "</li>"
    )
}



function formFieldSetContainer(){
    return $('#new_status_email fieldset')
}

function indicateSubmissionStarted(){
    clearErrors()
    formFieldSetContainer().addClass("submitting")
}

function indicateSubmissionFinished(){
    formFieldSetContainer().removeClass("submitting")
}

function bindSendStatusEmail(){
    $('#new_status_email').submit(e => {
        let statusDate = $('#new_status_email_status_date').val()
        let content = $('#new_status_email_content').val().trim()
        sendNewEmail(statusDate, content)
        e.preventDefault();
    })
}

function sendNewEmail(statusDate, content){
    clearErrors()
    indicateSubmissionStarted()
    chan.push("send_status_email", {status_date: statusDate, content: content})
        .receive("ok", payload => {
            indicateSubmissionFinished()
            clearForm()
            clearErrors()
            flashUpMessage("Email has been created")
        })
        .receive("error", payload => {
            indicateSubmissionFinished()
            indicateFailure(payload.changeset)
        })
        .after(2000, () => {
            indicateTimeout()
        })
}
export function initProjectEmailStatus(socket_){
    if($('form#new_status_email').length == 0) return

    socket = socket_
    projectId= $('#project').data().projectId
    createChannel()
    bindSendStatusEmail()
}
