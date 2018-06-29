import * as Datamap from "datamaps"

document.getElementById("map").innerHTML = ""

export default new Datamap({
  element: document.getElementById("map"),
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