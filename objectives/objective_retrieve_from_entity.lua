require "objective"

RetrieveFromEntityObjective = Objective:new()

RetrieveFromEntityObjective.minThresh = 0


function RetrieveFromEntityObjective:finished(par)
  return par.p.get_inventory(defines.inventory.character_main).get_item_count(self.to_retrieve.name) >= self.to_retrieve.count
end

function RetrieveFromEntityObjective:get_name()
  return "Retrieving " .. serpent.block(self.to_insert)
end

function RetrieveFromEntityObjective:tick(par)

    targetEntity = par.p.surface.find_entities_filtered {
      position = { x = par.p.position.x + self.targetPos.x, y = par.p.position.y + self.targetPos.y },
      radius = 1,
      limit = 1,
      name = self.target,
    }[1]

    local inventory = targetEntity.get_output_inventory()

    local itemCount = inventory.get_item_count(self.to_retrieve.name)

    if itemCount > self.minThresh then 
      local item_stack = { name=self.to_retrieve.name, count=itemCount - self.minThresh }

      par.p.get_inventory(defines.inventory.character_main).insert(item_stack)
      inventory.remove(item_stack)
    end
  self.done = true
end
