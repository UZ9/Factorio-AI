require "objective"

CraftItemsObjective = Objective:new()

CraftItemsObjective.target = nil

CraftItemsObjective.started = false

function CraftItemsObjective:finished(par)
  return self.targetEntity
end

function CraftItemsObjective:get_name()
    return "Crafting " .. self.count .. " " .. self.recipe
end

function CraftItemsObjective:tick(par)
end

