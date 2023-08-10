require "objective"

BuildOnOrePatternObjective = Objective:new()

BuildOnOrePatternObjective.zone_type = ""
BuildOnOrePatternObjective.started = false

local zone_manager = require "zones/zone_manager"

function BuildOnOrePatternObjective:finished(par)
    return self.started
end

function BuildOnOrePatternObjective:get_name()
    return "ApplyOrePatternObjective";
end

function BuildOnOrePatternObjective:tick(par)
    if self.started == false then
        -- Objective: build to zone



        local zone = zone_manager:get_available_zone(self.zone_type)

        if zone then
            local pattern = zone.pattern

            local entity_count = {}


            for _, patternEntity in ipairs(pattern:get_pattern_entities()) do

                if entity_count[patternEntity.name] then
                    entity_count[patternEntity.name] = entity_count[patternEntity] + 1
                else
                    entity_count[patternEntity.name] = 1
                end
            end

            for entity_type, count in pairs(entity_count) do
                if par.p.get_inventory(defines.inventory.character_main).get_item_count(entity_type) < count then
                    par.p.print("Missing crucial item: " .. entity_type)
                end
            end

            par.p.print(serpent.block(pattern))

            pattern:build_next { current_objective = par.currentObjectiveTable, rendering = par.rendering,
                game = par.game,
                player = par.p }

        else 
            error("NO ZONE FOUND FOR APPLY ORE PATTERN")
        end

        self.started = true
    end
end
