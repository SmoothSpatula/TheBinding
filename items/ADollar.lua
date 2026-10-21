local sprite = Sprite.new("equipment/ADollar", "~/assets/sprites/items/ADollar.png", 1, 16, 16)

local ADollar = Item.new("ADollar")
ADollar:set_sprite(sprite)
ItemLog.new_from_item(ADollar)
ADollar:set_tier(ItemTier.UNCOMMON)

Callback.add(ADollar.on_acquired, function(actor, stack)
	local inst = actor.value
	local cost = 100 * gm.cost_get_base_gold_price_scale()

    if gm.is_local_player(inst) then
        local oHUD = gm.instance_find(gm.constants.oHUD, 0)
        oHUD.gold = oHUD.gold + cost
    else
        inst.gold = inst.gold + cost
    end
end)