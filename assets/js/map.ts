import * as Datamap from "datamaps"

document.getElementById("map").innerHTML = ""

export const addArc = (map, allArcs, from, to, options={}) => {
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

export const initMap = (mapElementId) => {
  return new Datamap({
    element: document.getElementById(mapElementId),
    projection: "mercator",
    bubblesConfig: {
      animate: false
    },
    arcConfig: {
      strokeColor: 'rgba(247, 247, 113, 0.5) ',
      strokeWidth: 2,
      animationSpeed: 1000
    }
  })
}

export default {
  initMap,
  addArc
}
