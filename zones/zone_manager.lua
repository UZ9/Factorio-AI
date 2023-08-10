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

function ZoneManager:get_available_zone(type)
    if self.zones[type] then 
        return self.zones[type][1]
    else
        error(serpent.block({"ZONE NOT FOUND", type, self.zones}))
        return
    end
end

return ZoneManager
