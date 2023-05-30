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

    def self.gameover_color
        SF::Color.new(0, 0, 0, 100)
    end
end