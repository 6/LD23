window.console ?= {}

console.p = (args...) ->
  console.log args... if window.location.hostname is "localhost"
