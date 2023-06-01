Zone = {}

Zone.bounds = {}
Zone.label = "UNMARKED_ZONE"

function Zone:new(o)
    if o then
        o.center = { x = o.bounds.minX + math.ceil((o.bounds.maxX - o.bounds.minX) / 2.0),
        y = o.bounds.minY + math.ceil((o.bounds.maxY - o.bounds.minY) / 2.0) }
    else 
        o = {}
    end

    setmetatable(o, self)
    self.__index = self


    return o
end

function Zone:draw_center(par)
    par.rendering.draw_rectangle {
        color = { r = 0.3, g = 0.6, b = 1, a = 0.1 },
        filled = false,
        left_top = { self.center.x - 0.5,
        self.center.y - 0.5 },
        right_bottom = { self.center.x + 0.5,
        self.center.y + 0.5 },
        surface = par.game.surfaces[1],
        only_in_alt_mode = true
    }
end

--- Draws text label for zone
function Zone:draw_label(par)
    par.rendering.draw_text { text = self.label, target = { x = self.bounds.minX + 1, y = self.bounds.minY + 1 },
        surface = par.game.surfaces[1], only_in_alt_mode = true,
        color = { r = 1, g = 1, b = 1, a = 1 } }
end

---Draws the bounds of a zone
function Zone:draw_outline(par)
    for x = self.bounds.minX, self.bounds.maxX do
        par.rendering.draw_rectangle {
            color = { r = 1, g = 0, b = 1, a = 0.1 },
            filled = false,
            left_top = { x - 0.5, self.bounds.minY - 0.5 },
            right_bottom = { x + 0.5, self.bounds.minY + 0.5 },
            surface = par.game.surfaces[1],
            only_in_alt_mode = true
        }
        par.rendering.draw_rectangle {
            color = { r = 1, g = 0, b = 1, a = 0.1 },
            filled = false,
            left_top = { x - 0.5, self.bounds.maxY - 0.5 },
            right_bottom = { x + 0.5, self.bounds.maxY + 0.5 },
            surface = par.game.surfaces[1],
            only_in_alt_mode = true
        }
    end

    for y = self.bounds.minY, self.bounds.maxY do
        rendering.draw_rectangle {
            color = { r = 1, g = 0, b = 1, a = 0.1 },
            filled = false,
            left_top = { self.bounds.minX - 0.5, y - 0.5 },
            right_bottom = { self.bounds.minX + 0.5, y + 0.5 },
            surface = par.game.surfaces[1],
            only_in_alt_mode = true
        }
        rendering.draw_rectangle {
            color = { r = 1, g = 0, b = 1, a = 0.1 },
            filled = false,
            left_top = { self.bounds.maxX - 0.5, y - 0.5 },
            right_bottom = { self.bounds.maxX + 0.5, y + 0.5 },
            surface = par.game.surfaces[1],
            only_in_alt_mode = true
        }
    end
end

function Zone:draw(par)
    self:draw_outline(par)
    self:draw_label(par)
    self:draw_center(par)
end
