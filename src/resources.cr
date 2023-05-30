require "crsfml"

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