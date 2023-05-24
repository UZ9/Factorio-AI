require "objective"

CraftItemsObjective = Objective:new()

CraftItemsObjective.target = nil

CraftItemsObjective.started = false

function CraftItemsObjective:finished(par)
    return par.p.crafting_queue_size == 0 and par.p.get_inventory(defines.inventory.character_main).get_item_count(self.recipe) >= self.count
end

function CraftItemsObjective:get_name()
    return "Crafting " .. self.count .. " " .. self.recipe
end

function CraftItemsObjective:tick(par)
    if self.started == false then
        if player.crafting_queue_size == 0 then
            player.begin_crafting { count = self.count, recipe = self.recipe }
            self.started = true
        end
    end
end
