PathTile = {}

function PathTile:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.g = 0
    o.h = 0
    return o
end
