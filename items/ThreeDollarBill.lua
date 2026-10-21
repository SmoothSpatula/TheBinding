local sprite = Sprite.new("equipment/ThreeDollarBill", "~/assets/sprites/items/ThreeDollarBill.png", 1, 16, 16)

local ThreeDollarBill = Item.new("ThreeDollarBill")
ThreeDollarBill:set_sprite(sprite)
ThreeDollarBill:set_tier(ItemTier.RARE)
ItemLog.new_from_item(ThreeDollarBill)

local armsRace = Item.find("armsRaceDroneHandler")

-- == Reimplementation of procs == --

-- Value_0: Nugget proc random(100) < 8
function nugget_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    for i = 1, 2 do
        local s = gm.instance_create(true_target.x, true_target.y, gm.constants.oEfNugget)
        s.value = stack * 8
    end
end

-- Value_59: Chain proc random(100) < 9
function chain_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    print("plasma", parent.plasma_count, stack)
    if parent.plasma_count < stack then
        local s             = gm.instance_create(true_target.x, true_target.y, gm.constants.oEfChain)
        s.parent            = parent
        s.target            = true_target
        parent.plasma_count = parent.plasma_count + 1
    end
end

-- Value_73: Scope proc random(100) < min(0.5 + stack * 0.5, 3)
function scope_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    if not gm.actor_is_boss(target) and math.random(50) < stack then
        local s  = gm.instance_create(target.x, target.y, gm.constants.oEfScope)
        s.target = target
    end
end

-- Value_94: Medallion pickup proc random(100) < 10 * stack
function medallion_pickup_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    if gm.actor_is_boss(target) then
        gm.instance_create(target.x, target.y, gm.constants.oEfMedallionPickup)
    end
end

-- Value_82: Ifrit bullet proc random(100) < 8
function ifrit_bullet_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    local bullet        = gm.instance_create(parent.x, parent.y, gm.constants.oIfritBullet)
    bullet.speed        = 8
    bullet.direction    = 90 - (90 * parent.image_xscale)
    bullet.hspeed       = math.cos(math.rad(bullet.direction)) * bullet.speed
    bullet.image_xscale = parent.image_xscale
    bullet.parent       = parent
    bullet.team         = parent.team
    bullet.is_proc      = true
    bullet.damage       = parent.damage * (3 * stack)
end

-- Value_29 / Value_129: Missile proc random(100) < stack * 10 + stack_129 * 5
function missile_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    gm._proc_missile_queue_for_actor(parent, 1, attack_info.damage * 3)
end

-- Value_57: Missile proc random(100) < stack * 7
function missile_proc_57(attack_info, parent, target, true_target, stack, replica, stack129)
    gm._proc_missile_queue_for_actor(parent, 3, attack_info.damage * 2)
end

-- Value_10 / Value_129: Mortar proc random(100) < 9
function mortar_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    local mortar     = gm.instance_create(parent.x, parent.y - 4, gm.constants.oEfMortar)
    mortar.parent    = parent
    mortar.damage    = math.ceil(attack_info.damage * 1.7 * (stack + stack129 * 0.5))
    mortar.direction = attack_info.direction + (65 * parent.image_xscale) - 6 + math.random(12)
    mortar.speed     = 8
    mortar.hspeed    = math.cos(math.rad(mortar.direction)) * mortar.speed
    mortar.vspeed    = -math.sin(math.rad(mortar.direction)) * mortar.speed
end

-- == From gml_GlobalScript_damager_proc_onhitactor_clientandserver ==--

-- Value_52: Thallium proc
function thallium_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    gm.apply_buff_internal(target, 7, 180, 1)
end

-- Value_16: Taser proc
function taser_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    gm.sound_play_at(gm.constants.wTaser, 1, 1, target.x, target.y)
    gm.apply_buff_internal(target, 10, 60 + 30 * stack, 1)
end

-- Value_8: Damage-over-time proc
function dot_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    if not Net.online or Net.host then 
        local s  = gm.instance_create(target.x, target.y, gm.constants.oDot); 
        s.team   = parent.team; 
        s.target = target; 
        s.parent = parent; 
        s.damage = math.ceil(attack_info.damage * 0.35); 
        s.ticks  = 4 
    end
    local s = gm.instance_create(target.x, target.y, gm.constants.oEfSparks); 
    s.sprite_index = gm.constants.sEfSlash; 
    s.image_yscale = 1
