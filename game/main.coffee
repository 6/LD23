rand_range = (min, max, round = yes) ->
  rand = min + Math.random()*(max - min)
  return if round then Math.round(rand) else rand

dialog = (who, text, done_fn, close = no) ->
  data =
    icon: "art/#{who}.png"
    text: text
  html = ich.dialog(data)
  on_confirm = ->
    $("#dialog").animate(bottom: "-=135px", 300) if close
    done_fn() if done_fn?
  if $("#dialog").css("bottom") is "-120px"
    $("#dialog").html(html).animate(bottom: "+=135px", 300)
    $("#dialog > #confirm").click on_confirm
  else
    $("#dialog").fadeOut 150, ->
      $("#dialog").html(html).fadeIn(150)
      $("#dialog > #confirm").click on_confirm

dialogs = (list, done_fn) ->
  [who, text] = list[0]
  done = if list.length is 1 then done_fn else ->
    dialogs list[1..], done_fn
  dialog who, text, done, list.length is 1

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
    Crafty.audio.add "intro", ["sound/bu-strong-and-sweet.ogg", "sound/bu-strong-and-sweet.mp3"]
    Crafty.audio.add "upgrade", ["sound/bu-the-tense-sheep.ogg", "sound/bu-the-tense-sheep.mp3"]
    Crafty.audio.add "ending", ["sound/bu-goats-and-seas.ogg", "sound/bu-goats-and-seas.mp3"]
    Crafty.c "Ship",
      init: ->
        console.p "Crafty.c Ship"
        @addComponent("2D, Canvas, Keyboard, spaceship")
          .origin("center")
          .attr
            x: Crafty.viewport.width / 2 - 45 / 2
            y: Crafty.viewport.height / 2 - 75 / 2 - 170
            speed: 0
            speed_cap: 15
            rotation: 0
            rotation_cap: 6
            handling: 0.4
            acceleration: 0.25
            decay: 0.99
        @w = 45
        @h = 75
        @bind "EnterFrame", ->
          @speed += @acceleration if @isDown(Crafty.keys.UP_ARROW)
          @speed -= @acceleration if @isDown(Crafty.keys.DOWN_ARROW)
          @rotation += Math.min(@rotation_cap, @speed * @handling + 2) if @isDown(Crafty.keys.RIGHT_ARROW)
          @rotation -= Math.min(@rotation_cap, @speed * @handling + 2) if @isDown(Crafty.keys.LEFT_ARROW)
          @speed *= @decay
          @speed = Math.max(-@speed_cap, Math.min(@speed_cap, @speed))
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
        .bind "EnterFrame", (data) ->
          if @is_hit is yes
            @rotation += 30
            @frames_left -= 1
            @alpha = Math.max(0, @frames_left) / 50
            @destroy() if @frames_left <= 0
          else
            @rotation += 1
          if data.frame % 150 is 0
            @tween(
              x: @x + rand_range(-5, 5)
              y: @y + rand_range(-5, 5)
            , 150)
          @x = 0 if @x > Crafty.viewport.width
          @x = Crafty.viewport.width if @x < 0
          @y = 0 if @y > Crafty.viewport.height
          @y = Crafty.viewport.height if @y < 0
          collision = @hit "Ship"
          @after_hit(collision[0]) if collision and not @is_hit is yes
      after_hit: (ship) ->
        console.p "Ship hit Tiny planet!"
        @attr
          is_hit: true
          frames_left: 30
          
    Crafty.scene "Game", ->
      console.p 'Crafty.scene Game'
      Crafty.audio.settings("intro", volume: 0)
      Crafty.audio.play("upgrade", -1) # TODO only show for upgrade screen
      Crafty.e "Ship"
      Crafty.e("2D, Canvas, Tiny, tiny_#{if yes then 'purple' else 'blue'}, Collision, Tween")

    Crafty.scene "Instructions", ->
      console.p 'Crafty.scene Instructions'
      Crafty.audio.play("intro", -1)
      instructs = [
        ["captain", "Listen up, Lieutenant! You're on a mission to help us colonize this new planet."]
        ,["captain", "Use the rocket ship to collect tiny planets. You can control the ship with your arrow keys."]
        ,["lieutenant", "Aye-aye sir! Just use the arrow keys to control the ship. Gotcha."]
      ]
      dialogs instructs, ->
        console.p "Done instructing"
        Crafty.scene "Game"
    Crafty.scene "Loading", ->
      console.log 'Crafty.scene Loading'
      Crafty.load ["art/spaceship.png", "art/tiny-planet.png", "sound/bu-strong-and-sweet.ogg", "sound/bu-strong-and-sweet.mp3", "sound/bu-the-tense-sheep.ogg", "sound/bu-the-tense-sheep.mp3", "sound/bu-goats-and-seas.ogg", "sound/bu-goats-and-seas.mp3"], ->
        Crafty.scene "Instructions"
      Crafty.e("2D, DOM, Text").attr({x: 17, y:60 }).text("Loading...").textColor("#ffffff")
      $("<div id=planet><img src='art/planet.png'></div>").appendTo("#cr-stage")
      
    Crafty.scene "Loading"
