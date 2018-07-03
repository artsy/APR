// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

import {initMap, addArc} from "./map"
import {getDistance, shortDateString, generateAThumbnail} from "./helpers"

declare const window: any


const allArcs = []

const map = initMap("map")

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

// Now that you are connected, you can join channels with a topic:
let messagesContainer = document.querySelector("#sidebar ol")

// Default to inquiries
if (document.location.hash === "") {
  document.location.hash = "#all"
}


function purchasesChannel() {
  let purchaseChannel = socket.channel("purchases")
  join(purchaseChannel)

  purchaseChannel.on("purchase.purchased", payload => {
    if (payload.partner_locations.length && payload.user.location) {
      // Use the furthest away location
      let partnerLoc = payload.partner_locations[0]
      payload.partner_locations.forEach(loc => {
        if (getDistance(payload.user.location, loc) > getDistance(payload.user.location, partnerLoc)) {
          partnerLoc = loc
        }
      });

      addArc(map, allArcs, partnerLoc, payload.user.location, { strokeWidth: 2, strokeColor: '#6E1FFF', greatArc: true} )

      const distance =  Math.round(getDistance(payload.user.location, partnerLoc))

      const thumbnail = generateAThumbnail(
        payload.artwork.images[0].image_urls.medium,
        `${payload.properties.inquireable.name}</span> from <span>${payload.properties.partner.name}</span>.`,
        `${shortDateString(payload.user.location)} ✈ ${shortDateString(partnerLoc)} (${distance}km)`
      )

      messagesContainer.insertBefore(thumbnail, messagesContainer.firstChild);
    }
  })
}

function inquiriesChannel(){
  let inquiriesChannel = socket.channel("inquiries")
  join(inquiriesChannel)
  inquiriesChannel.on("artworkinquiryrequest.inquired", payload => {

    if (payload.partner_locations.length && payload.user.location) {
      // Use the furthest away location
      let partnerLoc = payload.partner_locations[0]
      payload.partner_locations.forEach(loc => {
        if (getDistance(payload.user.location, loc) > getDistance(payload.user.location, partnerLoc)) {
          partnerLoc = loc
        }
      });

      addArc(map, allArcs, payload.user.location, partnerLoc)

      const distance =  Math.round(getDistance(payload.user.location, partnerLoc))

      const thumbnail = generateAThumbnail(
        payload.artwork.images[0].image_urls.medium,
        `${payload.properties.inquireable.name}</span> from <span>${payload.partner.name}</span>.`,
        `${shortDateString(payload.user.location)} ✈ ${shortDateString(partnerLoc)} (${distance}km)`
      )

      messagesContainer.insertBefore(thumbnail, messagesContainer.firstChild);
    }
  })
}

function join(channel){
  channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })
}

function allChannels(){
  purchasesChannel()
  inquiriesChannel()
}


// Take the query from the URL ( the #bit ) and maps it to an event from the
// socket to phoenix
//
const queryToEvent = (query: string) => {
  switch (query) {
    case "purchases":
      purchasesChannel()
    case "inquiries":
      inquiriesChannel()

    default:
      allChannels()
  }
}

queryToEvent(document.location.hash.substr(1))

export default socket
