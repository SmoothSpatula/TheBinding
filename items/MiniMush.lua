local sprite = Sprite.new("equipment/MiniMush", "~/assets/sprites/items/MiniMush.png", 1, 16, 16)

local MiniMush = Item.new("MiniMush")
MiniMush:set_sprite(sprite)
ItemLog.new_from_item(MiniMush)
MiniMush:set_tier(ItemTier.UNCOMMON)

Callback.add(MiniMush.on_acquired, function(actor, stack)
    actor:recalculate_stats() 
end)

RecalculateStats.add(function(actor, api)
    local count = actor:item_count(MiniMush) 
    if count < 1 then return end
    
    local size = 0.33 + 0.67 * math.exp(-0.3339 * count)
    inst = actor.value
    inst.image_xscale = size
    inst.image_yscale = size

    api.pVmax_add(count * 0.15)
end)