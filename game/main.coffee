progress_queue = []
progress_in_action = no
time = 0
temp_time = 1
has_upgrade_instructions = no
tiny_planets = []

tick_tock = -> # run every frame
  temp_time += 1
  if temp_time % 100 == 0
    temp_time = 1
    time += 1
  check_progress_queue()
  check_game_done()
  if get_level() >= 2 and not has_upgrade_instructions
    has_upgrade_instructions = yes
    destroy_all_tiny ->
      Crafty.scene "Level2"

rand_range = (min, max, round = yes) ->
  rand = min + Math.random()*(max - min)
  return if round then Math.round(rand) else rand
  
rand_location_not_near = (min_x, max_x, min_y, max_y, not_min_x, not_min_y, not_max_x, not_max_y) ->
  if not not_max_x?
    not_min_x -= 80
    not_max_x = not_min_x + 160
  if not not_max_y?
    not_min_y -= 80
    not_max_y = not_min_y + 160
  rand_x = rand_range(min_x, max_x)
  rand_y = rand_range(min_y, max_y)
  if rand_x < not_min_x or rand_x > not_max_x or rand_y < not_min_y or rand_y > not_max_y
    return [rand_x, rand_y]
  else
    return rand_location_not_near(min_x, max_x, min_y, max_y, not_min_x, not_min_y, not_max_x, not_max_y)

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

fade_audio = (ident, i, delay = 500, start_volume = 1) ->
  i ?= start_volume * 10
  Crafty.audio.settings ident, volume: (i - 1)/(start_volume*10)
  return if i - 1 <= 0
  setTimeout ->
    fade_audio ident, i - 1, delay, start_volume
  , delay

get_level = ->
  parseInt($("#level").text().split(" ")[1])

change_level = (new_level) ->
  console.p "Change level to #{new_level}"
  $("#level").fadeOut(200).text("Level #{new_level}").fadeIn(200)

check_progress_queue = ->
  return if progress_in_action or progress_queue.length is 0
  add_progress(progress_queue.splice(0, 1))
  
enqueue_progress = (amount) ->
  progress_queue.push(amount)

add_progress = (amount) ->
  progress_in_action = yes
  level = get_level()
  progress_change = amount / (level / 2)
  progress = parseInt($("#progress-inner").css("width"))
  if progress + progress_change >= 192 # level up
    level += 1
    change_level(level)
    $("#progress-inner").animate width: "100%", 50, ->
      $("#progress-inner").css("width", "0%")
      progress_change = progress + progress_change - 192 #TODO
      $("#progress-inner").animate width: "#{progress_change}px", 100, ->
        progress_in_action = no
  else
    $("#progress-inner").animate width: "#{progress + progress_change}px", 100, ->
      progress_in_action = no

check_game_done = ->
  return if get_level() < 5
  Crafty.scene "End"
  
