--control.lua
require "objectives/objective"
require "path_tile"
require "objectives/objective_walk_to_location"
require "objectives/objective_pathfind_to_location"
require "objectives/objective_find_ore"
require "objectives/objective_build_structure"
require "objectives/objective_mine_resources"

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

local previous_positions = {}

local currentObjective = {
  -- FindOreObjective:new {entityType = "iron-ore"},
  -- BuildStructureObjective:new {type = "burner-mining-drill", target = {x=0,y=0}, tag="initial-burner"}, --target is relative to player position
  -- BuildStructureObjective:new {type = "stone-furnace", target = {x=1,y=1}},
  FindOreObjective:new {entityType = "coal", tag="coal-deposit-1"},
  -- MineResourcesObjective:new {type = "coal", amount = 20}

  --PathfindToLocationObjective:new{target={x = 84, y = -42}}
}

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
          player.begin_crafting {count = 1, recipe = "ai-armor"}
          init_armor = 0
        end
        if
          player.character and
            player.get_inventory(defines.inventory.character_armor).get_item_count("ai-armor") > 0
         then
          if currentObjective[1] then
            if currentObjective[1]:finished{event = e, p = player, currentObjectiveTable = currentObjective, game = game, rendering = rendering} then
              player.print("Finished Task")

              currentObjective[1]:cleanup{ previous_positions = previous_positions, p = player }
              table.remove(currentObjective, 1)

              if (currentObjective[1]) then
                currentObjective[1]:tick {event = e, p = player, currentObjectiveTable = currentObjective, game = game, rendering = rendering}
              end

              player.print(serpent.block(previous_positions))


              if #previous_positions > 0 then
                player.print("YEET")
              end
            else
              currentObjective[1]:tick {event = e, p = player, currentObjectiveTable = currentObjective, game = game, rendering = rendering}
            end
          else
            player.print("Finished All Tasks")
            done = true
          end
        else
          player.color = {r = 255, g = 140, b = 0, a = 1}
          --player.character_running_speed_modifier = 0
          ironCount = 0
        end
      end
    end
  end
)
