function distanceSquared(positionA, positionB)
    return math.pow(positionA.x - positionB.x, 2) + math.pow(positionA.y - positionB.y, 2)
end

function distance(positionA, positionB)
    return math.sqrt(distanceSquared(positionA, positionB))
end

function removeNil(t)
    local ans = {}
    for _,v in pairs(t) do
      ans[ #ans+1 ] = v
    end
    return ans
  end