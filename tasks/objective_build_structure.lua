require "objective"
require "util/util"

BuildStructureObjective = Objective:new()

BuildStructureObjective.target = nil
BuildStructureObjective.type = nil
BuildStructureObjective.entity = nil

local function isPlayerInBox(playerPos, playerBox, targetPos, targetBox)
    return playerPos.x + playerBox.left_top.x <= targetPos.x + targetBox.right_bottom.x and
        playerPos.x + playerBox.right_bottom.x >= targetPos.x + b.left_top.x and
        playerPos.y + playerBox.left_top.y <= targetPos.y + b.right_bottom.y and
        playerPos.y + playerBox.right_bottom.y >= targetPos.y + b.left_top.y
end

function BuildStructureObjective:finished(par)
    return self.done == true
end

function BuildStructureObjective:tick(par)
    if
        (distanceSquared(par.p.position, self.target.position) > 36) or
            isPlayerInBox(
                par.p.position,
                game.entity_prototypes["player"].collision_box,
                self.target.position,
                game.entity_prototypes[self.type]
            )
     then --36 is default distance squared
        --move to somewhere to be in range
        par.p.print("Outside of build range")

        self.done = true
    else
        if
            (par.pr.surface.can_place_entity {
                name = self.type,
                position = self.target.position,
                direction = defines.direction.north,
                force = par.p.force
            })
         then
            inventory = par.p.get_inventory(defines.inventory.player_main)

            if inventory.get_item_count(self.type) ~= 0 then
                inventory.remove({name = self.type, count = 1})

                self.entity =
                    player.surface.create_entity {
                    name = self.type,
                    position = self.target.position,
                    direction = defines.direction.north,
                    force = player.force
                }

                self.done = true
            end
        else
            for x = 1, game.entity_prototypes[self.type].collision_box.x do
                for y = 1, game.entity_prototypes[self.type].collision_box.y do
                    if collidesWith({x = self.target.position.x + x, y = self.target.position.y + y}, par.game) == true then
                        targetEntity =
                            par.game.surfaces[1].find_entities_filtered {
                            area = {tile.position, {x = tile.position.x + 1, y = tile.position.y + 1}},
                            limit = 1,
                            collision_mask = "player-layer"
                        }[1]
                        table.insert(
                            par.currentObjectiveTable,
                            1,
                            ClearEnvironmentObjective:new {target = {x = targetEntity.position.x, y = targetEntity.position.y}}
                        )
                    end
                end
            end
        end
    end
end
