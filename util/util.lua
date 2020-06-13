function distanceSquared(positionA, positionB)
    return math.pow(positionA.x - positionB.x, 2) + math.pow(positionA.y - positionB.x)
end

function distance(positionA, positionB)
    return math.sqrt(distanceSquared(positionA, positionB))
end