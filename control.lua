--control.lua
require "tasks/objective"
require "path_tile"
require "tasks/objective_walk_to_location"

local SEARCH_OFFSET = 1
local GLOBAL_SURFACE_MAP = {{-32, -32}, {32, 32}}
local init_armor = 1
local init_scan = 1
local map_width = 256
local map_height = 256
local moveDiagonal = 1
local moveHorizontal = 0
local moveVertical = 0
local success_flag = 0
local done = false

local currentObjective = {}

local entity

local line

local asharp = false

script.on_event(
  {defines.events.on_tick},
  function(e)
    if e.tick % 1 == 0 then
      if done == true then
        do
          return
        end
      end
      for index, player in pairs(game.connected_players) do
        if init_armor == 1 then
          player.begin_crafting {count = 1, recipe = "autopilot-armor"}
          init_armor = 0
        end
        if
          player.character and
            player.get_inventory(defines.inventory.character_armor).get_item_count("autopilot-armor") > 0
         then
          if currentObjective[1] then
            if currentObjective[1]:finished {} then
              player.print("Finished Task")
              table.remove(currentObjective, 1)
            else
              currentObjective[1]:tick {event = e, p = player}
            end
          else
            player.print("Finished All Tasks")
            done = true
          end
        else
          player.color = {r = 255, g = 140, b = 0, a = 1}
          player.character_running_speed_modifier = 0
          ironCount = 0
        end
      end
    end
  end
)

function contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local openList = {}
local closedList = {}

function tablelength(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

local function getChildren(tilePos)
  tiles = {}

  table.insert(tiles, PathTile:new {parent = tilePos, x = tilePos.x + 1, y = tilePos.y})
  table.insert(tiles, PathTile:new {parent = tilePos, x = tilePos.x, y = tilePos.y + 1})
  table.insert(tiles, PathTile:new {parent = tilePos, x = tilePos.x + 1, y = tilePos.y + 1})
  table.insert(tiles, PathTile:new {parent = tilePos, x = tilePos.x - 1, y = tilePos.y})
  table.insert(tiles, PathTile:new {parent = tilePos, x = tilePos.x, y = tilePos.y - 1})
  table.insert(tiles, PathTile:new {parent = tilePos, x = tilePos.x - 1, y = tilePos.y - 1})
  table.insert(tiles, PathTile:new {parent = tilePos, x = tilePos.x + 1, y = tilePos.y - 1})
  table.insert(tiles, PathTile:new {parent = tilePos, x = tilePos.x - 1, y = tilePos.y + 1})

  return tiles
end

local function containsNode(list, child) 
  dont = false
  for index, open_node in pairs(list) do
    if child.x == open_node.x and child.y == open_node.y then
      dont = true
    --break
    end
  end
  return dont 
end

local function asharp(startPos, endPos)
  table.insert(openList, startPos)

  log("{")

  while next(openList) ~= nil do
    --log(tablelength(openList))
    currentNode = openList[1]
    currentIndex = 1

    for k = 1, #openList do
      item = openList[k]
      if item.g + item.h < currentNode.g + currentNode.h then
        currentNode = item
        currentIndex = k
      end
    end

    if currentNode.x == endPos.x and currentNode.y == endPos.y then
      path = {}
      curr = currentNode
      while curr ~= nil do
        table.insert(path, curr)
        curr = curr.parent
      end
      return path
    end

    table.remove(openList, currentIndex)
    table.insert(closedList, currentNode)

    adjacent = getChildren(currentNode)

    applicableChildren = {}

    for j = 1, #adjacent do
      child = adjacent[j]

      if
        containsNode(closedList, child) == false and
          game.surfaces[1].get_tile({x = child.x, y = child.y}).collides_with("player-layer") == false and
          game.surfaces[1].count_entities_filtered {
            area = {{x = child.x, y = child.y}, {x = child.x + 1, y = child.y + 1}},
            limit = 1
          } == 0
       then
        table.insert(applicableChildren, child)
      end
    end

    for i = 1, #applicableChildren do
      child = applicableChildren[i]
      child.g = currentNode.g + 1
      --((child.position[0] - end_node.position[0]) ** 2) + ((child.position[1] - end_node.position[1]) ** 2)
      child.h = (math.abs(math.pow(child.x - endPos.x, 2))) + (math.abs(math.pow(child.y - endPos.y, 2)))
      dont = false

      for index, open_node in pairs(openList) do
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

script.on_init(
  function()
    for index, player in pairs(game.connected_players) do
      player.print("Starting....")

      endPos = PathTile.new {x = 80, y = -20}

      
      if
        game.surfaces[1].count_entities_filtered {
          area = {{x = endPos.x, y = endPos.y}, {x = endPos.x + 1, y = endPos.y + 1}},
          limit = 1
        } == 0
       then
        list = asharp(PathTile:new {x = player.position.x, y = player.position.y}, endPos)

        for i = #list, 1, -1 do
          element = list[i]
          rendering.draw_rectangle {
            color = {r = 0, g = 1, b = 0, a = 1},
            filled = true,
            left_top = {element.x, element.y},
            right_bottom = {element.x + 1, element.y + 1},
            surface = game.surfaces[1]
          }

          table.insert(currentObjective, WalkToLocationObjective:new {target = {x = element.x, y = element.y}})
        end
      else
        player.print("Invalid Tile")
      end

    end
  end
)
