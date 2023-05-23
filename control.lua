--control.lua
require "objectives/objective"
require "path_tile"
require "objectives/objective_walk_to_location"
require "objectives/objective_pathfind_to_location"
require "objectives/objective_find_ore"
require "objectives/objective_build_structure"
require "objectives/objective_mine_resources"
require "objectives/objective_insert_materials"

local SEARCH_OFFSET = 1
local GLOBAL_SURFACE_MAP = { { -32, -32 }, { 32, 32 } }
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
  FindOreObjective:new { entityType = "iron-ore" },
  BuildStructureObjective:new { type = "burner-mining-drill", target = { x = 0, y = 0 } }, --target is relative to player position
  BuildStructureObjective:new { type = "stone-furnace", target = { x = 1, y = 1 }, tag = "initial-burner" },
  FindOreObjective:new { entityType = "coal", tag = "coal-deposit-1" },
  MineResourcesObjective:new {type = "coal", amount = 10},

  PathfindToLocationObjective:new { previous_positions = previous_positions, target = "initial-burner" },
  InsertMaterialsObjective:new { to_insert = { name = "coal", count = 5 }, target = "stone-furnace" },
  InsertMaterialsObjective:new { to_insert = { name = "coal", count = 5 }, target = "burner-mining-drill" },
  InsertMaterialsObjective:new { to_insert = { name = "coal", count = 5 }, target = "stone-furnace" }
}

local entity

local line

local asharp = false



script.on_event(
  { defines.events.on_tick },
  function(e)


    if e.tick % 1 == 0 then
      if done == true then
        do
          return
        end
      end
      for index, player in pairs(game.connected_players) do
        if init_armor == 1 then
          player.begin_crafting { count = 1, recipe = "ai-armor" }

          init_armor = 0
        end
        if
            player.character and
            player.get_inventory(defines.inventory.character_armor).get_item_count("ai-armor") > 0
        then
          if currentObjective[1] then
            if currentObjective[1]:finished { event = e, p = player, currentObjectiveTable = currentObjective, game =
                game, rendering = rendering } then
              player.print("Finished Task")


              currentObjective[1]:cleanup { rendering = rendering, previous_positions = previous_positions, p = player }
              table.remove(currentObjective, 1)

              if (currentObjective[1]) then
                player.set_goal_description(currentObjective[1]:get_name(), true)
                currentObjective[1]:tick { event = e, p = player, previous_positions = previous_positions, currentObjectiveTable =
                currentObjective, game = game, rendering = rendering }
              end



              if #previous_positions > 0 then
                player.print("YEET")
              end
            else
              currentObjective[1]:tick { event = e, previous_positions = previous_positions, p = player, currentObjectiveTable =
              currentObjective, game = game, rendering = rendering }
            end
          else
            player.print("Finished All Tasks")
            done = true
          end
        else
          player.color = { r = 255, g = 140, b = 0, a = 1 }
          --player.character_running_speed_modifier = 0
          ironCount = 0
        end
      end
    end
  end
)
