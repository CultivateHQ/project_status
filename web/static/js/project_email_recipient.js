
let projectId = null,
    chan = null,
    socket = null

function createChannel(){
    chan = socket.channel(`project_email_recipients:${projectId}`, {})
    chan.join().receive("ok", chan => {
        console.log(`Joined channel with ${projectId}`)
        loadProjectEmailRecipients()
    })
    chan.on("new_project_email_recipient", payload => {
        addRecipientToDisplay(payload.email_recipient)
    })
    chan.on("delete_project_email_recipient", payload => {
        deleteRecipient(payload.id)
    })
}

function recipientsContainer(){
    return $('ul#recipient_list')
}

function deleteRecipient(recipientId) {
    $(`#email-recipient-${recipientId}`).remove()
}
function addRecipientToDisplay(emailRecipient){
    recipientsContainer().append(`<li id='email-recipient-${emailRecipient.id}'>` +
                                 '<span class="recipient">' +
                               `${emailRecipient.name} &lt;${emailRecipient.email}>` +
                                 '</span>' +
                                 '<a class="btn btn-danger btn-xs delete_recipient"' +
                                 `data-email-recipient-id="${emailRecipient.id}">` +
                                 'Delete</a>' +
                                 '</li>')
    bindDeleteButtons(recipientsContainer().find("li:last"))
}


function formFieldSetContainer(){
    return $('#new_project_email_recipient fieldset')
}

function indicateSubmissionStarted(){
    formFieldSetContainer().addClass("submitting")
}

function indicateSubmissionFinished(){
    formFieldSetContainer().removeClass("submitting")
}

function errorContainer(){
    return $('#new_project_email_recipient .errors')
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
    formFieldSetContainer().find("input:first").focus()
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
    $('#new_project_email_recipient fieldset input').val("")
}


function submitNewEmailRecipient(name, email){
    indicateSubmissionStarted()
    chan.push("new_project_email_recipient", {name: name, email: email})
        .receive("ok", payload => {
            indicateSubmissionFinished()
            clearForm()
            clearErrors()
            // recipient added from channel broadcast
        })
        .receive("error", payload => {
            indicateSubmissionFinished()
            indicateFailure(payload.changeset)
        })
        .after(2000, () => {
            indicateTimeout()
        })
}

function submitDeleteRecipient(emailRecipientId){
    chan.push("delete_project_email_recipient", {id: emailRecipientId})
        .receive("ok", payload => {
            // Delete from broadcast
        }).
        after(2000, () => {
            $('a.delete_recipient.submitting').removeClass("submitting")
            alert("Timeout deleting :-(")
        })
}

function bindNewEmailRecipientSubmit(){
    $('#new_project_email_recipient').submit(e => {
        let name = $('#project_email_recipient_name').val()
        let email = $('#project_email_recipient_email').val()
        submitNewEmailRecipient(name, email)
        e.preventDefault()
    })
}

function bindDeleteButtons(buttons = $("#recipient_list a.delete_recipient")){
    buttons.click(event => {
        let targetButton = $(event.target)
        targetButton.addClass("submitting")
        submitDeleteRecipient($(event.target).data().emailRecipientId)
    })
}

function loadProjectEmailRecipients(){
    recipientsContainer().html("")
    chan.push("project_email_recipients").
        receive("ok", payload => {
            payload.project_email_recipients.forEach(recipient => {
                addRecipientToDisplay(recipient)
            })
        }).
        after(2000, () => {alert("Can't load email recipients")})
}

export function initProjectEmailRecipient(socket_) {
    if ($('#new_project_email_recipient').length == 0) return
    socket = socket_
    projectId= $('#project').data().projectId
    createChannel()
    bindNewEmailRecipientSubmit()
}
