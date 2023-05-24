require "objective"

WaitForAsyncObjective = Objective:new()

function WaitForAsyncObjective:finished(par)
    return #par.current_async_objectives == 0
end

function WaitForAsyncObjective:get_name()
    return "Waiting for ASYNC completion..."
end

function WaitForAsyncObjective:tick(par)
end
