import map from "./map"

declare const window: any

// Take the query from the URL ( the #bit ) and maps it to an event from the
// socket to phoenix
//
const queryToEvent = (query: string) => {
  switch (query) {
    case "purchases":
      return "purchases"

    default:
      return "artworkinquiryrequest.inquired"
  }
}

const allArcs = []

// From an Artsy Location to a mini summary
const shortDateString = (loc) => {
  if(!loc) {
    return "TBD"
  }
  if (loc.country === "United States" && loc.state_code) {
    return `${loc.city}, ${loc.state_code}`
  }
  // If we just have a city
  if(!loc.country) {
    return loc.city
  }

  return `${loc.city}, ${loc.country}`
}

// Adds an arc, and caps the amount at 50 on the map
const addArc = (from, to) => {
  const arcData = {
    origin: {
        latitude: from.coordinates.lat,
        longitude: from.coordinates.lng
    },
    destination: {
      latitude: to.coordinates.lat,
      longitude: to.coordinates.lng
    }
  }
  allArcs.push(arcData)
  map.arc(allArcs)

  // cap it at 50
  if (allArcs.length > 50) {
    allArcs.shift()
  }
}


// Using the lat/long format in the Artsy Location - get the distance as the crow flies
const getDistance = (to, from) =>  getDistanceFromLatLonInKm(from.coordinates.lat, from.coordinates.lng, to.coordinates.lat, to.coordinates.lng)


// https://stackoverflow.com/questions/18883601/function-to-calculate-distance-between-two-coordinates-shows-wrong
//
const getDistanceFromLatLonInKm = (lat1:number, lon1:number, lat2:number, lon2:number ) => {
  var R = 6371; // Radius of the earth in km
  var dLat = deg2rad(lat2-lat1);  // deg2rad below
  var dLon = deg2rad(lon2-lon1);
  var a =
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon/2) * Math.sin(dLon/2)
    ;
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  var d = R * c // Distance in km
  return d
}

// Needed for above.
const deg2rad = (deg: number) => {
  return deg * (Math.PI/180)
}

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

// Now that you are connected, you can join channels with a topic:
let messagesContainer = document.querySelector("#sidebar ol")

// Default to inquiries
if (document.location.hash === "") {
  document.location.hash = "#inquiries"
}

const channel = document.location.hash.substr(1)
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

    addArc(payload.user.location, partnerLoc)

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
