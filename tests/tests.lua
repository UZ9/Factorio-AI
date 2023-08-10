require "objectives/objective_retrieve_from_entity"
require "objectives/objective_walk_to_location"
require "objectives/objective_pathfind_to_location"
require "objectives/objective_find_ore"
require "objectives/objective_build_structure"
require "objectives/objective_mine_resources"
require "objectives/objective_insert_materials"
require "objectives/objective_craft_items.lua"
require "objectives/objective_wait_for_async.lua"
require "objectives/objective_apply_ore_pattern.lua"
require "objectives/objective_build_on_ore_pattern.lua"

local oreTest = {
    FindOreObjective:new { entityType = "iron-ore" },
    ApplyOrePatternObjective:new { zone_type = "iron-ore" },
    BuildOnOrePatternObjective:new { zone_type = "iron-ore" },
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


local tests = { oreTest, buildTest, fullObjectives }





return tests
