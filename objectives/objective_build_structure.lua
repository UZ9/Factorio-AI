require "objective"
require "util/util"

BuildStructureObjective = Objective:new()

BuildStructureObjective.target = nil
BuildStructureObjective.position = nil --temporary workaround until I find a better solution that doesn't use target AND position
BuildStructureObjective.type = nil
BuildStructureObjective.entity = nil
BuildStructureObjective.direction = defines.direction.north

local function isPlayerInBox(playerPos, playerBox, targetPos, targetBox)
    return playerPos.x + playerBox.left_top.x <= targetPos.x + targetBox.right_bottom.x and
        playerPos.x + playerBox.right_bottom.x >= targetPos.x + targetBox.left_top.x and
        playerPos.y + playerBox.left_top.y <= targetPos.y + targetBox.right_bottom.y and
        playerPos.y + playerBox.right_bottom.y >= targetPos.y + targetBox.left_top.y
end

function BuildStructureObjective:finished(par)
    return self.done == true
end

function BuildStructureObjective:tick(par)

    if self.position == nil then
        if type(self.target) == "table" then
            self.position = {
                x = math.floor(par.p.position.x) + self.target.x,
                y = math.floor(par.p.position.y) + self.target.y
            }
        else
            self.position = {
                x = par.previous_positions[self.target].x,
                y = par.previous_positions[self.target].y
            }
        end
    end

    par.p.print(type(self.target))

    targetPos = self.position

    if
        (distanceSquared(par.p.position, targetPos) > 36) or
            isPlayerInBox(
                par.p.position,
                game.entity_prototypes["character"].collision_box,
                targetPos,
                game.entity_prototypes[self.type].collision_box
            )
     then --36 is default distance squared
        --self.done = true
        --move to somewhere to be in range
        par.p.print("Outside of build range")

        if
            isPlayerInBox(
                par.p.position,
                par.game.entity_prototypes["character"].collision_box,
                targetPos,
                par.game.entity_prototypes[self.type].collision_box
            )
         then
            par.p.print("in box")
        end

        if distanceSquared(par.p.position, targetPos) > 36 then
            par.p.print("distance ")
        end

        collider = game.entity_prototypes[self.type].collision_box

        par.p.print("{" .. collider.left_top.x .. ", " .. collider.left_top.y .. "}")

        movementOrder =
            WalkToLocationObjective:new {
            target = {
                x = self.position.x + collider.left_top.x,
                y = -2.5 + self.position.y + collider.left_top.y
            }
        }

        table.insert(par.currentObjectiveTable, 1, movementOrder)
    else
        if
            (par.p.surface.can_place_entity {
                name = self.type,
                position = targetPos,
                direction = defines.direction.north,
                force = par.p.force
            })
         then
            inventory = par.p.get_inventory(defines.inventory.character_main)

            if inventory.get_item_count(self.type) ~= 0 then
                inventory.remove({name = self.type, count = 1})

                self.entity =
                    player.surface.create_entity {
                    name = self.type,
                    position = targetPos,
                    direction = self.direction,
                    force = player.force
                }

                self.done = true
            end
        else
            for x = 1, game.entity_prototypes[self.type].collision_box.x do
                for y = 1, game.entity_prototypes[self.type].collision_box.y do
                    if collidesWith({x = targetPos.x + x, y = targetPos.y + y}, par.game) == true then
                        targetEntity =
                            par.game.surfaces[1].find_entities_filtered {
                            area = {tile.position, {x = tile.position.x + 1, y = tile.position.y + 1}},
                            limit = 1,
                            collision_mask = "player-layer"
                        }[1]

                        table.insert(
                            par.currentObjectiveTable,
                            1,
                            ClearEnvironmentObjective:new {
                                target = {x = targetEntity.position.x, y = targetEntity.position.y}
                            }
                        )
                    end
                end
            end
        end
    end
end
