--control.lua
require "objectives/objective"
require "objectives/objective_retrieve_from_entity"
require "path_tile"
require "objectives/objective_walk_to_location"
require "objectives/objective_pathfind_to_location"
require "objectives/objective_find_ore"
require "objectives/objective_build_structure"
require "objectives/objective_mine_resources"
require "objectives/objective_insert_materials"
require "objectives/objective_craft_items.lua"
require "util/util"
require "objectives/objective_wait_for_async.lua"
require "goals/goal_recipe"

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

local currentObjective = {}

local oreTest = {
  FindOreObjective:new { entityType = "iron-ore" },
}

local buildTest = {
  BuildStructureObjective:new { type = "burner-mining-drill", target = { x = 0, y = 0 } }, --target is relative to player position
  BuildStructureObjective:new { type = "stone-furnace", target = { x = 1, y = 1 }, tag = "initial-burner" },
}

local fullObjectives = {
  FindOreObjective:new { entityType = "iron-ore" },
  BuildStructureObjective:new { type = "burner-mining-drill", target = { x = 0, y = 0 } }, --target is relative to player position
  BuildStructureObjective:new { type = "stone-furnace", target = { x = 1, y = 1 }, tag = "initial-burner" },
  FindOreObjective:new { center = true, entityType = "coal", tag = "coal-deposit-1" },
  MineResourcesObjective:new { type = "coal", amount = 10 },
  PathfindToLocationObjective:new { previous_positions = previous_positions, target = "initial-burner" },
  InsertMaterialsObjective:new { targetPos = { x = 0, y = 0 }, to_insert = { name = "coal", count = 5 },
    target = "stone-furnace" },
  InsertMaterialsObjective:new { targetPos = { x = 0, y = -2 }, to_insert = { name = "coal", count = 5 },
    target = "burner-mining-drill" },
  RetrieveFromEntityObjective:new { targetPos = { x = 0, y = 2 }, to_retrieve = { name = "iron-plate", count = 18 },
    target = "stone-furnace" },

  FindOreObjective:new { entityType = "stone", tag = "stone-deposit-1" },
  MineResourcesObjective:new { type = "stone", amount = 30 },
  CraftItemsObjective:new { recipe = "stone-furnace", count = 6, asyncTask = true },
  CraftItemsObjective:new { recipe = "burner-mining-drill", count = 2, asyncTask = true },

  PathfindToLocationObjective:new { previous_positions = previous_positions, target = "coal-deposit-1" },
  BuildStructureObjective:new { type = "burner-mining-drill", direction = defines.direction.north,
    target = { x = 0, y = 0 } }, --target is relative to player position
  BuildStructureObjective:new { type = "burner-mining-drill", direction = defines.direction.south,
    target = { x = 1, y = 1 }, tag = "initial-coal" },

  InsertMaterialsObjective:new { to_insert = { name = "wood", count = 1 }, target = "burner-mining-drill" },

  RetrieveFromEntityObjective:new { minThresh = 1, targetPos = { x = 0, y = 2 },
    to_retrieve = { name = "coal", count = 20 }, target = "burner-mining-drill", asyncTask = true },
  RetrieveFromEntityObjective:new { minThresh = 1, targetPos = { x = 0, y = 4 },
    to_retrieve = { name = "coal", count = 20 }, target = "burner-mining-drill", asyncTask = true },

  WaitForAsyncObjective:new {},

  PathfindToLocationObjective:new { previous_positions = previous_positions, target = "initial-burner" },

  InsertMaterialsObjective:new { to_insert = { name = "coal", count = 5 }, target = "stone-furnace" },
  InsertMaterialsObjective:new { to_insert = { name = "coal", count = 5 }, target = "burner-mining-drill" },

  RetrieveFromEntityObjective:new { targetPos = { x = 0, y = 2 }, to_retrieve = { name = "iron-plate", count = 36 },
    target = "stone-furnace" },

  CraftItemsObjective:new { recipe = "burner-mining-drill", count = 2, asyncTask = true },
  CraftItemsObjective:new { recipe = "iron-chest", count = 1, asyncTask = true },

  PathfindToLocationObjective:new { previous_positions = previous_positions, target = "stone-deposit-1" },

  WaitForAsyncObjective:new {},

  BuildStructureObjective:new { type = "burner-mining-drill", direction = defines.direction.east,
    target = { x = -1, y = 0 } }, --target is relative to player position
  BuildStructureObjective:new { type = "iron-chest", direction = defines.direction.east,
    target = { x = 0, y = -1 } },
  BuildStructureObjective:new { type = "burner-mining-drill", direction = defines.direction.west,
    target = { x = 2, y = -1 } },

  InsertMaterialsObjective:new { targetPos = { x = -1, y = 0 }, to_insert = { name = "coal", count = 5 },
    target = "stone-furnace" },
  InsertMaterialsObjective:new { targetPos = { x = 2, y = -1 }, to_insert = { name = "coal", count = 5 },
    target = "stone-furnace" },

}

