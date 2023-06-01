Pattern = {}

Pattern.blueprintString = ""
Pattern.repeating = true

function Pattern:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Pattern:thing()
    local bp_entity = game.surfaces[1].create_entity { name = 'item-on-ground', position = { x = 0, y = 0 },
        stack = 'blueprint' }

    local bp_string = "0eNqVkttqwzAMht9F13ZJnKaHvEoZJQetCBw52M5oCH732Q2Msq1bcifJ6Pt/WZqh0SMOlthDNQO1hh1Ulxkc3bjWqeanAaEC8tiDAK77lHlbsxuM9bJB7SEIIO7wDlUexL/NzWgZreyJiW+ys6T1E0GFNwHInjzh4uWRTFce+wZtlHjlQsBgXGwznKQjSqpdKWCKQbEro0JHFtvlXSWf38BqPTjbBC7Wg/NN4P0X2HnDKN/jz9Yt/uRmC1SFXyDlanfbpj78ufAXFrOQ1v+4l+rpNgV8oHWL1CnfH8/qeDir7FTEiT4B/k7ptw=="
    bp_entity.stack.import_stack(bp_string)

    bp_entity.stack.build_blueprint {
        surface = game.surfaces[1],
        force = player.force,
        position = { x = 0, y = 0 }
    }

    bp_entity.destroy()
end
