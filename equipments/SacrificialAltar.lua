local sprite = Sprite.new("equipment/altar", "~/assets/sprites/equipments/Altar.png", 1, 16, 16)

local box = Equipment.new("SacrificialAltar")
box:set_sprite(sprite)
box.cooldown = 60 * 1
box.loot_tags = Item.LootTag.CATEGORY_UTILITY + Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR

ItemLog.new_from_equipment(box)

--custom altar item pool, needs weights, dunno where i'd start beyond duplicating entries which'd look awful
local pool = {
		"Hoof", "Glasses", "Dice", "Thorns", "Blade", "Tooth",
		"Rage", "Bottled", "PoisonMine", "Poison", "Scythe", "Pelt", "Medallion", "Insecticide",
		"Mask", "Dagger", "Cannon", "LaserTurbine", "SkullRing", "AlienHead", "Axe", "Hitlist", "Scepter", "Fireshoe", "JackBox",
		"ImpTentacle", "WormEye", "Horn",
		"Void", "Brain", "Lantern", "Mirror", "Sawmerang", "JarSouls", "Key", "Doll", "Leech", "Meteor"
	}

Callback.add(box.on_use, function(actor, embryo)
	if actor:is_authority() then
		
        local friends = Instance.find_all(gm.constants.pFriend)
		
		local realFriends = #friends
		
		for _, friend in ipairs(friends) do
			if friend:item_count(Item.find(128), Item.StackKind.ANY) > 0 then
				realFriends = realFriends - 1
			end
			if friend:get_object_index() == gm.constants.oP then
				realFriends = realFriends - 1
			end
		end
		
		local maxKills = 2 
		
		if embryo then
			maxKills = 4
		end
		
		for i = 1, maxKills do
			if realFriends > 0 then
			
				::redo::
				
				local pos
				if realFriends == 1 then
					pos = 2
				else
					pos = math.random(1, #friends)
				end
				
				local victim = Instance.find(gm.constants.pFriend, pos)
				
				--prevent ghost drones (boxoffriends) and players from being saaced
				local filter = victim:item_count(Item.find(128), Item.StackKind.ANY) <= 0 and victim:get_object_index() ~= gm.constants.oP
				
				local attempts = 0
				
				if Instance.exists(victim) then
					while not (filter) and attempts < 48 do
						victim = Instance.find(gm.constants.pFriend, pos)
						attempts = attempts + 1
					end
				end
				
				if filter then
				
					if victim.interactable_child then --no drone interactable drop :)
						victim.interactable_child = -1
					end
					
					--impfriend tentacle removal
					local removal = nil
					if victim:get_object_index() == gm.constants.oImpFriend and actor:item_count(Item.find("impOverlordsTentacle"), Item.StackKind.ANY) > 0 then
						removal = 1
					end
					
					victim:kill()
					
					if removal == 1 then
						actor:item_take(Item.find("impOverlordsTentacle"), 1, Item.StackKind.ANY)
					end
					
					local roll = pool[math.random(1, #pool)]
					
					--also don't let the impfriend drop imp tentacle if sacrificed, lmao
					if removal == 1 then
						local attempts2 = 0
						while roll == "ImpTentacle" and attempts < 48 do
							roll = pool[math.random(1, #pool)]
							attempts2 = attempts2 + 1
						end
					end
					
					Object.find(roll):create(victim.x, victim.y)
				else
					--just retry this loop if it still dodged the filter and if other realfriends exist
					if realFriends > 0 then
						goto redo
					end
				end
				
				--fx trigger, only need it once
				if i == 1 then
					GM.sound_play_global(gm.constants.wWormRoar, 1, 0.8) --wraaaaaaaaaa hah hah hah haaaaaaa
			
					local data = Instance.get_data(actor)
					data.altarDoShake = 60 * 3
					data.altarAlpha = 0
				end
				
				--need to break the loop or else everyone dies
				--#friends/realFriends size does not change until after each loop is finished, and killed actors are fully destroyed by the game
				if realFriends > 0 and i == maxKills then
					gm.equipment_set(actor.value, -1)
					break
				elseif realFriends == 1 then --only one ally left to kill
					gm.equipment_set(actor.value, -1)
					break
				end
			
			end
		end
		
		
	end
end)

--shake sceen
Callback.add(Callback.ON_PLAYER_STEP, function(actor)
	local data = Instance.get_data(actor)
	if not data.altarDoShake then return end
	
	if data.altarDoShake > 0 then
		data.altarDoShake = data.altarDoShake - 1
		data.altarAlpha = data.altarAlpha + 0.003
		actor:screen_shake(1)
	elseif data.altarDoShake <= 0 then
		data.altarAlpha = data.altarAlpha - 0.007
	end
	
	if data.altarAlpha <= 0 and data.altarDoShake <= 0 then
		data.altarAlpha = nil
		data.altarDoShake = nil
	
	end
	
end)

--draw skeen
Callback.add(Callback.PRE_HUD_DRAW, function()
	local actor = Player.get_local()
	local data = Instance.get_data(actor)
	if not data.altarDoShake then return end
	if data.altarAlpha <= 0 then return end
	
	Global.draw_screen(data.altarAlpha, 0)

end)