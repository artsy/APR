// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()
let moment = require('moment')
let messagesContainer = $("#messages")
let artistFollowCheckbox = $('#show-follow-artist')
let subscriptionCheckbox = $('#show-subscriptions')
let inquiriesCheckbox = $('#show-inquiries')

// Now that you are connected, you can join channels with a topic:
let subscriptionChannel = socket.channel("subscriptions", {})
subscriptionChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })
subscriptionChannel.on("activated", payload => {
  if (subscriptionCheckbox.is(':checked')) {
    let newItem = $(`<li class="news-item">${moment().format("LT")}: ${payload.subject.display}</a> ${payload.verb} ${payload.object.root_type} for <a href=${payload.properties.partner.id}>${payload.properties.partner.name}</a></li>`)
    newItem.prependTo(messages).hide().slideDown()
  }
})

let usersChannel = socket.channel("users", {})
usersChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

usersChannel.on("followed", payload => {
  if (artistFollowCheckbox.is(':checked')) {
    let newItem = $(`<li class="news-item">${moment().format("LT")}: ${payload.subject.display}</a> ${payload.verb} <a href="http://artsy.net/artist/${payload.properties.artist.id}" target='_blank'>${payload.properties.artist.name}</a></li>`)
    newItem.prependTo(messages).hide().slideDown()
  }
})

let inquiriesChannel = socket.channel("inquiries", {})
inquiriesChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

inquiriesChannel.on("inquired", payload => {
  if (inquiriesCheckbox.is(':checked')) {
    let newItem = $(`<li class="news-item"><i class="fa fa-heart" aria-hidden="true"></i>${moment().format("LT")}: ${payload.subject.display}</a> ${payload.verb} <a href="http://artsy.net/artwork/${payload.properties.inquireable.id}" target='_blank'>${payload.properties.inquireable.name}</a></li>`)
    newItem.prependTo(messages).hide().slideDown()
  }
})



export default socket
