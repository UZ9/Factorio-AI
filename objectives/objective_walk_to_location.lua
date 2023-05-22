require "objective"

WalkToLocationObjective = Objective:new()

WalkToLocationObjective.target = nil
WalkToLocationObjective.renderingTile = nil

local TILE_RADIUS = 0.3

local function tablelength(table)
  local count = 0
  for index in pairs(table) do
    count = count + 1
  end
  return count
end

local function getDegrees(player, target, xDist, yDist)
  if xDist > 0 and yDist >= 0 then
    return math.deg(math.atan(xDist / yDist)) + 90 --quadrant 4
  elseif xDist >= 0 and yDist < 0 then
    return math.deg(math.atan(xDist / -yDist)) --quadrant 1
  elseif xDist <= 0 and yDist > 0 then --quadrant 3
    return math.deg(math.atan(-xDist / yDist)) + 180
  elseif xDist <= 0 and yDist < 0 then --quadrant 2
    return math.deg(math.atan(-xDist / -yDist)) + 270
  else
    return -1
  end
end

local function getDirection(player, target, xDist, yDist)
  angle = getDegrees(player, target, xDist, yDist)
  --player.print(angle)

  if angle > 337.5 then
    return defines.direction.north
  end
  if angle > 292.5 then
    return defines.direction.northwest
  end
  if angle > 247.5 then
    return defines.direction.west
  end
  if angle > 202.5 then
    return defines.direction.southwest
  end
  if angle > 157.5 then
    return defines.direction.south
  end
  if angle > 122.5 then
    return defines.direction.southeast
  end
  if angle > 67.5 then
    return defines.direction.east
  end
  if angle > 22.5 then
    return defines.direction.northeast
  end
  return defines.direction.north
end

local function round(value)
  return math.floor(value + 0.5)
end

local xDist = 0
local yDist = 0

function WalkToLocationObjective:finished(par)
  player = par.p

  xDist = self.target.x - player.position.x + 0.5
  yDist = self.target.y - player.position.y + 0.5

  self.done = not (math.abs(xDist) > TILE_RADIUS or math.abs(yDist) > TILE_RADIUS)

  if self.done == true then
    if self.renderingTile ~= nil then
      par.rendering.destroy(self.renderingTile)
    end
  end

  return self.done == true
end

function WalkToLocationObjective:tick(par)
  if self.done == true then
    return
  end

  if self.renderingTile == nil then
  end


  -- self.renderingTile()

  player = par.p
  --player.print("position: " .. player.position.x .. ", " .. player.position.y)

  distance =
    math.sqrt(
    math.pow(math.abs(player.position.x - (self.target.x + 0.5)), 2) +
      math.pow(math.abs(player.position.y - (self.target.y + 0.5)), 2)
  )



  if not self.done then
    --moveTo(player, xDist, yDist, distance)
    --player.print("seems that dist was greater than tile radius (" .. distance .. " > " .. TILE_RADIUS .. ")")
    --getDirection(player, self.target, xDist, yDist)
    player.character_running_speed_modifier = 0.1
    player.walking_state = {walking = true, direction = getDirection(player, self.target, xDist, yDist)}
  else
    self.done = true
  end
end
