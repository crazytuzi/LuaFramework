--[[
    Class name QSBSummonGhosts
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBSummonGhosts = class("QSBSummonGhosts", QSBAction)
local QSkill = import("...models.QSkill")
local QBaseEffectView
if not IsServerSide then
    QBaseEffectView = import("...views.QBaseEffectView")
end

function QSBSummonGhosts:_execute(dt)
    local actor = self._attacker
    local target = self._target
    local skill = self._skill
    local ghost_id = self:getOptions().actor_id
    local lockTarget = self:getOptions().lock_target 
    assert(type(ghost_id) == "number", "QSBSummonGhosts: wrong actor_id!")
    local life_span = self:getOptions().life_span
    life_span = life_span and life_span or 5.0

    local pos = self:getOptions().absolute_position
    local clean_new_wave = self:getOptions().clean_new_wave or false
    local fog_effect = self:getOptions().fog_effect or "haunt_3"
    local is_image_pos = self:getOptions().image_pos_hero and self:getOptions().image_pos_npc
    local ignorePosition = self:getOptions().ignorePosition
    if nil == ignorePosition then ignorePosition = true end

    if is_image_pos then
        if self._attacker:getType() == ACTOR_TYPES.HERO then
            pos = self:getOptions().image_pos_hero
        else
            pos = self:getOptions().image_pos_npc
        end
    end

    local targets = {}
    if skill:getRangeType() == skill.SINGLE then
        if skill:getTargetType() == skill.SELF then
            table.insert(targets, actor)
        elseif skill:getTargetType() == skill.TARGET or skill:getTargetType() == skill.COUNTERATTACK_TARGET then
            table.insert(targets, target)
        end
    else
        targets = actor:getMultipleTargetWithSkill(self._skill, self._target, self._director:getTargetPosition())
    end

    local number = nil
    local skill = self._skill
    if skill and skill:isNeedComboPoints() then
        number = actor:getComboPointsConsumed()
    elseif self:getOptions().number then
        number = self:getOptions().number
    else
        number = #targets
    end

    if skill:getGhostLimit() then
        local limit = skill:getGhostLimit()
        local available = limit - skill:getLivingSummonedGhostCount()
        if available <= 0 then
            self:finished()
            return
        else
            number = math.min(number, available)
        end
    end

    if #targets == 0 then
        self:finished()
        return
    end

    local candidates = {}
    local index = 1
    for i = 1, math.ceil(number / #targets) do
        for j = 1, math.min(number, #targets) do
            if index <= number then
                local select_index = app.random(j, #targets)
                local tmp = targets[select_index]
                targets[select_index] = targets[j]
                targets[j] = tmp

                table.insert(candidates, tmp) 
                index = index + 1
            end
        end
    end

    --重新设置actor
    if self:getOptions().trace_to_the_source then
        actor = self:getAncestorSummer() or self._attacker
    end

    local percent = self._options.percents or {}
    local ai_name = self._options.ai_name
    local extends_level_skills = {}
    for i,id in ipairs(self._options.extends_level_skills or {}) do
        extends_level_skills[id] = true
    end

    local skill_level = self._skill:getSkillLevel() or 1

    local attack = actor:getAttack() * (percent.attack or 1)
    local crit = actor:getCrit() * (percent.crit or 1)
    local hit = actor:getHit() * (percent.hit or 1)
    local haste = actor:getMaxHaste() * (percent.haste or 1)
    local pvp_attack_physical = actor:getPVPPhysicalAttackPercent() * (percent.pvp_attack_physical or 1)
    local pvp_attack_magic = actor:getPVPMagicAttackPercent() * (percent.pvp_attack_magic or 1)
    local pvp_reduce_physical = actor:getOriginPVPPhysicalReducePercent() * (percent.pvp_reduce_physical or 1)
    local pvp_reduce_magic = actor:getOriginPVPMagicReducePercent() * (percent.pvp_reduce_magic or 1)
    local hit_level = actor:getHitLevel() * (percent.hit_level or 1)

    local armor_physical = actor:getPhysicalArmor()*(percent.armor_physical or 1)
    local armor_magic = actor:getMagicArmor() * (percent.armor_magic or 1)
    local dodge_chance = actor:getDodge() * (percent.dodge_chance or 1)
    local block_chance = actor:getBlock() * (percent.block_chance or 1)
    local cri_reduce_rating = actor:getCritReduce() * (percent.cri_reduce_rating or 1)

    local physical_damage_percent_attack = actor:getPhysicalDamagePercentAttack() * (percent.physical_damage_percent_attack or 1)
    local magic_damage_percent_attack = actor:getMagicDamagePercentAttack() * (percent.magic_damage_percent_attack or 1)

    local physical_damage_percent_beattack = actor:getPhysicalDamagePercentBeattack() * (percent.physical_damage_percent_beattack or 1)
    local physical_damage_percent_beattack_reduce = actor:getPhysicalDamagePercentBeattackReduce() * (percent.physical_damage_percent_beattack_reduce or 1)

    local magic_damage_percent_beattack = actor:getMagicDamagePercentBeattack() * (percent.magic_damage_percent_beattack or 1)
    local magic_damage_percent_beattack_reduce = actor:getMagicDamagePercentBeattackReduce() * (percent.magic_damage_percent_beattack_reduce or 1)

    local hp = actor:getMaxHp() * (self:getOptions().hp_percent or 1) + (self:getOptions().hp_fixed or 0)

    local function getBuffValue(ghost,v1,v2)
        local result1,result2 = 0,0
        for k,buff in pairs(ghost:getBuffs()) do
            if buff:isGhostBuff() then
                if v1 then
                    result1 = result1 + (buff._effects[v1] or 0)
                end

                if v2 then
                    result2 = result2 + (buff._effects[v2] or 0)
                end
            end
        end

        return result1,result2
    end

    local function getMaxHp(ghost)
        return hp
    end

    local function getAttack(ghost)
        local value,percent = getBuffValue(ghost, "attack_value", "attack_percent")
        return attack*(1 + percent) + value
    end
    local function getCrit(ghost)
        local value = getBuffValue(ghost, "critical_chance") * 100
        return crit + value
    end
    local function getHit(ghost)
        local value = getBuffValue(ghost, "hit_chance") * 100
        return hit + value
    end
    local function getMaxHaste(ghost)
        local value = getBuffValue(ghost, "attackspeed_chance")*100
        return haste + value
    end
    local function getPVPPhysicalAttackPercent(ghost)
        return pvp_attack_physical + getBuffValue(ghost, "pvp_physical_damage_percent_attack")
    end
    local function getPVPMagicAttackPercent(ghost)
        return pvp_attack_magic + getBuffValue(ghost, "pvp_magic_damage_percent_attack")
    end
    local function getPVPPhysicalReducePercent(ghost)
        local value = pvp_reduce_physical + getBuffValue(ghost, "pvp_physical_damage_percent_beattack_reduce")
        return (value > 0.8 and 0.8) or value
    end
    local function getPVPMagicReducePercent(ghost)
        local value = pvp_reduce_magic + getBuffValue(ghost, "pvp_magic_damage_percent_beattack_reduce")
        return (value > 0.8 and 0.8) or value
    end
    local function getHitLevel(ghost)
        local value = getBuffValue(ghost, "hit_rating")*100
        return hit_level
    end


    local function getPhysicalArmor(ghost)
        local percent,value = getBuffValue(ghost ,"armor_physical_percent", "armor_physical")
        return armor_physical * (1 + percent) + value
    end
    local function getMagicArmor(ghost)
        local percent,value = getBuffValue(ghost ,"armor_magic_percent", "armor_magic")
        return armor_magic * (1 + percent) + value
    end
    local function getDodge(ghost)
        local value = getBuffValue(ghost, "dodge_chance") * 100
        return dodge_chance + value
    end
    local function getBlock( ghost )
        local value = getBuffValue(ghost, "block_chance") * 100
        return block_chance + value
    end
    local function getCritReduce( ghost )
        local value = getBuffValue(ghost, "cri_reduce_rating") * 100
        return cri_reduce_rating + value
    end

    local function getPhysicalDamagePercentAttack( ghost )
        local value = getBuffValue(ghost, "physical_damage_percent_attack")
        return physical_damage_percent_attack + value
    end
    local function getMagicDamagePercentAttack( ghost )
        local value = getBuffValue(ghost, "magic_damage_percent_attack")
        return magic_damage_percent_attack + value
    end
    local function getPhysicalDamagePercentUnderAttack( ghost )
        local value1 , value2 = getBuffValue(ghost, "physical_damage_percent_beattack", "physical_damage_percent_beattack_reduce")
        local result = physical_damage_percent_beattack + value1 - physical_damage_percent_beattack_reduce - value2
        return (result < -0.8 and -0.8) or result
    end
    local function getMagicDamagePercentUnderAttack( ghost )
        local value1 , value2 = getBuffValue(ghost, "magic_damage_percent_beattack", "magic_damage_percent_beattack_reduce")
        local result = magic_damage_percent_beattack + value1 - magic_damage_percent_beattack_reduce - value2
        return (result < -0.8 and -0.8) or result
    end

    local appear_skill = self._options.appear_skill
    for _, target in ipairs(candidates) do
        local relative_pos = self:getOptions().relative_pos
        local absolute_pos = self:getOptions().absolute_pos
        local divide_pos = self:getOptions().divide_pos
        local position = clone(target:getPosition())
        if relative_pos then
            position.x = position.x + relative_pos.x
            position.y = position.y + relative_pos.y
        elseif absolute_pos then
            position.x = absolute_pos.x
            position.y = absolute_pos.y
        end
        
        if divide_pos then
            position.x = position.x + app.random(-divide_pos.x, divide_pos.x)
            position.y = position.y + app.random(-divide_pos.y, divide_pos.y)
        end

        local ghostConfig = {
            ghost_id = ghost_id,
            summoner = actor,
            life_span = life_span,
            screen_pos = pos or position,
            is_normal_pet = self:getOptions().is_pet,
            pet_hp_per = skill:getGhostHP() or self:getOptions().hp_percent,
            clean_new_wave = clean_new_wave,
            dead_skill = self:getOptions().dead_skill,
            skin_id = self:getOptions().skin_id,
            is_no_deadAnimation = self:getOptions().is_no_deadAnimation
        }
        local ghost = app.battle:summonGhosts(ghostConfig)

        -- 朝向
        if self._options.direction ~= "" then
            ghost:setDirection(self._options.direction)
        end

        --释放出场技能
        if appear_skill then
            local level = extends_level_skills[appear_skill] and skill_level or 1
            local skill = QSkill.new(appear_skill, {}, ghost, level)
            ghost._skills[appear_skill] = skill
            if self._options.same_target == true then
                ghost:attack(skill,nil,self._target,true)
            else
                ghost:attack(skill,nil,nil,true)
            end
        end
    
        if ghost == nil then
            -- 可能由于自己是援助魂师并且已经下场，所以会召唤失败
            self:finished()
            return
        end

        ghost:setGhostCanBeAttacked(self._options.is_attacked_ghost or false)

        local pos = clone(ghost:getPosition())
        if not relative_pos and not absolute_pos then
            local distance = (target:getRect().size.width + ghost:getRect().size.width) / 2
            pos.x = pos.x + (ghost:getDirection() == ghost.DIRECTION_LEFT and distance or -distance)
        end
        app.grid:moveActorTo(ghost, pos, true, true, ignorePosition)

        if not IsServerSide then
            local view = app.scene:getActorViewFromModel(ghost)
            if self:getOptions().tint_color then
                -- 因为pet会被攻击所以为了让不让攻击颜色取代染色，使用render target进行最后染色
                if self:getOptions().is_pet or self:getOptions().use_render_texture then
                    -- 使用render target最后进行染色
                    local maskRect = CCRect(0, 0, 0, 0)
                    view:setScissorEnabled(true)
                    view:setScissorRects(
                        maskRect,
                        CCRect(0, 0, 0, 0),
                        CCRect(0, 0, 0, 0),
                        maskRect
                    )
                    view:getSkeletonActor():getRenderTextureSprite():setColor(self._options.tint_color)
                    makeNodeFromNormalToGrayLuminance(view:getSkeletonActor():getRenderTextureSprite())
                else
                    -- 直接对每一个骨骼进行染色
                    view:getSkeletonActor():setColor(self._options.tint_color)
                    makeNodeFromNormalToGrayLuminance(view:getSkeletonActor())
                end
            end
            if self:getOptions().set_color then
                -- 因为pet会被攻击所以为了让不让攻击颜色取代染色，使用render target进行最后染色
                if self:getOptions().is_pet then
                    -- 使用render target最后进行染色
                    local maskRect = CCRect(0, 0, 0, 0)
                    view:setScissorEnabled(true)
                    view:setScissorRects(
                        maskRect,
                        CCRect(0, 0, 0, 0),
                        CCRect(0, 0, 0, 0),
                        maskRect
                    )
                    view:getSkeletonActor():getRenderTextureSprite():setColor(self._options.set_color)
                else
                    -- 直接对每一个骨骼进行染色
                    view:getSkeletonActor():setColor(self._options.set_color)
                end
            end

            if not self:getOptions().no_fog then
                local effect_id = self:getOptions().effect_id or "haunt_3"
                local frontEffect, backEffect = QBaseEffectView.createEffectByID(effect_id)
                local effect = frontEffect or backEffect
                effect:setPosition(ghost:getPosition().x, ghost:getPosition().y)
                app.scene:addEffectViews(effect, {isFrontEffect = true})
                effect:playAnimation(effect:getPlayAnimationName(), false)
                local arr = CCArray:create()
                effect:afterAnimationComplete(function()
                    app.scene:removeEffectViews(effect)
                end)
            end
        end

        if lockTarget then
            ghost:setTarget(target)
            ghost:lockTarget()
        end

        if self:getOptions().is_attacked_ghost and self:getOptions().enablehp then
            ghost.getMaxHp = getMaxHp
            ghost:setFullHp()
            if not IsServerSide then
                local view = app.scene:getActorViewFromModel(ghost)
                if view then
                    view:hideHpView()
                end
            end
        end

        -- 鬼的攻击力
        ghost.getAttack = getAttack
        -- 鬼的暴击
        ghost.getCrit = getCrit
        -- 鬼的命中
        ghost.getHit = getHit
        -- 鬼的攻速
        if not self:getOptions().no_haste then
            ghost.getMaxHaste = getMaxHaste
        end
        ghost.getPVPPhysicalAttackPercent = getPVPPhysicalAttackPercent
        ghost.getPVPMagicAttackPercent = getPVPMagicAttackPercent
        ghost.getPVPPhysicalReducePercent = getPVPPhysicalReducePercent
        ghost.getPVPMagicReducePercent = getPVPMagicReducePercent
        ghost.getHitLevel = getHitLevel

        ghost.getPhysicalArmor = getPhysicalArmor
        ghost.getMagicArmor = getMagicArmor
        ghost.getDodge = getDodge
        ghost.getBlock = getBlock
        ghost.getCritReduce = getCritReduce

        ghost.getPhysicalDamagePercentAttack = getPhysicalDamagePercentAttack
        ghost.getMagicDamagePercentAttack = getMagicDamagePercentAttack
        ghost.getPhysicalDamagePercentUnderAttack = getPhysicalDamagePercentUnderAttack
        ghost.getMagicDamagePercentUnderAttack = getMagicDamagePercentUnderAttack
        -- 普攻的伤害
        local attack1 = ghost:getTalentSkill()
        if attack1 then
            attack1:set("damage_type", skill:get("damage_type"))
            attack1:set("damage_p", skill:get("damage_p"))
            attack1:set("physical_damage", skill:get("physical_damage"))
            attack1:set("magic_damage", skill:get("magic_damage"))
        end
        -- 普攻2的伤害
        local attack2 = ghost:getTalentSkill2()
        if attack2 then
            attack2:set("damage_type", skill:get("damage_type"))
            attack2:set("damage_p", skill:get("damage_p"))
            attack2:set("physical_damage", skill:get("physical_damage"))
            attack2:set("magic_damage", skill:get("magic_damage"))
        end

        --替换ai
        if ai_name then
            app.battle:replaceActorAIAndPosition(ghost,ai_name)
        end

        --重新添加技能、设定技能等级
        local real_ai_name = ai_name or ghost:getAIType()
        local skillIds = ghost:getSkillIdWithAiType(real_ai_name)
        --actor的一些技能可以给ghost增加新技能
        for id,skill in pairs(actor._skills) do
            local id = skill:getSkillIdForGhost()
            if id then
                id = id .. "," .. skill:getSkillLevel()
                table.insert(skillIds,id)
            end
        end
        --重新添加ai里的技能
        for i,skillId in ipairs(skillIds) do
            local id,level = ghost:_parseSkillID(skillId)
            if extends_level_skills[id] then
                level = skill_level
            end
            local newSkill = QSkill.new(id,{},ghost,level)
            ghost._skills[id] = newSkill
        end

        --释放出场技能
--         if appear_skill then
--             local level = extends_level_skills[appear_skill] and skill_level or 1
--             local skill = QSkill.new(appear_skill, {}, ghost, level)
--             ghost._skills[appear_skill] = skill
--             ghost:_classifySkillByType()
--             ghost:attack(skill,nil,nil,true)
--         else
            ghost:_classifySkillByType()
--         end

        skill:addSummonedGhost(ghost)
    end

    self:finished()
end

function QSBSummonGhosts:getAncestorSummer()
    local actor
    local last_actor = self._attacker
    while last_actor ~= nil do
        actor = last_actor
        last_actor = app.battle:isGhost(actor)
    end
    return actor
end

function QSBSummonGhosts:_onCancel()

end

return QSBSummonGhosts
