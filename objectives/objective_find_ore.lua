require "objective"
require "objective_walk_to_location"

FindOreObjective = PathfindToLocationObjective:new()

FindOreObjective.currentRenderingTiles = {}

local TILE_RADIUS = 0.3

local function round(value)
    return math.floor(value + 0.5)
end

function collidesWith(position, game)
    tile = game.surfaces[1].get_tile {x = position.x, y = position.y}
    if
        tile.collides_with("player-layer") == false and
            game.surfaces[1].count_entities_filtered {
                area = {tile.position, {x = tile.position.x + 1, y = tile.position.y + 1}},
                limit = 1,
                collision_mask = "player-layer"
            } == 0
     then
        game.players[1].print("Found one at " .. tile.position.x .. ", " .. tile.position.y)
        return true
    else
        return false
    end
end

function FindOreObjective:finished(par)
    if self.done == true then
        return true
    else
        return false
    end
end

function findOre(player, game, entityType)
    searchSize = 5

    foundEntity = nil

    count = 0

    while foundEntity == nil do
        foundEntities =
            game.surfaces[1].find_entities_filtered {
            area = {
                {x = player.position.x - searchSize, y = player.position.y - searchSize},
                {x = player.position.x + searchSize, y = player.position.y + searchSize}
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
        foundOre = findOre(par.p, par.game, self.entityType)
        self.target = PathTile:new {x = math.floor(foundOre.position.x), y = math.floor(foundOre.position.y)}
        self.done = true
    end

    if
        game.surfaces[1].count_entities_filtered {
            area = {{x = self.target.x, y = self.target.y}, {x = self.target.x + 1, y = self.target.y + 1}},
            limit = 1,
            collision_mask = "player-layer"
        } == 0
     then
        list = asharp(PathTile:new {x = round(par.p.position.x), y = round(par.p.position.y)}, self.target)

        for i = 1, #list do
            element = list[i]

            movementOrder = WalkToLocationObjective:new {target = {x = element.x, y = element.y}}

            movementOrder.renderingTile =
                par.rendering.draw_rectangle {
                color = {r = 0, g = 1, b = 0, a = 1},
                filled = true,
                left_top = {element.x, element.y},
                right_bottom = {element.x + 1, element.y + 1},
                surface = game.surfaces[1],
                only_in_alt_mode = true
            }

            table.insert(par.currentObjectiveTable, 2, movementOrder)
        end

        self.done = true
    else
        par.p.print("Invalid Tile")
        self.done = true
    end
end
