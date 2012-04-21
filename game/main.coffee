class window.Game
  @init: ->
    console.p "Game.init"
    Crafty.init()
    Crafty.sprite "art/spaceship.png",
      spaceship: [0, 0, 45, 75]
    Crafty.sprite 35, "art/tiny-planet.png",
      tiny_purple: [0, 0]
      tiny_blue: [1, 0]
      tiny_green: [2, 0]
      tiny_red: [3, 0]
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
    Crafty.c "Tiny",
      init: ->
        console.p "Crafty.c Tiny"
        @w = 35
        @h = 35
        @origin("center")
        @attr
          x: 400
          y: 300
          is_hit: no
        .bind "EnterFrame", ->
          if @is_hit is yes
            @rotation += 30
            @frames_left -= 1
            @alpha = Math.max(0, @frames_left) / 50
            @destroy() if @frames_left <= 0
          else
            @rotation += 1
          collision = @hit "Ship"
          @after_hit(collision[0]) if collision and not @is_hit is yes
      after_hit: (ship) ->
        console.p "Ship hit Tiny planet!"
        @attr
          is_hit: true
          frames_left: 30
          
    Crafty.scene "Game", ->
      console.p 'Crafty.scene Game'
      Crafty.e "Ship"
      Crafty.e("2D, Canvas, Tiny, tiny_#{if yes then 'purple' else 'blue'}, Collision")
      
    Crafty.scene "Loading", ->
      console.log 'Crafty.scene Loading'
      Crafty.load ["art/spaceship.png", "art/tiny-planet.png"], ->
        Crafty.scene "Game"
      Crafty.e("2D, DOM, Text").attr({x: 20, y: 20 }).text("Loading...").textColor("#ffffff")
      $("<div id=planet><img src='art/planet.png'></div>").appendTo("#cr-stage")
      
    Crafty.scene "Loading"
