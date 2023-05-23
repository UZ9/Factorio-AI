require "objective"

InsertMaterialsObjective = Objective:new()


function InsertMaterialsObjective:finished(par)
  return self.done == true
end

function InsertMaterialsObjective:get_name()
  return "Insert " .. serpent.block(self.to_insert)
end

function InsertMaterialsObjective:tick(par)

  targetEntity = par.p.surface.find_entities_filtered {
    position = par.p.position,
    radius = 10,
    limit = 1,
    name = self.target,
  }[1]

  player_inventory = par.p.get_inventory(defines.inventory.character_main)

  if player_inventory.get_item_count(self.to_insert.name) >= self.to_insert.count then
    if (targetEntity.can_insert(self.to_insert)) then
      targetEntity.insert(self.to_insert)
      player_inventory.remove(self.to_insert)
    else
      par.p.print("Failed to insert items")
    end
  else
    par.p.print("Not enough items in player inventory")
  end

  -- tile = par.game.surfaces[1].get_tile(par.p.position)
  -- par.p.update_selected_entity({x=tile.position.x+0.5, y=tile.position.y+0.5})
  -- par.p.mining_state={mining=true, position=par.p.position}

  self.done = true
end
