// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

import map from "./map"
import {getDistance, shortDateString} from "./helpers"

declare const window: any


const allArcs = []

// Adds an arc, and caps the amount at 50 on the map
const addArc = (from, to, options={}) => {
  const arcData = {
    origin: {
        latitude: from.coordinates.lat,
        longitude: from.coordinates.lng
    },
    destination: {
      latitude: to.coordinates.lat,
      longitude: to.coordinates.lng
    },
    options
  }
  allArcs.push(arcData)
  map.arc(allArcs)

  // cap it at 50
  if (allArcs.length > 50) {
    allArcs.shift()
  }
}


let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

// Now that you are connected, you can join channels with a topic:
let messagesContainer = document.querySelector("#sidebar ol")

// Default to inquiries
if (document.location.hash === "") {
  document.location.hash = "#inquiries"
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

const channels = queryToEvent(document.location.hash.substr(1))

let socketChannel = socket.channel(channel, {})

socketChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

socketChannel.on("artworkinquiryrequest.inquired", payload => {

  if (payload.partner_locations.length && payload.user.location) {
    // Use the furthest away location
    let partnerLoc = payload.partner_locations[0]
    payload.partner_locations.forEach(loc => {
      if (getDistance(payload.user.location, loc) > getDistance(payload.user.location, partnerLoc)) {
        partnerLoc = loc
      }
    });

    addArc(payload.user.location, partnerLoc)

    const distance =  Math.round(getDistance(payload.user.location, partnerLoc))

    const thumbnail = generateAThumbnail(
      payload.artwork.images[0].image_urls.medium,
      `${payload.properties.inquireable.name}</span> from <span>${payload.partner.name}</span>.`,
      `${shortDateString(payload.user.location)} ✈ ${shortDateString(partnerLoc)} (${distance}km)`
    )

    messagesContainer.insertBefore(thumbnail, messagesContainer.firstChild);
  }
})

socketChannel.on("purchase.purchased", payload => {
  if (payload.partner_locations.length && payload.user.location) {
    // Use the furthest away location
    let partnerLoc = payload.partner_locations[0]
    payload.partner_locations.forEach(loc => {
      if (getDistance(payload.user.location, loc) > getDistance(payload.user.location, partnerLoc)) {
        partnerLoc = loc
      }
    });

    addArc(partnerLoc, payload.user.location, { strokeWidth: 2, strokeColor: '#6E1FFF', greatArc: true} )

    const distance =  Math.round(getDistance(payload.user.location, partnerLoc))

    const thumbnail = generateAThumbnail(
      payload.artwork.images[0].image_urls.medium,
      `${payload.properties.inquireable.name}</span> from <span>${payload.properties.partner.name}</span>.`,
      `${shortDateString(payload.user.location)} ✈ ${shortDateString(partnerLoc)} (${distance}km)`
    )

    messagesContainer.insertBefore(thumbnail, messagesContainer.firstChild);
  }
})


/** Generates a sidebar item for an artwork */
const generateAThumbnail = (imageURL: string, title: string, subtitle: string) => {

  let newItem = document.createElement("li")
  newItem.className = "news-item"
  newItem.innerHTML = `
    <div class="img" style="background-image: url(${imageURL});"></div>
    <p>
      ${title}.<br/>
      ${subtitle}
    </p>
    `

    return newItem;
}

export default socket
