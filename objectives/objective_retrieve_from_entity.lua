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

    par.p.print(itemCount)

    if itemCount > self.minThresh then 
      local item_stack = { name=self.to_retrieve.name, count=itemCount - self.minThresh }

      par.p.get_inventory(defines.inventory.character_main).insert(item_stack)
      inventory.remove(item_stack)
    end


  -- local target_ingredients = par.game.recipe_prototypes[self.to_retrieve.count].ingredients

  -- for ingredient


  --   player_inventory = par.p.get_inventory(defines.inventory.character_main)

  --   if player_inventory.get_item_count(self.to_insert.name) >= self.to_insert.count then
  --     if (targetEntity.can_insert(self.to_insert)) then
  --       targetEntity.insert(self.to_insert)
  --       player_inventory.remove(self.to_insert)
  --     else
  --       par.p.print("Failed to insert items")
  --     end
  --   else
  --     par.p.print("Not enough items in player inventory")
  --   end

  -- tile = par.game.surfaces[1].get_tile(par.p.position)
  -- par.p.update_selected_entity({x=tile.position.x+0.5, y=tile.position.y+0.5})
  -- par.p.mining_state={mining=true, position=par.p.position}

  self.done = true
end
