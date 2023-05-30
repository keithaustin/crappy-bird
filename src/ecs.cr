module ECS
  class Entity
    @components = Hash(Component.class, Component).new

    def get(subclass : Component.class) : Component
      subinstance = @components[subclass].downcast
      subclass.cast subinstance
    end

    def has?(subclass : Component.class)
      @components.has_key?(subclass)
    end
  end

  abstract class Component
    abstract def component : Component.class

    def downcast
      component_type = self.component
      component_type.cast self
    end
  end

  class World
    @@registry = {} of Entity => Set(Component.class)

    def register(entity : Entity)
      unless @@registry.has_key?(entity)
        @@registry[entity] = Set(Component.class).new
      end
    end

    def attach(entity : Entity, component : Component)
      
      self.register(entity)

      component_class = component.component
      real_component = component.downcast

      @@registry[entity] << component_class

      entity.@components[component_class] = real_component
    end

    def detach(entity : Entity, component : Component)
      component_class = component.component

      @registry[entity].delete(component_class)
      entity.@components.delete(component_class)
    end

    def entities_with(components : Set(Component.class)) : Set(Entity)
      result = Set(Entity).new
      @@registry.each do |e, c|
        if c.superset_of?(components)
          result << e 
        end
      end

      result
    end

    def entities_without(components : Set(Component.class)) : Set(Entity)
      result = Set(Entity).new
      
      @@registry.each do |e, c|
        unless c.superset_of?(components)
          result << e 
        end
      end

      result
    end

    def first_entity_with(components : Set(Component.class)) : Entity
      result = nil
      @@registry.each do |e, c|
        if c.superset_of?(components)
          result = e
          break
        end
      end

      result
    end

    def remove_entity(entity : Entity)
      if @@registry.has_key?(entity)
        @@registry.delete(entity)
      end
    end

    def dispose
      @@registry = {} of Entity => Set(Component.class)
    end

    def pretty_print
      @@registry.each do |k, v|
        puts "#{k} -----"
        v.each do |component|
          puts "#{component}"
        end
        puts "-----"
      end
    end
  end
end
