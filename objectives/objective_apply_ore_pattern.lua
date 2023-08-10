require "objective"

ApplyOrePatternObjective = Objective:new()

ApplyOrePatternObjective.zone_type = ""
ApplyOrePatternObjective.started = false

local zone_manager = require "zones/zone_manager"

function ApplyOrePatternObjective:finished(par)
    return self.started
end

function ApplyOrePatternObjective:get_name()
    return "ApplyOrePatternObjective";
end

function ApplyOrePatternObjective:tick(par)
    if self.started == false then
        -- Objective: build to zone



        local zone = zone_manager:get_available_zone(self.zone_type)

        if zone then
            local pattern = zone.pattern

            pattern:apply_pattern(par.rendering, par.game, par.p, zone, 1)
        else 
            error("NO ZONE FOUND FOR APPLY ORE PATTERN")
        end

        self.started = true
    end
end
