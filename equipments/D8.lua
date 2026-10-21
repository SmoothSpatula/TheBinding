local sprite = Sprite.new("equipment/D8", "~/assets/sprites/equipments/D8.png", 1, 16, 16)


-- 		local filter = not string.find(item.identifier, "elite") and not string.find(item.identifier, "Handler") and item.identifier ~= "hitListTally" and item.identifier ~= "diosFriendUsed" and item.identifier ~= "timeKeepersSecretUsed" and item.identifier ~= "goldOnHit" and item.identifier ~= "cancel" and item.identifier ~= "dummyItem" and item.identifier ~= "nkotasHeritage" --this is not a startstorm leak vro trust


local D8 = Equipment.new("D8")
D8:set_sprite(sprite)
D8.cooldown = 60 * 60
D8.loot_tags = Item.LootTag.CATEGORY_UTILITY 
			 -- Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS 
			 + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR -- The Equipment Activator is a unique interactable found in any Stage 3-TBA. It displays a random Equipment item, which when paid for will activate the Equipment as if used by the player. It can be reused many times, each use costing more than the last. 

ItemLog.new_from_equipment(D8)

local stats = {"maxhp_mult", "damage_mult", "attack_speed_mult", "pHmax_mult", "pVmax_mult"}

Callback.add(D8.on_use, function(actor, embryo)
	if not actor:is_authority() then return end

    local data = Instance.get_data(actor)
    for _, stat in pairs(stats) do data["boi_"..stat] = math.random()*1.5 + 0.5 end
    actor:recalculate_stats()
end)

RecalculateStats.add(Callback.Priority.AFTER, function(actor, api)
    local data = Instance.get_data(actor)
    if not data.boi_maxhp_mult then return end

    for _, stat in pairs(stats) do api[stat]( data["boi_"..stat] ) end
end)
