Pattern = {}

Pattern.blueprintString = ""
Pattern.repeating = true
Pattern.currentIndex = 0
Pattern.currentBuildIndex = 0
Pattern.stepX = 2
Pattern.stepY = 4
Pattern.buildQueue = {}

function Pattern:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Pattern:apply_pattern(rendering, game, player, zone, max_count)
    local bp_entity = game.surfaces[1].create_entity { name = 'item-on-ground',
        position = { x = 0, y = 0 },
        stack = 'blueprint' }

    local current_count = 0

    for y = zone.bounds.minY + (self.currentIndex * self.stepY), zone.bounds.maxY, self.stepY do
        for x = zone.bounds.minX + (self.currentIndex * self.stepY), zone.bounds.maxX, self.stepX do
            bp_entity.stack.import_stack(self.blueprintString)



            local bp_entities = bp_entity.stack.get_blueprint_entities()

            print(#bp_entities)

            local can_place = true

            if current_count >= max_count then
                bp_entity.destroy()
                return
            end


            for _, entity in pairs(bp_entities) do
                local new_entity = entity

                new_entity.position = { entity.position.x + x, entity.position.y + y }
                new_entity.force = player.force

                player.print(entity.name)

                -- TODO: Find a way to not make this hardcoded
                if entity.name == "burner-mining-drill" then
                    local foundEntities = game.surfaces[1].find_entities_filtered {
                        area = {
                            -- 0.5 offset as it starts in the middle of the tile
                            { x = new_entity.position[1] - 0.5, y = new_entity.position[2] - 0.5 },
                            { x = new_entity.position[1] + 1.5, y = new_entity.position[2] + 1.5 }
                        },
                        name = "iron-ore"
                    }

                    if not (#foundEntities > 0 and game.surfaces[1].can_place_entity(new_entity)) then

                        can_place = false
                    end
                else
                    -- game.surfaces[1].create_entity(new_entity)
                end



            end

            if can_place then
                self.buildQueue[self.currentIndex] = { x = x, y = y }

                bp_entity.stack.build_blueprint {
                    surface = game.surfaces[1],
                    force = player.force,
                    position = { x = x, y = y }
                }

                current_count = current_count + 1
                self.currentIndex = self.currentIndex + 1

                rendering.draw_rectangle {
                    color = { r = 1, g = 0.6, b = 0, a = 1 },
                    filled = false,
                    left_top = { x - 0.5,
                    y - 1.5 },
                    right_bottom = { x + self.stepX - 0.5,
                    y + self.stepY - 1.5 },
                    surface = game.surfaces[1],
                    only_in_alt_mode = true
                }
            else
                player.print("Couldn't polka for " .. serpent.block({ x = x, y = y }))
            end
        end

    end

    bp_entity.destroy()



end

function Pattern:build_next(par)
    -- Import blueprint of pattern
    local bp_entity = game.surfaces[1].create_entity { name = 'item-on-ground',
        position = { x = 0, y = 0 },
        stack = 'blueprint' }

    bp_entity.stack.import_stack(self.blueprintString)
    local bp_entities = bp_entity.stack.get_blueprint_entities()


    -- Add to build index
    self.currentBuildIndex = self.currentBuildIndex + 1
    
    -- Find pos based on build index 
    local position = self.buildQueue[self.currentBuildIndex]

    -- Draw that region has changed

    par.rendering.draw_rectangle {
        color = { r = 0, g = 0.6, b = 0, a = 1 },
        filled = false,
        left_top = { position.x - 0.5,
        position.y - 1.5 },
        right_bottom = { position.x + self.stepX - 0.5,
        position.y + self.stepY - 1.5 },
        surface = par.game.surfaces[1],
        only_in_alt_mode = true
    }

    -- Loop over entities
    for _, entity in pairs(bp_entities) do
        table.insert(par.current_objective, BuildStructureObjective:new { type = entity.name, direction = entity.direction,
        target = {x = position.x + entity.position.x, y = position.y + entity.position.y }}) 
    end

    par.player.print(serpent.block(bp_entity.stack.cost_to_build))

    bp_entity.destroy()

end
