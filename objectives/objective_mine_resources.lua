require "objective"

MineResourcesObjective = Objective:new()


function MineResourcesObjective:finished(par)
  return par.p.get_inventory(defines.inventory.character_main).get_item_count(self.type) >= self.amount
end

function MineResourcesObjective:get_name()
  return "Mining " .. self.amount .. " " .. self.type
end

function MineResourcesObjective:tick(par)
    tile = par.game.surfaces[1].get_tile(par.p.position)
    par.p.update_selected_entity({x=tile.position.x+0.5, y=tile.position.y+0.5})
    par.p.mining_state={mining=true, position=par.p.position}
end

