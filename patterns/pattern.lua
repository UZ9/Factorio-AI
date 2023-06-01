Pattern = {}

Pattern.blueprintString = ""
Pattern.repeating = true

function Pattern:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Pattern:apply_pattern(game, player, zone)
    local bp_entity = game.surfaces[1].create_entity { name = 'item-on-ground',
        position = { x = 0, y = 0 },
        stack = 'blueprint' }

    for x = zone.bounds.minX, zone.bounds.maxX, 2 do
        for y = zone.bounds.minY, zone.bounds.maxY, 4 do
            bp_entity.stack.import_stack(self.blueprintString)



            local bp_entities = bp_entity.stack.get_blueprint_entities()

            print(#bp_entities)

            for _, entity in pairs(bp_entities) do
                local new_entity = entity

                new_entity.position = { entity.position.x + x, entity.position.y + y }
                new_entity.force = player.force

                player.print(entity.name)

                if entity.name == "burner-mining-drill" then
                    foundEntities = game.surfaces[1].find_entities_filtered {
                        area = {
                            new_entity.position,
                            { x = new_entity.position[1] + 2, y = new_entity.position[2] + 2 }
                        },
                        name = "iron-ore"
                    }

                    if #foundEntities > 0 and game.surfaces[1].can_place_entity(new_entity) then
                        game.surfaces[1].create_entity(new_entity)
                    else 
                        break 
                    end
                else 
                    game.surfaces[1].create_entity(new_entity)
                end
                    
            end

            -- local entities = bp_entity.stack.get_blueprint_entities()

            -- local can_place = true

            -- player.print(#entities)

            -- for i = 1, #entities do
            --     if not game.surfaces[1].can_place_entity(entities[i]) then
            --         player.print("checking if placing " .. serpent.block(entities[i]))
            --         can_place = false
            --         break
            --     end
            -- end

            -- if can_place then
            --     bp_entity.stack.build_blueprint {
            --         surface = game.surfaces[1],
            --         force = player.force,
            --         position = { x = x, y = y }
            --     }
            -- end



        end

    end

    bp_entity.destroy()



end
