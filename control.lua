--control.lua
require "objectives/objective"
require "path_tile"
require "goals/goal_recipe"

local aw = require "util/async_await"

local zone_manager = require "zones/zone_manager"

local utility = require "util/util"
local tests = require "tests/tests"

local init_armor = 1
local done = false

local previous_positions = {}

local current_objective = {}

local current_goal = RecipeGoal:new { recipe = "burner-mining-drill" }

local async_objectives = {}

-- Available modes
local MODE_FULL = 3
local MODE_BUILD_TEST = 2
local MODE_ORE_TEST = 1

-- Mode to automatically run as soon as the player equips the armor
local mode = MODE_ORE_TEST

local function initialize(player, game)
  current_objective = tests[mode]

  

  --[[
    find_ore_objective 
    when it finishes:
    attempt build 
  ]]
    --end
   --end
-- end
  player.print("SELECTED TEST " .. mode)
end

local primary_zone_manager = zone_manager:new {}

script.on_event(
  { defines.events.on_tick },
  function(e)
    if e.tick % 1 == 0 then
      if done == true then
        do
          return
        end
      end

      for _, player in pairs(game.connected_players) do
        -- player.set_goal_description(serpent.block(primary_zone_manager.zones, { maxlevel = 3 }), true)

        if init_armor == 1 then
          initialize(player, game)
          init_armor = 0
        end
        if player.character and
            player.get_inventory(defines.inventory.character_armor).get_item_count("ai-armor") > 0
        then
          if #async_objectives > 0 then
            for i = 1, #async_objectives do

              if async_objectives[i]:finished { event = e, p = player, currentObjectiveTable = current_objective,
                game =
                game, rendering = rendering } then
                async_objectives[i]:cleanup { rendering = rendering, previous_positions = previous_positions,
                  p = player }

                async_objectives[i] = nil
              else
                async_objectives[i]:tick { event = e, previous_positions = previous_positions, p = player,
                  currentObjectiveTable =
                  current_objective, game = game, rendering = rendering, zone_manager = primary_zone_manager }
              end
            end
          end

          async_objectives = utility:remove_nil(async_objectives)

          if current_objective[1] then
            if current_objective[1].asyncTask == true then
              player.print("Found async ")
              table.insert(async_objectives, current_objective[1])
              table.remove(current_objective, 1)
            end

            if current_objective[1] then

              if current_objective[1]:finished { event = e, p = player, current_async_objectives = async_objectives,
                currentObjectiveTable = current_objective,
                game =
                game, rendering = rendering } then
                current_objective[1]:cleanup { rendering = rendering, previous_positions = previous_positions, p = player }
                table.remove(current_objective, 1)

                if (current_objective[1]) then
                  player.set_goal_description(current_objective[1]:get_name(), true)
                  current_objective[1]:tick { event = e, p = player, previous_positions = previous_positions,
                    currentObjectiveTable =
                    current_objective, game = game, rendering = rendering, zone_manager = primary_zone_manager }
                end
              else
                current_objective[1]:tick { event = e, previous_positions = previous_positions, p = player,
                  currentObjectiveTable =
                  current_objective, game = game, rendering = rendering, zone_manager = primary_zone_manager }
              end
            end
          else
            player.set_goal_description("No current objective", true)
          end
        else
          player.color = { r = 255, g = 140, b = 0, a = 1 }
        end
      end
    end
  end
)
