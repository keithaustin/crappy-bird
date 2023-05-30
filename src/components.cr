require "./ecs"

include ECS

class PlayerController < Component
    def component : Component.class
        PlayerController
    end
end

class Sprite < Component
  def component : Component.class
    Sprite
  end

  def initialize(@sprite : SF::Sprite)
  end

  def sprite
    @sprite
  end

  def set_position(position : SF::Vector2f)
    @sprite.set_position(position.x, position.y)
  end
end

class Speed < Component
    getter speed
    setter speed
    def component : Component.class
        Speed
    end

    def initialize(@speed : Float = 0.0)
    end
end

class Collider < Component
  def component : Component.class 
    Collider
  end
end

class ScoreTrigger < Component
  getter x
  setter x
  def component : Component.class
    ScoreTrigger
  end

  def initialize(@x : Float32)
  end
end

class Pipe < Component
  def component : Component.class
    Pipe
  end
end
