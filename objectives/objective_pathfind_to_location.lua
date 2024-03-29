require "objective"
require "objective_walk_to_location"

PathfindToLocationObjective = WalkToLocationObjective:new()



local TILE_RADIUS = 0.01


local function round(value)
    return math.floor(value + 0.5)
end

local function collidesWith(position, game)
    local tile = game.surfaces[1].get_tile { x = position.x, y = position.y }
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

function PathfindToLocationObjective:finished(par)
    return self.done == true
end

local function getChildren(tilePos)
    local tiles = {
        PathTile:new { parent = tilePos, x = tilePos.x + 1, y = tilePos.y },
        PathTile:new { parent = tilePos, x = tilePos.x, y = tilePos.y + 1 },
        PathTile:new { parent = tilePos, x = tilePos.x + 1, y = tilePos.y + 1 },
        PathTile:new { parent = tilePos, x = tilePos.x - 1, y = tilePos.y },
        PathTile:new { parent = tilePos, x = tilePos.x, y = tilePos.y - 1 },
        PathTile:new { parent = tilePos, x = tilePos.x - 1, y = tilePos.y - 1 },
        PathTile:new { parent = tilePos, x = tilePos.x + 1, y = tilePos.y - 1 },
        PathTile:new { parent = tilePos, x = tilePos.x - 1, y = tilePos.y + 1 }
    }

    return tiles
end

local function containsNode(list, child)
    local dont = false
    for index, open_node in pairs(list) do
        if child.x == open_node.x and child.y == open_node.y then
            dont = true
            --break
        end
    end
    return dont
end

function astar(startPos, endPos)

    local openList = {}
    local closedList = {}

    table.insert(openList, startPos)

    local current_iteration = 0


    while next(openList) ~= nil do
        if current_iteration > 100 then
            return nil
        end

        print(current_iteration)

        current_iteration = current_iteration + 1
        --log(#openList)
        local currentNode = openList[1]
        local currentIndex = 1

        for k = 1, #openList do
            item = openList[k]
            if item.g + item.h < currentNode.g + currentNode.h then
                currentNode = item
                currentIndex = k
            end
        end

        if currentNode.x == endPos.x and currentNode.y == endPos.y then
            local path = {}
            local curr = currentNode
            while curr ~= nil do
                table.insert(path, curr)
                curr = curr.parent
            end
            return path
        end

        --log(currentNode.x .. ", " .. currentNode.y)

        table.remove(openList, currentIndex)
        table.insert(closedList, currentNode)

        local adjacent = getChildren(currentNode)

        local applicableChildren = {}

        for j = 1, #adjacent do
            child = adjacent[j]

            if containsNode(closedList, child) == false and
                collidesWith({ x = child.x, y = child.y }, game) == true
            then
                table.insert(applicableChildren, child)
            end
        end

        for i = 1, #applicableChildren do
            local child = applicableChildren[i]
            child.g = currentNode.g + 1
            --((child.position[0] - end_node.position[0]) ** 2) + ((child.position[1] - end_node.position[1]) ** 2)
            child.h = (math.abs(math.pow(child.x - endPos.x, 2))) + (math.abs(math.pow(child.y - endPos.y, 2)))
            local dont = false

            for _, open_node in pairs(openList) do
                if child.x == open_node.x and child.y == open_node.y then
                    dont = true
                    --break
                end
            end

            if dont == false then
                table.insert(openList, child)
            end
        end
    end
end

function PathfindToLocationObjective:tick(par)
    if self.done == true then
        return
    end

    if self.position == nil then
        if type(self.target) == "table" then
            self.position = {
                x = math.floor(par.p.position.x) + self.target.x,
                y = math.floor(par.p.position.y) + self.target.y
            }
        else
            -- print(par.previous_positions)
            -- print(self.target)

            self.position = {
                x = par.previous_positions[self.target].x,
                y = par.previous_positions[self.target].y
            }
        end
    end

    self.target = self.position

    if game.surfaces[1].count_entities_filtered {
        area = { { x = self.target.x, y = self.target.y }, { x = self.target.x + 1, y = self.target.y + 1 } },
        limit = 1,
        collision_mask = "player-layer"
    } == 0
    then
        player.print("Calculating astar")

        list = astar(PathTile:new { x = round(par.p.position.x), y = round(par.p.position.y) }, self.target)

        if list == nil then
            player.print("Exceeded pathfinding step count")
            self.done = true
            return
        end

        for i = 1, #list do
            element = list[i]
            player.print("Drawing rectangle")
            rendering.draw_rectangle {
                color = { r = 0, g = 1, b = 0, a = 1 },
                filled = false,
                left_top = { element.x, element.y },
                right_bottom = { element.x + 1, element.y + 1 },
                surface = game.surfaces[1],
                only_in_alt_mode = true
            }

            table.insert(par.currentObjectiveTable, 2,
                WalkToLocationObjective:new { target = { x = element.x, y = element.y } })
        end

        self.done = true
    else
        par.p.print("Invalid Tile")
        self.done = true
    end
end
