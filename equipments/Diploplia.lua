local sprite = Sprite.new("equipment/Diplopia", "~/assets/sprites/equipments/Diplopia.png", 1, 16, 16)

local Diplopia = Equipment.new("Diplopia")
Diplopia:set_sprite(sprite)
Diplopia.cooldown = 0
Diplopia.loot_tags = Item.LootTag.CATEGORY_UTILITY 
			 -- Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS 
			 + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR -- The Equipment Activator is a unique interactable found in any Stage 3-TBA. It displays a random Equipment item, which when paid for will activate the Equipment as if used by the player. It can be reused many times, each use costing more than the last. 

ItemLog.new_from_equipment(Diplopia)

RADIUS = 30*10

Callback.add(Diplopia.on_use, function(actor, embryo)
	if not actor:is_authority() then return end

	insts = actor:get_collisions_circle(gm.constants.pPickup, RADIUS)
	for _, inst in pairs(insts) do
		inst:instance_copy(true)
	end
	gm.equipment_set(actor.value, -1)
	local inst = Instance.create(actor.x, actor.y, Object.wrap(gm.constants.oEfCircle))
    inst.radius = RADIUS
end)