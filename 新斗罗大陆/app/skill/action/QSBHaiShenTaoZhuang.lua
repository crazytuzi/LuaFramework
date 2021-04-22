--[[
    海神套装专用脚本
    这个技能要配置成AOE技能， AOE中心就配置target，脚本会根据触发AOE的人来自动改变target

    duration:脚本持续时间
    interval:触发的间隔
    shelter_coefficient:庇护的伤害系数
    near_death_cd:濒死触发护盾的cd
    absorb_buff_id:护盾的buff ID
    near_death_coefficient:濒死增加最大血量的多少的护盾
    shelter_damage_coefficient:庇护的伤害系数 默认是1
    shelter_damage_effect_id:庇护的特效ID
    shelter_damage_effect_id2:庇护的特效ID
    shelter_damage_split: 填写true会根据人数来分割伤害，否则不会
    trigger_damage_count：填写多少次触发一次伤害
    near_death_buff_id:濒死的护盾buff id
    near_death_buff_id2:濒死表现的buff id
    shelter_buff_id:被庇护的人上的表现buff,这个buff持续时间180即可 程序会自动移除
    shelter_buff_id2:被庇护的人上的表现buff,这个buff持续时间180即可 程序会自动移除

    debuff_id:被普攻后会上的debuff的id
--]]
local QSBAction = import(".QSBAction")
local QSBHaiShenTaoZhuang  = class("QSBHaiShenTaoZhuang", QSBAction)
local QActor = import("...models.QActor")

local function getTime()
    return app.battle:getDungeonDuration() - app.battle:getTimeLeft()
end

function QSBHaiShenTaoZhuang:getDecreaseHpCallback()
    if self._decreaseHpCallback == nil then
        self._decreaseHpCallback = 
        {
            name = "decreaseHp",
            functionBefore = function(params)
                local actor, hp, attacker, skill, no_render, isAOE, ignoreAbsorb, not_add_to_log, isExecute = table.unpack(params, 1, params.n)
                --计算是否处于濒死状态
                local left_hp = actor:getHp() + (ignoreAbsorb and 0 or 1) * (skill and skill:getReduceAbsorbPercent() or 1) * actor:getAbsorbDamageValue()
                local cd_time = app.battle:getFromMap(self._attacker:getType(), "HAISHENTAOZHUANG_NEAR_DEATH_CD_TIME") or 0
                --处于濒死状态且cd ok那么就加护盾
                if cd_time <= getTime() and hp >= left_hp and not isExecute then
                    local buff = actor:applyBuff(self._options.near_death_buff_id, self._attacker, self._skill)
                    local real_absorb = actor:getMaxHp() * self._options.near_death_coefficient
                    if buff then
                        local old_value = buff:getAbsorbDamageValue()
                        local newValue = buff:setAbsorbDamageValue(old_value + real_absorb, true)
                        actor:dispatchAbsorbChangeEvent(newValue - old_value)
                        actor:applyBuff(self._options.near_death_buff_id2, self._attacker, self._skill)
                        self:playMountSkillAnimation()
                    end

                    app.battle:setFromMap(self._attacker:getType(), "HAISHENTAOZHUANG_NEAR_DEATH_CD_TIME", getTime() + self._options.near_death_cd)
                end
            end,
            functionEnd = function(params, result)
                local actor, hp, attacker, skill, no_render, isAOE, ignoreAbsorb, not_add_to_log, isExecute = table.unpack(params, 1, params.n)
                --处于庇护状态下的人要记录庇护的血量
                if actor == app.battle:getFromMap(self._attacker:getType(), "HAISHENTAOZHUANG_SHELTER_ACTOR") then
                    local old_value = app.battle:getFromMap(actor, "HAISHENTAOZHUANG_SHELTER_VALUE") or 0
                    app.battle:setFromMap(actor, "HAISHENTAOZHUANG_SHELTER_VALUE", (result[2] or 0) * self._options.shelter_coefficient + old_value)
                    --处于庇护下的人被攻击后还要给对方上debuff
                    if self._options.debuff_id and attacker and skill and skill:isTalentSkill() then
                        attacker:applyBuff(self._options.debuff_id, self._attacker, self._skill)
                    end
                end
            end
        }
    end
    return self._decreaseHpCallback
end

function QSBHaiShenTaoZhuang:ctor(director, attacker, target, skill, options)
    QSBHaiShenTaoZhuang.super.ctor(self, director, attacker, target, skill, options)
    self._last_trigger_time = 0
    self._changed_actors = {}
    self._trigger_damage_count = self._options.trigger_damage_count
    self._hash_ik = {}
    self._hash_ki = {}
end

function QSBHaiShenTaoZhuang:getHash(obj)
    if obj == nil then return 0 end
    if self._hash_ki[obj] then
        return self._hash_ki[obj]
    else
        table.insert(self._hash_ik, obj)
        local hash = #self._hash_ik
        self._hash_ki[obj] = hash
        return hash
    end
end

function QSBHaiShenTaoZhuang:getObjectByHash(hash)
    if hash == 0 then return nil end
    return self._hash_ik[hash]
end

function QSBHaiShenTaoZhuang:onSkillEnd()
    local callback = self:getDecreaseHpCallback()
    for hash, _ in pairs(self._changed_actors) do
        local actor = self:getObjectByHash(hash)
        if actor then
            actor:removeFunctionCallBack(callback)
        end
    end
end

