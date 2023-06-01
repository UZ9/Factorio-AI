require "zone"
require "patterns/pattern_burner_mining"

OreZone = Zone:new()

OreZone.someValue = true
OreZone.pattern = BurnerMiningPattern:new{}

function OreZone:draw(par)
    self:draw_outline(par)
    self:draw_label(par)
    self:draw_center(par)

    -- Shade ore if enabled
    if par.fill then 
        for i = 1, #self.entities do
            element = self.entities[i].position
    
            par.rendering.draw_rectangle {
                color = { r = 0, g = 0, b = 1, a = 0.1 },
                filled = true,
                left_top = { element.x - 0.5, element.y - 0.5 },
                right_bottom = { element.x + 0.5, element.y + 0.5 },
                surface = par.game.surfaces[1],
                only_in_alt_mode = true
            }
        end
    end
end

function OreZone:apply_pattern(par)

end