end

-- Value_36: Slow proc
function slow_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    gm.apply_buff_internal(target, 1, 30 + 30 * stack, 1)
end

-- Value_72: Sunder proc
function sunder_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    gm.apply_buff_internal(target, 14, 120 * stack, 1)
end

-- Value_105: Insecticide proc
function insecticide_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    gm.apply_buff_internal(target, 48, 241 + 60 * stack, 1)
    target.buff_insecticide_damage = parent.damage * 0.1
end

-- Value_78: Wisp mine proc
function wisp_mine_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    for i = 0, stack do local s = gm.instance_create(true_target.x + i * 52 * parent.image_xscale, true_target.y, gm.constants.oWispBMineNosync); 
        s:alarm_set(0, 50 + i * 5)
        s.damage                    = attack_info.damage * 2; 
        s.team                      = parent.team; 
        s.parent                    = parent; 
        s.friendly                  = true; 
        s.sprite_index              = gm.constants.sWispBWarningFriendly; 
        s.local_client_is_authority = not Net.online or Net.host
    end
end

-- Value_19: Sticky proc
function sticky_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    local s  = gm.instance_create(target.x, target.y, gm.constants.oEfSticky); 
    s.damage = math.ceil(attack_info.damage * (1 + stack)); 
    s.parent = parent; 
    s.target = true_target;
    s.xx     = math.random(-10, 10)
    s.yy     = math.random(-10, 10)
    s.x      = s.x + s.xx; 
    s.y      = s.y + s.yy; 
end

-- Value_131 / buff 29: Gold and experience proc
function gold_exp_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    local value = math.max(1, math.floor(gm.cost_get_base_gold_price_scale() * 0.375 * (stack + parent.buff_stack[29] * 2)))
    gm.drop_gold_and_exp(target.x - 10 + math.random(20), target.y - 20 + math.random(20), value, false, true, false, 1)
end

-- Value_100: Razor Penny proc
function razor_penny_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    local g = gm.instance_create(target.x, target.y, gm.constants.oEfGold); g.direction = math.random(180); g.speed = 3 + math.random() * 4; g.sprite_index = gm.constants.sEfGoldRazorPenny; g.value = stack
end

-- Value_75: Blaster proc
function blaster_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    local s                     = gm.instance_create(parent.x, parent.y, gm.constants.oEfBlaster); 
    s.direction                 = attack_info.direction; 
    s.parent                    = parent; 
    s.team                      = parent.team; 
    s.max_bounce                = 1 + stack; 
    s.climb                     = attack_info.climb + 10.8; 
    s.local_client_is_authority = true
    s.hspeed                    = math.cos(math.rad(s.direction)) * s.speed
    s.vspeed                    = -math.sin(math.rad(s.direction)) * s.speed
end

local procs = {
    nugget_proc,
    chain_proc,
    scope_proc,
    medallion_pickup_proc,
    ifrit_bullet_proc,
    missile_proc,
    missile_proc_57,
    mortar_proc,
    -- gml_GlobalScript_damager_proc_onhitactor_clientandserver procs
    thallium_proc,
    taser_proc,
    dot_proc,
    slow_proc,
    sunder_proc,
    insecticide_proc,
    wisp_mine_proc,
    sticky_proc,
    gold_exp_proc,
    razor_penny_proc,
    blaster_proc,
}

function random_proc(attack_info, parent, target, true_target, stack, replica, stack129)
    local proc = procs[math.random(#procs)]
    return proc(attack_info, parent, target, true_target, stack, replica, stack129)
end

Callback.add(Callback.ON_HIT_PROC, function(parent, target, hit_info)
    local stack = parent:item_count(ThreeDollarBill)
    if stack <= 0 or math.random(4) > 2 then return end

    local attack_info   = hit_info.attack_info
    local target        = hit_info.target.value
    local true_target   = hit_info.target_true.value
    local replica       = attack_info.attack_flags & AttackFlag.FORCE_PROC
    local stack129      = parent:item_count(armsRace)

    random_proc(attack_info, parent.value, target, true_target, stack, replica, stack129)
end)