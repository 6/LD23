class window.Game
  @init: ->
    console.p "Game.init"
    Crafty.init()
    Crafty.sprite "art/spaceship.png",
      spaceship: [0, 0, 45, 75]
    Crafty.c "Ship",
      init: ->
        console.p "Crafty.c Ship"
        @addComponent("2D, Canvas, Keyboard, spaceship")
          .origin("center")
          .attr
            x: Crafty.viewport.width / 2.3
            y: Crafty.viewport.height / 2
            speed: 0
            speed_cap: 15
            rotation: 0
            handling: 0.6
            acceleration: 0.25
            decay: 0.99
        @w = 45
        @h = 75
        @bind "EnterFrame", ->
          @speed += @acceleration if @isDown(Crafty.keys.UP_ARROW)
          @speed -= @acceleration if @isDown(Crafty.keys.DOWN_ARROW)
          @rotation += @speed * @handling if @isDown(Crafty.keys.RIGHT_ARROW)
          @rotation -= @speed * @handling if @isDown(Crafty.keys.LEFT_ARROW)
          @speed *= @decay
          @speed = Math.max(0, Math.min(@speed_cap, @speed))
          @x += Math.sin(@rotation * Math.PI / 180) * @speed
          @y += Math.cos(@rotation * Math.PI / 180) * -@speed
          @x = 0 if @x > Crafty.viewport.width
          @x = Crafty.viewport.width if @x < 0
          @y = 0 if @y > Crafty.viewport.height
          @y = Crafty.viewport.height if @y < 0
          
    Crafty.scene "Game", ->
      console.p 'Crafty.scene Game'
      Crafty.e "Ship"
      
    Crafty.scene "Loading", ->
      console.log 'Crafty.scene Loading'
      Crafty.load ["art/spaceship.png"], ->
        Crafty.scene "Game"
      Crafty.e("2D, DOM, Text").attr({x: 20, y: 20 }).text("Loading...").textColor("#ffffff")
      $("<div id=planet><img src='art/planet.png'></div>").appendTo("#cr-stage")
      
    Crafty.scene "Loading"
