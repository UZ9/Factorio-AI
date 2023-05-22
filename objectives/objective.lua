Objective = {}

Objective.done = false

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

function Objective:cleanup(par)

    if self.tag then
        par.p.print("Adding pos for " .. self.tag)
        par.previous_positions[self.tag] = par.p.position
    end
end
