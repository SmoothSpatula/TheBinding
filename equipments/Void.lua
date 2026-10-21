local sprite = Sprite.new("equipment/Void", "~/assets/sprites/equipments/Void.png", 1, 16, 16)

local Void = Equipment.new("Void")
Void:set_sprite(sprite)
Void.cooldown = 60 * 90
Void.loot_tags = Item.LootTag.CATEGORY_UTILITY 
			 -- Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS 
			 + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR -- The Equipment Activator is a unique interactable found in any Stage 3-TBA. It displays a random Equipment item, which when paid for will activate the Equipment as if used by the player. It can be reused many times, each use costing more than the last. 

ItemLog.new_from_equipment(Void)

local stats_void = {damage_add = 1, attack_speed_add = 6, critical_chance_add = 4, pHmax_add = 0.2, pVmax_add = 0.1}
local stats_void_i = {}
for k, _ in pairs(stats_void) do
    table.insert(stats_void_i, k)
end

RADIUS = 30*10

Callback.add(Void.on_use, function(actor, embryo)
	if not actor:is_authority() then return end

    local data = Instance.get_data(actor)
    
    if not data.boi_void_actives then data.boi_void_actives = {} end
    local active_nb = #data.boi_void_actives
    
    insts = actor:get_collisions_circle(gm.constants.pPickup, RADIUS)
    for _, inst in pairs(insts) do
        if (inst.equipment_id < 0) and (inst.item_id > 0) then
            local stat = stats_void_i[math.random(#stats_void_i)]
            local val = stats_void[stat]
            if not data["boi_"..stat] then 
                data["boi_"..stat] = val 
            else 
                data["boi_"..stat] = data["boi_"..stat] + val
            end
            inst:destroy()
        elseif inst.equipment_id>0 then
            local equip = Equipment.wrap(inst.equipment_id)
            data.boi_void_actives[#data.boi_void_actives + 1] = equip.on_use
            inst:destroy()
        end
    end
        
    -- play previous actives
    for i=1, active_nb do
        local inst = actor.value
        inst:callback_execute(data.boi_void_actives[i], inst, false, -1);
    end
    actor:recalculate_stats()

    local inst = Instance.create(actor.x, actor.y, Object.wrap(gm.constants.oEfCircle))
    inst.radius = RADIUS
end)

Callback.add(Callback.ON_EQUIPMENT_SWAP, function(actor, new_equip, old_equip)
    if not old_equip then return end
    if old_equip.namespace..old_equip.identifier == "BoIVoid" then
        local data = Instance.get_data(actor)
        data.boi_void_actives = {}
    end
end)

RecalculateStats.add(Callback.Priority.AFTER, function(actor, api)
    local data = Instance.get_data(actor)
    
    for stat, _ in pairs(stats_void) do 
        if data["boi_"..stat] then
            api[stat]( data["boi_"..stat] ) 
        end
    end
end)