local ZoneManager = {}

ZoneManager.zones = {}

function ZoneManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ZoneManager:register_zone(zone)
    if not self.zones[zone.type] then
        self.zones[zone.type] = {}
    end

    table.insert(self.zones[zone.type], zone)
end

return ZoneManager
