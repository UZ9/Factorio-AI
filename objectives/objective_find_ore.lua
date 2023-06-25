require "objective"
require "objective_walk_to_location"
require "zones/zone"
require "zones/zone_ore"
require "patterns/pattern_burner_mining"

FindOreObjective = PathfindToLocationObjective:new()

FindOreObjective.currentRenderingTiles = {}
FindOreObjective.center = false

local function round(value)
    return math.floor(value + 0.5)
end

function collidesWith(position, game)
    tile = game.surfaces[1].get_tile { x = position.x, y = position.y }
    if tile.collides_with("player-layer") == false and
        game.surfaces[1].count_entities_filtered {
            area = { tile.position, { x = tile.position.x + 1, y = tile.position.y + 1 } },
            limit = 1,
            collision_mask = "player-layer"
        } == 0
    then
        return true
    else
        return false
    end
end

function FindOreObjective:finished(par)
    return self.done
end

function FindOreObjective:findOrePatch(par)
    local foundOre = findOre(par.p, par.game, self.entityType)

    if foundOre == nil then
        return nil
    end

    local searchSize = 1

    local foundEntity = nil

    local count = 0

    local found_layer = false
    local foundEntities = {}

    local minX = 999999999
    local minY = 999999999
    local maxX = -999999999
    local maxY = -999999999

    while foundEntity == nil do
        foundEntities = game.surfaces[1].find_entities_filtered {
            area = {
                { x = foundOre.position.x - searchSize, y = foundOre.position.y - searchSize },
                { x = foundOre.position.x + searchSize, y = foundOre.position.y + searchSize }
            },
            name = self.entityType
        }

        for i = 1, #foundEntities do
            local pos = foundEntities[i].position

            if collidesWith(pos, game) == true then
                if pos.x < minX then
                    minX = pos.x
                elseif pos.x > maxX then
                    maxX = pos.x
                end

                if pos.y < minY then
                    minY = pos.y
                elseif pos.y > maxY then
                    maxY = pos.y
                end

                found_layer = true
            end
        end

        if found_layer == false or searchSize > 30 then
            return { foundEntities = foundEntities, minX = minX, maxX = maxX, minY = minY, maxY = maxY }
        end

        searchSize = searchSize + 2
        found_layer = false
    end
end

function findOre(player, game, entityType)
    local searchSize = 5

    local foundEntity = nil

    local count = 0

    while foundEntity == nil do
        if searchSize > 1000 then
            return nil
        end

        local foundEntities = game.surfaces[1].find_entities_filtered {
            area = {
                { x = player.position.x - searchSize, y = player.position.y - searchSize },
                { x = player.position.x + searchSize, y = player.position.y + searchSize }
            },
            name = entityType
        }

        for i = 1, #foundEntities do
            if collidesWith(foundEntities[i].position, game) == true then
                return foundEntities[i]
            end
        end

        searchSize = searchSize + 5
    end
end

function FindOreObjective:tick(par)
    if self.done == true then
        return
    end

    if self.target == null then
        local orePatch = self:findOrePatch(par)

        if orePatch == nil then
            par.p.print("No ore patch found with type " .. self.entityType)
            self.done = true
            return
        end

        local zone = OreZone:new { type = self.entityType, entities = orePatch.foundEntities,
            bounds = { minX = orePatch.minX, maxX = orePatch.maxX, minY = orePatch.minY, maxY = orePatch.maxY } }

        zone:draw { game = par.game, fill = false, rendering = par.rendering }

        par.zone_manager:register_zone(zone)

        -- Objective: build to zone

        local pattern = BurnerMiningPattern:new {}
        pattern:apply_pattern(par.rendering, par.game, par.p, zone, 1)
        pattern:apply_pattern(par.rendering, par.game, par.p, zone, 3)

        pattern:build_next { current_objective = par.currentObjectiveTable, rendering = par.rendering, game = par.game, player = par.p  }

        if par.previous_positions[self.entityType] == nil then
            par.previous_positions[self.entityType] = {}
        end

        for entityIndex = 1, #orePatch.foundEntities do
            local orePatchPos = orePatch.foundEntities[entityIndex].position
            local centerPos = zone.center

            local distPos = { x = math.abs(orePatchPos.x - centerPos.x), y = math.abs(orePatchPos.y - centerPos.y) }

            if (distPos.x == 0 and distPos.y == 0) then
                local foundOre = orePatch.foundEntities[entityIndex]

                self.target = PathTile:new { x = math.floor(foundOre.position.x), y = math.floor(foundOre.position.y) }
                self.done = true
            end
        end
    end

    if game.surfaces[1].count_entities_filtered {
        area = { { x = self.target.x, y = self.target.y }, { x = self.target.x + 1, y = self.target.y + 1 } },
        limit = 1,
        collision_mask = "player-layer"
    } == 0
    then
        local list = astar(PathTile:new { x = round(par.p.position.x), y = round(par.p.position.y) }, self.target)

        if list then

            for i = 1, #list do
                local element = list[i]

                local movementOrder = WalkToLocationObjective:new { target = { x = element.x, y = element.y } }


                movementOrder.renderingTile = par.rendering.draw_rectangle {
                    color = { r = 0, g = 1, b = 0, a = 1 },
                    filled = true,
                    left_top = { element.x, element.y },
                    right_bottom = { element.x + 1, element.y + 1 },
                    surface = game.surfaces[1],
                    only_in_alt_mode = true
                }

                if i == 1 then
                    movementOrder.tag = self.tag
                    self.tag = nil
                end

                table.insert(par.currentObjectiveTable, 2, movementOrder)
            end
        end


        self.done = true
    else
        par.p.print("Invalid Tile")
        self.done = true
    end
end
