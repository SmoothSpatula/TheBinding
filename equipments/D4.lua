local sprite = Sprite.new("equipment/D4", "~/assets/sprites/equipments/D4.png", 1, 16, 16)

local D4 = Equipment.new("D4")
D4:set_sprite(sprite)
D4.cooldown = 60 * 90
D4.loot_tags = Item.LootTag.CATEGORY_UTILITY 
			 -- Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS 
			 + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR -- The Equipment Activator is a unique interactable found in any Stage 3-TBA. It displays a random Equipment item, which when paid for will activate the Equipment as if used by the player. It can be reused many times, each use costing more than the last. 

ItemLog.new_from_equipment(D4)

Callback.add(D4.on_use, function(actor, embryo)
	if actor:is_authority() then
        local total_items = 0
        items = Item.find_all()
        for _, item in pairs(items) do
            local count = actor:item_count(item, Item.StackKind.NORMAL)
            total_items = total_items + count
            actor:item_take(item, count, Item.StackKind.NORMAL)
        end
        for i=1, total_items do
            gm.item_give_internal(actor.value, items[math.random(#items)].value, 1, Item.StackKind.NORMAL)
        end
	end
end)