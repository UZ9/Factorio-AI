--control.lua
require "objectives/objective"

require "path_tile"

require "goals/goal_recipe"

local utility = require "util/util"
local tests = require "tests/tests"

local init_armor = 1
local done = false

local previous_positions = {}

local currentObjective = {}

local current_goal = RecipeGoal:new { recipe = "automation-science-pack" }

local async_objectives = {}

local MODE_FULL = 3
local MODE_BUILD_TEST = 2
local MODE_ORE_TEST = 1

local mode = MODE_ORE_TEST

local function initialize(player, game)
  currentObjective = tests[mode]

  player.print("SELECTED TEST " .. mode)
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

          async_objectives = utility:remove_nil(async_objectives)

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
          end
        else
          player.color = { r = 255, g = 140, b = 0, a = 1 }
        end
      end
    end
  end
)
