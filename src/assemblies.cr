require "./ecs"
require "./components"
require "./resources"

include ECS

module Assembly
  def self.bird(world : World)
    texture = Resources.bird_texture
    bird = Entity.new
    world.attach bird, Sprite.new(SF::Sprite.new(texture))
    world.attach bird, PlayerController.new
    world.attach bird, Speed.new
    world.attach bird, Collider.new

    bird.get(Sprite).sprite.origin = texture.size / 2.0
    bird.get(Sprite).sprite.scale = SF.vector2(2.5, 2.5)
    bird.get(Sprite).sprite.set_position(100, 300)

    bird
  end

  def self.bottom_pipe(world : World, x : Float32, y : Float32)
    pipe = Entity.new
    world.attach pipe, Sprite.new(SF::Sprite.new(Resources.bottom_pipe_texture))
    world.attach pipe, Speed.new(-196.0)
    world.attach pipe, Collider.new
    world.attach pipe, Pipe.new

    pipe.get(Sprite).sprite.scale = SF.vector2(0.5, 0.5)
    pipe.get(Sprite).sprite.set_position(x, y)

    pipe
  end

  def self.top_pipe(world : World, x : Float32, y : Float32)
    pipe = Entity.new
    world.attach pipe, Sprite.new(SF::Sprite.new(Resources.top_pipe_texture))
    world.attach pipe, Speed.new(-196.0)
    world.attach pipe, Collider.new
    world.attach pipe, Pipe.new

    pipe.get(Sprite).sprite.scale = SF.vector2(0.5, 0.5)
    pipe.get(Sprite).sprite.set_position(x, y)
  end

  def self.score_trigger(world : World, x : Float32)
    score_trigger = Entity.new
    world.attach score_trigger, ScoreTrigger.new(x)
    world.attach score_trigger, Speed.new(-196.0)
  end
end
