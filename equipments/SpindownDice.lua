local sprite = Sprite.new("equipment/SpindownDice", "~/assets/sprites/equipments/SpindownDice.png", 1, 16, 16)

local SpindownDice = Equipment.new("SpindownDice")
SpindownDice:set_sprite(sprite)
SpindownDice.cooldown = 60 * 120
SpindownDice.loot_tags = Item.LootTag.CATEGORY_UTILITY 
			 -- Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS 
			 + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR -- The Equipment Activator is a unique interactable found in any Stage 3-TBA. It displays a random Equipment item, which when paid for will activate the Equipment as if used by the player. It can be reused many times, each use costing more than the last. 

ItemLog.new_from_equipment(SpindownDice)

RADIUS = 30*10

Callback.add(SpindownDice.on_use, function(actor, embryo)
	if not actor:is_authority() then return end

    insts = actor:get_collisions_circle(gm.constants.pPickup, RADIUS)
    for _, inst in pairs(insts) do
        local new_pickup = nil
        if (inst.equipment_id < 0) and (inst.item_id > 0) then
            new_pickup = Item.wrap(inst.item_id - 1)
        elseif inst.equipment_id > 0 then
            new_pickup = Equipment.wrap(inst.equipment_id - 1)
        end
        if new_pickup then
            local wrapped = Instance.wrap(inst)
            new_pickup:create(inst.x, inst.y)
            wrapped:destroy()
        end
    end
    local inst = Instance.create(actor.x, actor.y, Object.wrap(gm.constants.oEfCircle))
    inst.radius = RADIUS
end)