function QSBHaiShenTaoZhuang:changeShelterActor()
    local last_actor = app.battle:getFromMap(self._attacker:getType(), "HAISHENTAOZHUANG_SHELTER_ACTOR")
    local shelter_count = app.battle:getFromMap(self._attacker:getType(), "HAISHENTAOZHUANG_SHELTER_COUNT") or 0
    if last_actor then
        local buff = last_actor:applyBuff(self._options.absorb_buff_id, self._attacker, self._skill)
        local real_absorb = app.battle:getFromMap(last_actor, "HAISHENTAOZHUANG_SHELTER_VALUE")
        last_actor:removeBuffByID(self._options.shelter_buff_id)
        last_actor:removeBuffByID(self._options.shelter_buff_id2)
        if buff then
            local old_value = buff:getAbsorbDamageValue()
            local newValue = buff:setAbsorbDamageValue(old_value + real_absorb, true)
            last_actor:dispatchAbsorbChangeEvent(newValue - old_value)

            --偶数次触发会有伤害
            if self._trigger_damage_count and (shelter_count % self._trigger_damage_count == 0) and self._options.shelter_damage_coefficient > 0 then
                local targets = self._attacker:getMultipleTargetWithSkill(self._skill, last_actor)
                if self._options.shelter_damage_effect_id then
                    last_actor:playSkillEffect(self._options.shelter_damage_effect_id, nil, {})
                end
                if self._options.shelter_damage_effect_id2 then
                    last_actor:playSkillEffect(self._options.shelter_damage_effect_id2, nil, {})
                end
                self:playMountSkillAnimation()
                if #targets > 0 then
                    local damage = real_absorb * self._options.shelter_damage_coefficient
                    if self._options.shelter_damage_split then
                        damage = damage / #targets
                    end
                    local override_damage = 
                    {
                        damage = damage,
                        tip = "",
                        critical = false,
                        hit_status = "hit",
                        ignore_damage_to_absorb = true,
                    }
                    for i,target in ipairs(targets) do
                        self._attacker:hit(self._skill, target, nil, override_damage, nil, true)
                    end
                end
            end
        end
    end

    local minHpActor = self:getObjectByHash(next(self._changed_actors))
    if minHpActor ~= nil then
        for hash, _ in pairs(self._changed_actors) do
            local actor = self:getObjectByHash(hash)
            if actor and actor:getHp()/actor:getMaxHp() < minHpActor:getHp()/minHpActor:getMaxHp() then
                minHpActor = actor
            end
        end
        minHpActor:applyBuff(self._options.shelter_buff_id, self._attacker, self._skill)
        minHpActor:applyBuff(self._options.shelter_buff_id2, self._attacker, self._skill)
        app.battle:setFromMap(minHpActor, "HAISHENTAOZHUANG_SHELTER_VALUE", 0)
        app.battle:setFromMap(self._attacker:getType(), "HAISHENTAOZHUANG_SHELTER_ACTOR", minHpActor)
    end
    app.battle:setFromMap(self._attacker:getType(), "HAISHENTAOZHUANG_SHELTER_COUNT", shelter_count + 1)
end

function QSBHaiShenTaoZhuang:_onChangeActor(actor)
    actor:addFunctionCallBack(self:getDecreaseHpCallback())
end

function QSBHaiShenTaoZhuang:checkActors()
    local targets = app.battle:getMyTeammates(self._attacker, true, true)
    for i, target in ipairs(targets) do
        if not target:isSupport() then
            local hash = self:getHash(target)
            if self._changed_actors[hash] ~= true then
                self:_onChangeActor(target)
                self._changed_actors[hash] = true
            end
        end
    end
    local dead_actors = {}
    for hash, _ in pairs(self._changed_actors) do
        local target = self:getObjectByHash(hash)
        if target and target:isDead() then
            table.insert(dead_actors, target)
        end
    end

    for i,target in ipairs(dead_actors) do
        target:removeFunctionCallBack(self:getDecreaseHpCallback())
        self._changed_actors[self:getHash(target)] = nil
        if app.battle:getFromMap(self._attacker:getType(), "HAISHENTAOZHUANG_SHELTER_ACTOR") == target then
            app.battle._map_cache:setObject(self._attacker:getType(), "HAISHENTAOZHUANG_SHELTER_ACTOR", nil)
        end
    end
end

function QSBHaiShenTaoZhuang:playMountSkillAnimation()
    local actor = self._attacker
    if not IsServerSide then 
        app.scene:playGodArmAnimation(actor, self._skill, true)
    end
end

function QSBHaiShenTaoZhuang:checkRunningSkill()
    if self._attacker:isSupport() then
        self:finished()
        return false
    end

    local sbDirector = app.battle:getFromMap(self._attacker:getType(), "HAISHENTAOZHUANG_CURRENT_SBDIRECTOR")
    if sbDirector == nil then
        self:playMountSkillAnimation()
    end

    if sbDirector == nil or sbDirector:isSkillFinished() then
        sbDirector = self._director
        app.battle:setFromMap(self._attacker:getType(), "HAISHENTAOZHUANG_CURRENT_SBDIRECTOR", sbDirector)
    end

    return sbDirector == self._director
end

function QSBHaiShenTaoZhuang:_execute(dt)
    if self:checkRunningSkill() ~= true then
        return
    end
    local cur_time = getTime()
    if cur_time > self._options.duration then
        self:onSkillEnd()
        self:finished()
        return
    end

    self:checkActors()

    local lastTriggerTime = app.battle:getFromMap("HAISHENTAOZHUANG_LAST_TRIGGER_TIME") or 0
    if cur_time - lastTriggerTime >= self._options.interval then
        self:changeShelterActor()
        app.battle:setFromMap("HAISHENTAOZHUANG_LAST_TRIGGER_TIME", cur_time)
    end
end

return QSBHaiShenTaoZhuang