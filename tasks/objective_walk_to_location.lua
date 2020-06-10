require "objective"

WalkToLocationObjective = Objective:new()

WalkToLocationObjective.target = nil

local TILE_RADIUS = 0.1
WalkToLocationObjective.done = false

local function tablelength(table)
  local count = 0
  for index in pairs(table) do
    count = count + 1
  end
  return count
end

local function find_nearest_entity(xPosPlayer, yPosPlayer, game, player, entity)
  local i = 1
  local entityCount = 0
  while entityCount == 0 do
    i = i + 1
    entityCount =
      game.surfaces[1].count_entities_filtered {
      area = {{xPosPlayer - i, yPosPlayer - i}, {xPosPlayer + i, yPosPlayer + i}},
      name = entity
    }
  end
  entityFind =
    game.surfaces[1].find_entities_filtered {
    area = {{xPosPlayer - i, yPosPlayer - i}, {xPosPlayer + i, yPosPlayer + i}},
    name = entity,
    limit = 1
  }
  allEntities =
    game.surfaces[1].find_entities_filtered {
    area = {{xPosPlayer - i, yPosPlayer - i}, {xPosPlayer + i, yPosPlayer + i}}
  }
  return entityCount, entityFind, allEntities, i
end

local function getDegrees(player, target, xDist, yDist)
  if xDist > 0 and yDist >= 0 then 
    return math.deg(math.atan(xDist/yDist)) + 90 --quadrant 4
  elseif xDist >= 0 and yDist < 0 then 
    return math.deg(math.atan(xDist/-yDist)) --quadrant 1
  elseif xDist <= 0 and yDist > 0 then --quadrant 3
    return math.deg(math.atan(-xDist/yDist)) + 180
  elseif xDist <= 0 and yDist < 0 then --quadrant 2
    return math.deg(math.atan(-xDist/yDist)) + 270
  else 
    return -1
  end
end

local function getDirection(player, target, xDist, yDist)
  angle = getDegrees(player, target, xDist, yDist)
  --player.print(angle)

  if angle > 337.5 then
    player.print("north")
    return defines.direction.north
  end
  if angle > 292.5 then
    player.print("northwest")
    return defines.direction.northwest
  end
  if angle > 247.5 then
    player.print("west")
    return defines.direction.west
  end
  if angle > 202.5 then
    player.print("southwest")
    return defines.direction.southwest
  end
  if angle > 157.5 then
    player.print("south")
    return defines.direction.south
  end
  if angle > 122.5 then
    player.print("southeast")
    return defines.direction.southeast
  end
  if angle > 67.5 then
    player.print("east")
    return defines.direction.east
  end
  if angle > 22.5 then
    player.print("northeast")
    return defines.direction.northeast
  end
  player.print("north")
  return defines.direction.north
end

function moveTo(player, xDist, yDist, distEuc)
  -- moveTo
  --
  if xDist >= TILE_RADIUS and yDist >= TILE_RADIUS then
    player.walking_state = {walking = true, direction = defines.direction.southeast}
  elseif xDist <= -TILE_RADIUS and yDist >= TILE_RADIUS then
    player.walking_state = {walking = true, direction = defines.direction.southwest}
  elseif xDist >= TILE_RADIUS and yDist <= -TILE_RADIUS then
    player.walking_state = {walking = true, direction = defines.direction.northeast}
  elseif xDist <= -TILE_RADIUS and yDist <= -TILE_RADIUS then
    player.walking_state = {walking = true, direction = defines.direction.northwest}
  elseif yDist >= TILE_RADIUS then
    player.walking_state = {walking = true, direction = defines.direction.south}
  elseif yDist <= -TILE_RADIUS then
    player.walking_state = {walking = true, direction = defines.direction.north}
  elseif xDist >= TILE_RADIUS then
    player.walking_state = {walking = true, direction = defines.direction.east}
  elseif xDist <= -TILE_RADIUS then
    player.walking_state = {walking = true, direction = defines.direction.west}
  end
end

local function round(value)
  return math.floor(value + 0.5)
end

function WalkToLocationObjective:finished(par)
  return self.done == true
end

function WalkToLocationObjective:tick(par)
  if self.done == true then return end 

  player = par.p
  --player.print("position: " .. player.position.x .. ", " .. player.position.y)

  distance =
    math.sqrt(
    math.pow(math.abs(player.position.x - self.target.x + 0.5), 2) +
      math.pow(math.abs(player.position.y - self.target.y + 0.5), 2)
  )

  xDist = self.target.x - player.position.x + 0.5
  yDist = self.target.y - player.position.y + 0.5

  if math.abs(xDist) > TILE_RADIUS or math.abs(yDist) > TILE_RADIUS then
    player.walking_state = {walking = true, direction = getDirection(player, self.target, xDist, yDist)}
    --moveTo(player, xDist, yDist, distance)
    --player.print("seems that dist was greater than tile radius (" .. distance .. " > " .. TILE_RADIUS .. ")")
    --getDirection(player, self.target, xDist, yDist)
  else
    self.done = true
  end
end

