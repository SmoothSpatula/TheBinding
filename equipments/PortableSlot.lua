local sprite = Sprite.new("equipment/PortableSlot", "~/assets/sprites/equipments/PortableSlot.png", 1, 16, 16)


-- 		local filter = not string.find(item.identifier, "elite") and not string.find(item.identifier, "Handler") and item.identifier ~= "hitListTally" and item.identifier ~= "diosFriendUsed" and item.identifier ~= "timeKeepersSecretUsed" and item.identifier ~= "goldOnHit" and item.identifier ~= "cancel" and item.identifier ~= "dummyItem" and item.identifier ~= "nkotasHeritage" --this is not a startstorm leak vro trust


local PortableSlot = Equipment.new("PortableSlot")
PortableSlot:set_sprite(sprite)
PortableSlot.cooldown = 60 * 1
PortableSlot.loot_tags = Item.LootTag.CATEGORY_UTILITY 
			 -- Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS 
			 + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR -- The Equipment Activator is a unique interactable found in any Stage 3-TBA. It displays a random Equipment item, which when paid for will activate the Equipment as if used by the player. It can be reused many times, each use costing more than the last. 

ItemLog.new_from_equipment(PortableSlot)

local SLOT_COST = 20
local SNAKE_EYES = Item.find("snakeEyes", "ror")
local SNAKE_EYES_BUFF = Buff.find("dice", "ror")
local COST_MULT = 1.1

Callback.add(PortableSlot.on_use, function(actor, embryo)
	if not actor:is_authority() then return end

	local data = Instance.get_data(actor)

	local inst = actor.value
	local cost = data.BoI_PortableSlotCost * gm.cost_get_base_gold_price_scale()

	if gm.bool(gm.interactable_check_cost(0, cost, inst)) then
		if gm.is_local_player(inst) then
			local oHUD = gm.instance_find(gm.constants.oHUD, 0)
			oHUD.gold = oHUD.gold - cost
		else
			inst.gold = inst.gold - cost
		end

		data.BoI_PortableSlotCost = math.ceil(data.BoI_PortableSlotCost * COST_MULT)

		local res = actor:treasure_weights_roll_pickup_and_handle_artifacts(15, nil)
		if math.random(1,2) > 1 then res = -1 end
		if res > -1 then
			gm.instance_create(inst.x, inst.bbox_top - 15, res)
			inst.game_report.shrine_win_streak = inst.game_report.shrine_win_streak + 1
			inst.game_report.shrine_loss_streak = 0
			inst.game_report.shrine_win_max = math.max(inst.game_report.shrine_win_max, inst.game_report.shrine_win_streak)
		else
			inst.game_report.shrine_loss_streak = inst.game_report.shrine_loss_streak + 1
			inst.game_report.shrine_win_streak = 0
			inst.game_report.shrine_loss_max = math.max(inst.game_report.shrine_loss_max, inst.game_report.shrine_loss_streak)

			if actor:item_count(SNAKE_EYES) > 0 then
				actor:buff_apply(SNAKE_EYES_BUFF, 72000, 1)
				gm.instance_create(inst.x, inst.bbox_top - 15, gm.constants.oEfSnakeEyes)
			end
		end
    end
end)

Callback.add(Callback.ON_EQUIPMENT_SWAP, function(actor, new_equip, old_equip)
    if not new_equip then return end
    if new_equip.namespace..new_equip.identifier == "BoIPortableSlot" then
        local data = Instance.get_data(actor)
        if not data.BoI_PortableSlotCost then
			data.BoI_PortableSlotCost = SLOT_COST
		end
    end
end)


Callback.add(Callback.ON_PLAYER_HUD_DRAW, function(player, hud_x, hud_y)
	if player.inventory_equipment ~= PortableSlot.value then return end
    local data = Instance.get_data(player)
	if not data.BoI_PortableSlotCost then return end
    local x, y = hud_x + 170, hud_y

    gm.scribble_set_starting_format("fntNormal", 8114927, 0)
	gm.scribble_draw(x, y, "$".. math.ceil(data.BoI_PortableSlotCost *  gm.cost_get_base_gold_price_scale()))
    
end)