destroy_all_tiny = (done_fn) ->
  for tiny in tiny_planets
    tiny.after_hit()
  tiny_planets = []
  setTimeout done_fn, 200 if done_fn?

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
    Crafty.audio.add "tiny", ["sound/Pickup_Coin4.ogg", "sound/Pickup_Coin4.mp3"]

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
          tick_tock()

    Crafty.c "Tiny",
      init: ->
        console.p "Crafty.c Tiny"
        @w = 35
        @h = 35
        @origin("center")
        [x, y] = rand_location_not_near(40, Crafty.viewport.width - 40, 40, Crafty.viewport.height - 40,
          Crafty.viewport.width / 2 - 45 / 2, Crafty.viewport.height / 2 - 75 / 2 - 170)
        @attr
          x: x
          y: y
          is_hit: no
          rotation_speed: rand_range(1, 3)
        .bind "EnterFrame", (data) ->
          if @is_hit is yes
            @rotation += 30
            @frames_left -= 1
            @alpha = Math.max(0, @frames_left) / 50
            @destroy() if @frames_left <= 0
          else
            @rotation += @rotation_speed
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
        if ship?
          console.p "Ship hit Tiny planet!"
          Crafty.audio.settings("tiny", volume: 0.1)
          Crafty.audio.play("tiny")
          enqueue_progress(10)
        @attr
          is_hit: true
          frames_left: 30
          
    Crafty.scene "Game", ->
      console.p 'Crafty.scene Game'
      $("<div id='progress-wrap' style='display:none'>
           <div id=level>Level 1</div>
           <div id=progress><div id='progress-inner'></div></div>
         </div>").appendTo("#planet")
      progress_in_action = yes
      $("#progress-wrap").fadeIn 600
      $("#progress-inner").animate width: "100%", 300, ->
        $("#progress-inner").animate width: "-=100%", 500, ->
          progress_in_action = no
      Crafty.audio.settings("intro", volume: 0)
      #Crafty.audio.play("upgrade", -1) # TODO only show for upgrade screen
      Crafty.e "Ship"
      for i in [0..20]
        color = {0: 'purple', 1: 'blue', 2: 'green', 3: 'red'}[rand_range(0,3)]
        tiny_planets.push Crafty.e("2D, Canvas, Tiny, tiny_#{color}, Collision, Tween")
          .attr color: color
    
    Crafty.scene "Level2", ->
      console.p "Crafty.scene Level2"
      instructions = [
        ["captain", "Great work, soldier! Thanks to your hard work, the planet has become a Level 2 colony."]
        ,["captain", "Each time the colony levels up, you can click on the 'Store' button to buy upgrades for your ship."]
        ,["lieutenant", "Oh, baby!"]
      ]
      dialogs instructions, ->
        Crafty.e "Ship"
        #TODO start level 2

    Crafty.scene "Instructions", ->
      console.p 'Crafty.scene Instructions'
      #Crafty.audio.play("intro", -1)
      instructs = [
        ["captain", "Listen up, Lieutenant! You're on a mission to help us colonize this new planet."]
        ,["captain", "Use the rocket ship to collect tiny planets. You can control the ship with your arrow keys."]
        ,["lieutenant", "Aye-aye sir! Just use the arrow keys to control the ship. Gotcha."]
      ]
      dialogs instructs, ->
        console.p "Done instructing"
        Crafty.scene "Game"

    Crafty.scene "End", ->
      console.p 'Crafty.scene End'
      final_score = Math.max(1000, 1900 - time) + rand_range(1, 50)
      $("#progress-wrap").fadeOut(400)
      Crafty.audio.play("ending", -1)
      instructs = [
        ["captain", "Well done, Lieutenant. With your help, the planet is now in tip-top shape!"]
        ,["captain", "Your final score is... #{final_score}! Congratulations!"]
        ,["lieutenant", "Wahoo!! Yeah!"]
      ]
      dialogs instructs, ->
        console.p "Done"
        fade_audio "ending"
        $("#planet").fadeOut(3000)
        $("<div id=end style='display:none'>
             <h2>Game over</h2>
             <a href='/'>Replay?</a>
           </div>").appendTo("#cr-stage")
        $("#end").fadeIn(3000)

    Crafty.scene "Loading", ->
      console.p 'Crafty.scene Loading'
      Crafty.load [
        "art/planet.png",
        "art/progress-bg.png", "art/progress-inner.png",
        "art/spaceship.png",
        "art/tiny-planet.png",
        "sound/bu-strong-and-sweet.ogg", "sound/bu-strong-and-sweet.mp3",
        "sound/bu-the-tense-sheep.ogg", "sound/bu-the-tense-sheep.mp3",
        "sound/bu-goats-and-seas.ogg", "sound/bu-goats-and-seas.mp3",
        "sound/Message.ogg", "sound/Message.mp3",
        "sound/Pickup_Coin4.ogg", "sound/Pickup_Coin4.mp3"
      ], ->
        $("<div id=planet style='display:none'><img src='art/planet.png'></div>").appendTo("#cr-stage")
        $("#planet").fadeIn 800, ->
          Crafty.scene "Instructions"
      Crafty.e("2D, DOM, Text").attr({x: 17, y:60 }).text("Loading...").textColor("#ffffff")
      
    Crafty.scene "Loading"
