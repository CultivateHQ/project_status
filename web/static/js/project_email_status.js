import {flashUpMessage} from "web/static/js/flashup"

let TIMEOUT = 5000;

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

function clearEmailText(){
    $('#status_email_content_preview').html('')
    $('#new_status_email textarea').val("")
}

function createChannel(){
    chan = socket.channel(`project_status_emails:${projectId}`)
    chan.join().receive("ok", chan => {
        console.log(`Joined status email channel ${projectId}`)
        loadStatusEmails()
    })
    chan.on("new_status_email", status_email => {
        addStatusEmailToDisplay(status_email)
    })
}

function loadStatusEmails(){
    $('#sent_status_emails').html('')
    chan.push("get_project_status_emails").
        receive("ok", payload => {
            payload.status_emails.forEach(email => {
                addStatusEmailToDisplay(email)
            })
        }).
        after(TIMEOUT, () => {flashUpMessage("Can't load email recipients")})
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
    if(!confirm("Send email?")){ return }
    indicateSubmissionStarted()
    chan.push("send_status_email", {status_date: statusDate, content: content})
        .receive("ok", payload => {
            indicateSubmissionFinished()
            clearEmailText()
            clearErrors()
            flashUpMessage("Email has been created")
        })
        .receive("error", payload => {
            indicateSubmissionFinished()
            indicateFailure(payload.changeset)
        })
        .receive("email_failed", payload => {
            indicateSubmissionFinished()
            showErrors(["Sorry, the email has failed to send. Try again?"])
        })
        .after(TIMEOUT, () => {
            indicateTimeout()
        })
}

function bindStatusEmailPreview(){
    let content = $('#new_status_email_content')
    let preview = $("#status_email_content_preview")
    content.on("input", () => {
        chan.push("preview_content", {markdown: content.val()})
            .receive("ok", payload => {
                preview.html(payload.html) 
            })
    })
}

export function initProjectEmailStatus(socket_){
    if($('form#new_status_email').length == 0) return

    socket = socket_
    projectId= $('#project').data().projectId
    createChannel()
    bindSendStatusEmail()
    bindStatusEmailPreview()
}
