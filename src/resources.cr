require "crsfml"
require "crsfml/audio"

module Resources
    def self.bird_texture
        SF::Texture.from_file("resources/bird.png")
    end

    def self.bottom_pipe_texture
        SF::Texture.from_file("resources/longpipe.png")
    end
    
    def self.top_pipe_texture
        SF::Texture.from_file("resources/longpipedown.png")
    end

    def self.font
        SF::Font.from_file("resources/font.ttf")
    end

    def self.black_background_color
        SF::Color.new(0, 0, 0, 100)
    end

    def self.music
        SF::Music.from_file("resources/crappy_bird.ogg")
    end

    def self.jump_sound
        SF::SoundBuffer.from_file("resources/jump.wav")
    end

    def self.death_sound
        SF::SoundBuffer.from_file("resources/hitHurt.wav")
    end

    def self.start_sound
        SF::SoundBuffer.from_file("resources/start.wav")
    end

    def self.text
      text = SF::Text.new
      text.font = self.font
      text.color = SF::Color::White
      text.outline_color = SF::Color::Black
      text.outline_thickness = 2
      text.style = SF::Text::Bold

      text
    end
end