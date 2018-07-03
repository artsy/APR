// From an Artsy Location to a mini summary
export const shortDateString = (loc) => {
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

// https://stackoverflow.com/questions/18883601/function-to-calculate-distance-between-two-coordinates-shows-wrong
//
export const getDistanceFromLatLonInKm = (lat1:number, lon1:number, lat2:number, lon2:number ) => {
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

// Using the lat/long format in the Artsy Location - get the distance as the crow flies
export const getDistance = (to, from) =>  getDistanceFromLatLonInKm(from.coordinates.lat, from.coordinates.lng, to.coordinates.lat, to.coordinates.lng)


/** Generates a sidebar item for an artwork */
export const generateAThumbnail = (imageURL: string, title: string, subtitle: string) => {

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



export default { shortDateString, getDistanceFromLatLonInKm, getDistance, generateAThumbnail }