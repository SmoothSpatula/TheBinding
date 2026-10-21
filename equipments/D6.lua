local sprite = Sprite.new("equipment/D6", "~/assets/sprites/equipments/D6.png", 1, 16, 16)

local D6 = Equipment.new("D6")
D6:set_sprite(sprite)
D6.cooldown = 60 * 120
D6.loot_tags = Item.LootTag.CATEGORY_UTILITY 
			 -- Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS 
			 + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR -- The Equipment Activator is a unique interactable found in any Stage 3-TBA. It displays a random Equipment item, which when paid for will activate the Equipment as if used by the player. It can be reused many times, each use costing more than the last. 

ItemLog.new_from_equipment(D6)

RADIUS = 30*10

Callback.add(D6.on_use, function(actor, embryo)
	if not actor:is_authority() then return end

	insts = actor:get_collisions_circle(gm.constants.pPickup, RADIUS)
	for _, inst in pairs(insts) do
		local wrapped = Instance.wrap(inst)

		if inst.equipment_id < 0 then
			item = Item.wrap(inst.item_id)
			lootPools = item:get_available_loot_pools()
			item = lootPools[math.random(1, #lootPools)]:roll()
			item:create(inst.x, inst.y)
			wrapped:destroy()
		else
			equip = Equipment.wrap(inst.equipment_id)
			lootPools = equip:get_available_loot_pools()
			item, equip = lootPools[math.random(1, #lootPools)]:roll()
			equip:create(inst.x, inst.y)
			wrapped:destroy()
		end
	end
	local inst = Instance.create(actor.x, actor.y, Object.wrap(gm.constants.oEfCircle))
    inst.radius = RADIUS
end)