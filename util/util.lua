local utility = {}

function utility:distance_squared(positionA, positionB)
    return math.pow(positionA.x - positionB.x, 2) + math.pow(positionA.y - positionB.y, 2)
end

function utility:distance(positionA, positionB)
    return math.sqrt(self:distanceSquared(positionA, positionB))
end

function utility:remove_nil(t)
    local ans = {}
    for _,v in pairs(t) do
      ans[ #ans+1 ] = v
    end
    return ans
  end

function utility:position_has_player_collision(position, game)
    tile = game.surfaces[1].get_tile {x = position.x, y = position.y}
    if
        tile.collides_with("player-layer") == false and
            game.surfaces[1].count_entities_filtered {
                area = {tile.position, {x = tile.position.x + 1, y = tile.position.y + 1}},
                limit = 1,
                collision_mask = "player-layer"
            } == 0
     then
        return true
    else
        return false
    end
end

return utility