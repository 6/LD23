class window.Game
  @init: ->
    console.p "Game.init"
    Crafty.init()
    Crafty.sprite 1, "art/spaceship.png",
      spaceship: [0, 0, 45, 71]
    Crafty.c "Ship",
      init: ->
        console.p "Crafty.c Ship"
        @addComponent("2D, Canvas, Fourway, spaceship")
          .attr
            x: Crafty.viewport.width / 2.3
            y: Crafty.viewport.height / 2
          .fourway(10)
        @w = 45
        @h = 71
    Crafty.scene "Game", ->
      console.p 'Crafty.scene Game'
      Crafty.e "Ship"
      
    Crafty.scene "Loading", ->
      console.log 'Crafty.scene Loading'
      Crafty.load ["art/spaceship.png"], ->
        Crafty.scene "Game"
      Crafty.e("2D, DOM, Text").attr({x: 20, y: 20 }).text("Loading...").textColor("#ffffff")
      
    Crafty.scene "Loading"
