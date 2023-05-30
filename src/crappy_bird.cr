# Load libs
require "crsfml"
require "./ecs"
require "./components"
require "./assemblies"
require "./systems"

# Load resources
bird_texture = SF::Texture.from_file("resources/bird.png")

# Set up ECS
include ECS
include Systems

# Create window
window = SF::RenderWindow.new(SF::VideoMode.new(480, 640), "Crappy Bird")
window.framerate_limit = 144

# Set up clock
clock = SF::Clock.new

# Main game loop
while window.open?
  while event = window.poll_event
    case event 
    when SF::Event::Closed
      window.close
    when SF::Event::KeyPressed
      Input.update(window, Game.world, event)
    end
  end
  
  Spawner.update(Game.world)
  
  Physics.update(Game.world, clock)

  Render.draw(window, Game.world)
end
