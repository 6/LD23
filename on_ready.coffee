$ ->
  console.p "$ Ready"
  $.deprecate
    msie: '8'
    mozilla: '4'
    safari: false
    opera: false
  Game.init()
