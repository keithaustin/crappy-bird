require "crsfml"
require "crsfml/audio"
require "./ecs"
require "./components"
require "./assemblies"

include ECS

module Systems
  module Game
    ENV = "prod"

    JUMP_VELOCITY = -440.0
    JUMP_COOLDOWN_SECS = 0.2

    @@jump_cooldown = 0.0

    @@state = :title
    @@world = World.new
    @@score : Int32 = 0

    def self.create_world
      @@world = World.new
    end

    def self.setup_game
      @@world.dispose
      self.create_world
      @@score = 0
    end

    def self.world
      @@world
    end

    def self.gameover
      Sound.stop_music
      @@state = :gameover
    end

    def self.gain_score(points : Int32)
      @@score += points
    end

    def self.score
      @@score
    end

    def self.state
      @@state
    end

    def self.start_game
      self.setup_game
      Sound.start_music
      @@state = :in_game
    end

    def self.pause_game
      @@state = :paused
    end

    def self.tick(delta_time)
      @@jump_cooldown = Math.max(@@jump_cooldown - (1.0 * delta_time), 0.0)
    end

    def self.jump_cooldown?
      @@jump_cooldown > 0
    end

    def self.set_jump_cooldown
      @@jump_cooldown = JUMP_COOLDOWN_SECS
    end
  end

  module Render
    def self.draw(window : SF::RenderWindow, world : World)
      window.clear SF::Color.new(117, 126, 227)

      world.entities_with(Set{Sprite}).each do |entity|
        window.draw entity.get(Sprite).sprite
        if Game::ENV == "dev"
          self.draw_hitbox(window, entity.get(Sprite).sprite.global_bounds.left,
            entity.get(Sprite).sprite.global_bounds.top,
            entity.get(Sprite).sprite.global_bounds.width,
            entity.get(Sprite).sprite.global_bounds.height)
        end
      end

      case Game.state
      when :in_game
        self.draw_score(window)
      when :title
        self.draw_title_ui(window)
      when :gameover
        self.draw_gameover_ui(window)
      end

      window.display
    end

    def self.draw_hitbox(window, x, y, width, height)
      hitbox = SF::RectangleShape.new
      hitbox.size = SF.vector2(width, height)
      hitbox.position = {x, y}
      hitbox.outline_color = SF::Color::Red
      hitbox.outline_thickness = 4
      hitbox.fill_color = SF::Color::Transparent
      window.draw hitbox
    end

    def self.draw_score(window)
      score_text = SF::Text.new
      score_text.font = Resources.font
      score_text.character_size = 26
      score_text.color = SF::Color::White
      score_text.outline_color = SF::Color::Black
      score_text.outline_thickness = 2
      score_text.style = SF::Text::Bold
      score_text.position = {24.0, 24.0}

      score_text.string = "Score: #{Game.score}"

      window.draw(score_text)
    end

    def self.draw_black_background(window)
      background = SF::RectangleShape.new
      background.position = {0.0, 0.0}
      background.size = window.size
      background.fill_color = Resources.black_background_color

      window.draw background
    end

    def self.draw_gameover_ui(window)
      self.draw_black_background window

      gameover_text = Resources.text
      gameover_text.character_size = 48
      gameover_text.position = {72.0, 24.0}

      gameover_text.string = "You Lose"

      window.draw gameover_text

      score_text = Resources.text
      score_text.character_size = 26
      score_text.position = {148.0, 128.0}

      score_text.string = "Score: #{Game.score}"

      window.draw score_text
    end

    def self.draw_title_ui(window)
      self.draw_black_background window

      title_text = Resources.text
      title_text.character_size = 48
      title_text.position = {22.0, 24.0}

      title_text.string = "Crappy Bird"

      window.draw title_text

      instruction_text = Resources.text
      instruction_text.character_size = 18
      instruction_text.position = {64.0, 128.0}

      instruction_text.string = "Press any key to start"

      window.draw instruction_text
    end
  end

  module Sound
    @@music = Resources.music
    def self.play_sound(buffer)
      sound = SF::Sound.new(buffer)
      sound.volume = 60
      sound.play
    end

    def self.start_music
      @@music.volume = 50
      @@music.loop = true
      @@music.play
    end

    def self.stop_music
      @@music.pause
    end
  end

  module Physics
    SCORE_SPEED_MULT = 0.5

    def self.update(world : World, delta_time)
      elapsed_time = delta_time
      unless Game.state == :in_game
        return
      end

      player = nil

      world.entities_with(Set{PlayerController}).each do |entity|
        player ||= entity
        if entity.get(Sprite).sprite.position.y <= 0
          entity.get(Speed).speed = 0
        end
        entity.get(Speed).speed += elapsed_time * 1000
        entity.get(Sprite).sprite.move(0.0, entity.get(Speed).speed * elapsed_time)
        entity.get(Sprite).sprite.rotation = {entity.get(Speed).speed / 16, 90.0}.min

        world.entities_with(Set{Pipe, Collider, Sprite}).each do |collider|
          collision_rect = collider.get(Sprite).sprite.global_bounds
            .intersects?(entity.get(Sprite).sprite.global_bounds)

          if collision_rect || entity.get(Sprite).sprite.position.y > 680
            Sound.play_sound(Resources.death_sound)
            Game.gameover
          end
        end
      end

      world.entities_with(Set{Pipe, Sprite, Speed}).each do |entity|
        entity.get(Sprite).sprite.move(entity.get(Speed).speed * elapsed_time, 0.0)
        entity.get(Speed).speed += (Game.score * -SCORE_SPEED_MULT) * elapsed_time
        if entity.get(Sprite).sprite.position.x < -144.0
          world.remove_entity(entity)
        end
      end

      world.entities_with(Set{ScoreTrigger, Speed}).each do |entity|
        entity.get(ScoreTrigger).x += entity.get(Speed).speed * elapsed_time
        entity.get(Speed).speed += (Game.score * -SCORE_SPEED_MULT) * elapsed_time
        
        if player.nil?
          return
        end

        if entity.get(ScoreTrigger).x < player.get(Sprite).sprite.position.x
          Game.gain_score(1)
          world.remove_entity(entity)
        end
      end
    end
  end

  module Input
    def self.update(window : SF::RenderWindow, world : World, event : SF::Event::KeyEvent)
      if event.code.escape?
        window.close
      elsif event.code.enter?
        world.pretty_print
      else
        case Game.state
        when :in_game
          return if Game.jump_cooldown?
          world.entities_with(Set{PlayerController, Speed}).each do |entity|
            entity.get(Speed).speed = Game::JUMP_VELOCITY
            Sound.play_sound(Resources.jump_sound)
          end

          Game.set_jump_cooldown
        when :title
          Game.start_game
          Sound.play_sound(Resources.start_sound)
          return
        when :gameover
          Game.start_game
          Sound.play_sound(Resources.start_sound)
          return
        end
      end
    end
  end

  module Spawner
    PIPE_DISTANCE        = 396.0
    PIPE_BASE_HEIGHT     = 520.0
    PIPE_OFFSET          = 360.0
    PIPE_HEIGHT_MULT     = 200.0
    SCORE_TRIGGER_OFFSET =  44.0

    def self.update(world : World)
      # Ensure player is created
      if world.entities_with(Set{PlayerController}).size < 1
        self.spawn_bird(world)
      end
      # Decide whether to spawn pipes
      pipe_count = world.entities_with(Set{Pipe}).size

      if pipe_count <= 3
        # Decide where to spawn pipes
        (1..6).each do |index|
          height_diff = Random.rand * PIPE_HEIGHT_MULT
          spawn_height = PIPE_BASE_HEIGHT - height_diff
          spawn_x = (index * PIPE_DISTANCE + PIPE_OFFSET).to_f32
          self.spawn_bottom_pipe(world, spawn_x, spawn_height.to_f32)
          self.spawn_top_pipe(world, spawn_x, (0 - height_diff).to_f32)
          self.spawn_score_trigger(world, spawn_x + SCORE_TRIGGER_OFFSET)
        end
      end
    end

    def self.spawn_bottom_pipe(world : World, x : Float32, y : Float32)
      Assembly.bottom_pipe(world, x, y)
    end

    def self.spawn_top_pipe(world : World, x : Float32, y : Float32)
      Assembly.top_pipe(world, x, y)
    end

    def self.spawn_score_trigger(world : World, x : Float32)
      Assembly.score_trigger(world, x)
    end

    def self.spawn_bird(world : World)
      Assembly.bird(world)
    end
  end
end
