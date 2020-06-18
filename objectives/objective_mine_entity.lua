require "objective"

MineEntityObjective = Objective:new()

MineEntityObjective.target = nil

function MineEntityObjective:finished(par)
  return self.done == true
end

function MineEntityObjective:tick(par)
    if self.target ~= nil then 
        par.p.mining_state={mining=true, position=target.position}
    else 
        self.done = true 
    end
end

