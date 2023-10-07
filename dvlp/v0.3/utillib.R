


# = dialog functions =========================================

showmessage <- function(msg) {
  showNotification(
    msg,
    duration = NA,   # or set seconds
    closeButton = TRUE,
    type = "message"  # "default", "message", "warning", "error", NULL
  )
}  

showmodalmessage <- function(ttl, msg) {
  showModal(modalDialog(
    title = ttl, msg ))
}