local current_goal = RecipeGoal:new { recipe = "automation-science-pack" }

local async_objectives = {}

local MODE_FULL = 0
local MODE_BUILD_TEST = 1
local MODE_PATHFIND_TEST = 2
local MODE_GOAL_TEST = 3

local mode = MODE_GOAL_TEST

local function initialize(player, game)
  if mode == MODE_FULL then
    currentObjective = fullObjectives
  elseif mode == MODE_BUILD_TEST then
    currentObjective = buildTest
  else 
    player.print(current_goal.recipe)

    player.set_goal_description(current_goal.recipe, true)

    player.print(serpent.block(game.recipe_prototypes[current_goal.recipe].ingredients))

    currentObjective = oreTest
  end




end

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
          -- player.begin_crafting { count = 1, recipe = "ai-armor" }
          initialize(player, game)
          init_armor = 0

          local bp_entity = game.surfaces[1].create_entity { name = 'item-on-ground', position = { x = 0, y = 0 },
            stack = 'blueprint' }

          local bp_string = "0eNqVkttqwzAMht9F13ZJnKaHvEoZJQetCBw52M5oCH732Q2Msq1bcifJ6Pt/WZqh0SMOlthDNQO1hh1Ulxkc3bjWqeanAaEC8tiDAK77lHlbsxuM9bJB7SEIIO7wDlUexL/NzWgZreyJiW+ys6T1E0GFNwHInjzh4uWRTFce+wZtlHjlQsBgXGwznKQjSqpdKWCKQbEro0JHFtvlXSWf38BqPTjbBC7Wg/NN4P0X2HnDKN/jz9Yt/uRmC1SFXyDlanfbpj78ufAXFrOQ1v+4l+rpNgV8oHWL1CnfH8/qeDir7FTEiT4B/k7ptw=="
          bp_entity.stack.import_stack(bp_string)

          bp_entity.stack.build_blueprint {
            surface = game.surfaces[1],
            force = player.force,
            position = { x = 0, y = 0 }
          }

          bp_entity.destroy()
        end
        if player.character and
            player.get_inventory(defines.inventory.character_armor).get_item_count("ai-armor") > 0
        then
          if #async_objectives > 0 then
            for i = 1, #async_objectives do

              if async_objectives[i]:finished { event = e, p = player, currentObjectiveTable = currentObjective,
                game =
                game, rendering = rendering } then
                async_objectives[i]:cleanup { rendering = rendering, previous_positions = previous_positions,
                  p = player }

                async_objectives[i] = nil
              else
                async_objectives[i]:tick { event = e, previous_positions = previous_positions, p = player,
                  currentObjectiveTable =
                  currentObjective, game = game, rendering = rendering }
              end
            end
          end

          async_objectives = removeNil(async_objectives)

          if currentObjective[1] then
            if currentObjective[1].asyncTask == true then
              player.print("Found async ")
              table.insert(async_objectives, currentObjective[1])
              table.remove(currentObjective, 1)
            end

            if currentObjective[1] then

              if currentObjective[1]:finished { event = e, p = player, current_async_objectives = async_objectives,
                currentObjectiveTable = currentObjective,
                game =
                game, rendering = rendering } then
                currentObjective[1]:cleanup { rendering = rendering, previous_positions = previous_positions, p = player }
                table.remove(currentObjective, 1)

                if (currentObjective[1]) then
                  player.set_goal_description(currentObjective[1]:get_name(), true)
                  currentObjective[1]:tick { event = e, p = player, previous_positions = previous_positions,
                    currentObjectiveTable =
                    currentObjective, game = game, rendering = rendering }
                end
              else
                currentObjective[1]:tick { event = e, previous_positions = previous_positions, p = player,
                  currentObjectiveTable =
                  currentObjective, game = game, rendering = rendering }
              end
            end
          else
            player.set_goal_description("No current objective", true)
            -- player.print("Finished All Tasks")
            -- done = true
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
