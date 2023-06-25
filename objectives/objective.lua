Objective = {}

Objective.done = false
Objective.finish_function = function(par) end

function Objective:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Objective:finished(par)
    return false
end

function Objective:tick(par)
end

function Objective:get_name()
    return "Objective"
end

function Objective:cleanup(par)

    if self.tag then
        newPos = {
            x = par.p.position.x - par.p.position.x % 1,
            y = par.p.position.y - par.p.position.y % 1
        }

        par.p.print("Adding pos for " .. self.tag)
        par.previous_positions[self.tag] = newPos

        par.rendering.draw_rectangle {
            color = { r = 1, g = 0, b = 0, a = 1 },
            filled = true,
            left_top = { newPos.x, newPos.y },
            right_bottom = { newPos.x + 1, newPos.y + 1 },
            surface = game.surfaces[1],
            only_in_alt_mode = true
        }

        par.rendering.draw_text { text = self.tag, target = newPos, surface = game.surfaces[1], only_in_alt_mode = true,
            color = { r = 1, g = 1, b = 1, a = 1 } }
    end

    self.finish_function(par)
end
