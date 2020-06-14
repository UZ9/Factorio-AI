function distanceSquared(positionA, positionB)
    return math.pow(positionA.x - positionB.x, 2) + math.pow(positionA.y - positionB.y, 2)
end

function distance(positionA, positionB)
    return math.sqrt(distanceSquared(positionA, positionB))
end