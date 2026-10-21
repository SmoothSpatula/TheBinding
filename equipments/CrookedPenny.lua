local sprite = Sprite.new("equipment/CrookedPenny", "~/assets/sprites/equipments/CrookedPenny.png", 1, 16, 16)

local CrookedPenny = Equipment.new("CrookedPenny")
CrookedPenny:set_sprite(sprite)
CrookedPenny.cooldown = 60 * 40
CrookedPenny.loot_tags = Item.LootTag.CATEGORY_UTILITY 
			 -- Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS 
			 + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR -- The Equipment Activator is a unique interactable found in any Stage 3-TBA. It displays a random Equipment item, which when paid for will activate the Equipment as if used by the player. It can be reused many times, each use costing more than the last. 

ItemLog.new_from_equipment(CrookedPenny)

RADIUS = 30*10 -- 10 meters

Callback.add(CrookedPenny.on_use, function(actor, embryo)

	if not actor:is_authority() then return end

    insts = actor:get_collisions_circle(gm.constants.pPickup, RADIUS)
    if math.random(1,2)>1 then 
        for _, inst in pairs(insts) do
            inst:destroy()
        end
        local a = math.random() * math.pi
        local r = math.random(100, 150)
        local gold = Instance.create(actor.x + math.cos(a) * r, actor.y - math.sin(a) * r, Object.wrap(gm.constants.oEfGold))
        gold.target = actor.value
    else
        for _, inst in pairs(insts) do
            inst:instance_copy(true)
        end
    end
    local inst = Instance.create(actor.x, actor.y, Object.wrap(gm.constants.oEfCircle))
    inst.radius = RADIUS
end)