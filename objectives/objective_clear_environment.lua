require "objective"

ClearEnvironmentObjective = Objective:new()

ClearEnvironmentObjective.bounding_box = nil

function ClearEnvironmentObjective:finished(par)
  return self.done == true
end

function ClearEnvironmentObjective:tick(par)
    entities = par.game.surfaces[1].find_entities_filtered{area = self.bounding_box, collision_mask="player-layer"}

    for i=1, #entities do 
        local element = entities[i]
        table.insert(par.currentObjectiveTable, 2, MineEntityObjective:new {target = {x = element.x, y = element.y}})
    end

    self.done = true
end

