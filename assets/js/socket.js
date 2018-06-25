// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let messagesContainer = document.querySelector("#sidebar ol")

let inquiriesChannel = socket.channel("inquiries", {})

inquiriesChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

inquiriesChannel.on("artworkinquiryrequest.inquired", payload => {

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

    let newItem = document.createElement("li", { class: "news-item"})
    newItem.innerHTML = `
      <div class="img" style="background-image: url(${payload.artwork.images[0].image_urls.medium});"></div>
      <p>
        <span>${payload.properties.inquireable.name}</span> from <span>${payload.partner.name}</span>.<br/>
        ${shortDateString(payload.user.location)} ✈ ${shortDateString(partnerLoc)} (${distance}km)
      </p>
      `

    messagesContainer.insertBefore(newItem, messagesContainer.firstChild);
  }
})

const allArcs = []

const shortDateString = (loc) => {
  if (loc.country === "United States") {
    return `${loc.city}, ${loc.state_code}`
  }
  return `${loc.city}, ${loc.country}`
}

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
  window.map.arc(allArcs)

  // cap it at 50
  if (allArcs.length > 50) {
    allArcs.shift()
  }
}

const getDistance = (to, from) => {
  return getDistanceFromLatLonInKm(from.coordinates.lat, from.coordinates.lng, to.coordinates.lat, to.coordinates.lng)
}

// https://stackoverflow.com/questions/18883601/function-to-calculate-distance-between-two-coordinates-shows-wrong

function getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
  var R = 6371; // Radius of the earth in km
  var dLat = deg2rad(lat2-lat1);  // deg2rad below
  var dLon = deg2rad(lon2-lon1); 
  var a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
    Math.sin(dLon/2) * Math.sin(dLon/2)
    ; 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  var d = R * c; // Distance in km
  return d;
}

function deg2rad(deg) {
  return deg * (Math.PI/180)
}

export default socket
