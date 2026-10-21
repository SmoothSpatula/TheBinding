local sprite = Sprite.new("equipment/box", "~/assets/sprites/equipments/Box.png", 1, 16, 16)

local box = Equipment.new("BoxOfFriends")
box:set_sprite(sprite)
box.cooldown = 60 * 75
box.loot_tags = Item.LootTag.CATEGORY_UTILITY --no i am not blacklisting this from activators. itd be really funny

ItemLog.new_from_equipment(box)

Callback.add(box.on_use, function(actor, embryo)
	if actor:is_authority() then
		GM.sound_play_global(gm.constants.wImpPortal2, 1.6, 1.4)
		
        local friends = Instance.find_all(gm.constants.pFriend)
		
		local maxFire = 1
		
		if embryo then
			maxFire = 2
		end
		
		if #friends > 1 then
			for _, friend in pairs(friends) do
				if not friend.user_name then --ignore the players
					for i = 1, maxFire do
						local clorne = Instance.create(friend.x, friend.y, friend:get_object_index())
						Global.actor_team_set(clorne, actor.team) --set the team to be safe
						clorne:item_give(Item.find(128), 1) --item id 128 is the ghost handler item used by hapmask and jar of souls
						
						--manually prevent drone clones dropping interactables on death, being used in upgrades and recyclers
						if clorne.interactable_child then
							clorne.interactable_child = -1
						end
						if clorne.drone_upgrade_type_id then
							clorne.drone_upgrade_type_id = -1
						end
						if clorne.recycle_tier then
							clorne.recycle_tier = -1
						end
					end
				end
			end
		else
			for i = 1, maxFire do
				local imp = Instance.create(actor.x, actor.y - 8, gm.constants.oImpFriend)
				imp.parent = actor
				Global.actor_team_set(imp, actor.team)
				imp:item_give(Item.find(128), 1)
			end
		end
	end
end)

--remove drones exploding and screaming on expiry and just leave them to fade out like all other ghost actors
Hook.add_pre("gml_Object_pDrone_Destroy_0", function(self, other, result, args)
	if self:item_count(Item.find(128), Item.StackKind.ANY) < 1 then return end
	if Global._current_frame - self.spawn_frame > 900 then --same as ghosthandler expiration condition, they'll otherwise die normally if killed by enemies
		return false
	end
end)