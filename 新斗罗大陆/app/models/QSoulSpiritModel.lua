-- **************************************************
-- Author               : wanghai
-- FileName             : QSoulSpiritModel.lua
-- Description          : 精灵需要在创建英雄后战斗开始前创建，确保属性的添加正确
-- Create time          : 2019-06-17 16:29
-- Last modified        : 2019-06-20 18:15
-- **************************************************

local QActor = import(".QActor")
local QActorProp = import(".QActorProp")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QSoulSpiritModel = class("QSoulSpiritModel", QActor)

--一些属性时按照某个函数计算出来的属性来使用的，结构为 函数名 = {field = 要加到的属性, compose = {"初始化英雄属性时忽略的属性"}}
local propertyFunction = {
    getMaxHpIgnoreHpCoefficient = {field = "hp_value", compose = {"hp_value", "hp_percent", "hp_value_support"}},
    getMaxAttack = {field = "attack_value", compose = {"attack_value", "attack_percent", "attack_value_support"}},
    getMaxMagicArmor = {field = "armor_magic", compose = {"armor_magic", "armor_magic_percent"}},
    getMaxPhysicalArmor = {field = "armor_physical", compose = {"armor_physical", "armor_physical_percent"}},
    getMaxMagicPenetration = {field = "magic_penetration_value", compose = {"magic_penetration_value", "magic_penetration_percent", "extra_magic_penetration_value"}},
    getMaxPhysicalPenetration = {field = "physical_penetration_value", compose = {"physical_penetration_value", "physical_penetration_percent", "extra_physical_penetration_value"}},
}

--一些属性不会走除以4的逻辑，属性名定义到这个字段里
local adjectivePro = {
    critical_damage = true,
    movespeed_replace = true,
    movespeed_value = true,
    movespeed_percent = true,
}

function QSoulSpiritModel:_getTeamHeroForProp()
    if self._team_hero_for_prop == nil then
        self._team_hero_for_prop = {}
        if self._type == ACTOR_TYPES.HERO_NPC then
            table.mergeForArray(self._team_hero_for_prop, app.battle:getHeroes())
        elseif self._type == ACTOR_TYPES.NPC then
            table.mergeForArray(self._team_hero_for_prop, app.battle:getEnemies())
        end
    end
    return self._team_hero_for_prop
end

function QSoulSpiritModel:ctor(soulSpiritInfo, type, isBattle)
    local properties = db:getCharacterByID(soulSpiritInfo.id)
    properties = q.cloneShrinkedObject(properties)
    local data_properties = self:_getCharacterData(properties.id, properties.data_type, nil, nil)
    data_properties = q.cloneShrinkedObject(data_properties)
    data_properties.id, data_properties.data_type, data_properties.npc_difficulty, data_properties.npc_level = nil, nil, nil, nil
    table.merge(properties, data_properties)

    properties.actor_id = properties.id
    local uuid = ((isBattle or IsServerSide)) and replay_uuid() or uuid()
    properties.id = properties.id .. "_" .. uuid
    properties.udid = properties.id
    properties.uuid = uuid

    local actorInfo = {
        is_elf = true,
        properties = properties,
        actorId = soulSpiritInfo.id,
        soulSpiritId = soulSpiritInfo.id,
        level = soulSpiritInfo.level,
        grade = soulSpiritInfo.grade or 0,
        soulSpiritInfo = soulSpiritInfo,
        skills = soulSpiritInfo.skills,
        devour_level = soulSpiritInfo.devour_level -- 用于前端显示

    }

    self._type = type
    -- 现在技能配置在grade表里
    local gradeConfig = db:getGradeByHeroActorLevel(actorInfo.actorId, actorInfo.grade)
    if gradeConfig ~= nil then
        actorInfo.skillIds = {}
        if gradeConfig.soulspirit_pg ~= nil then
            local skills = string.split(gradeConfig.soulspirit_pg, ";")
            for _, skill in ipairs(skills) do
                local idAndLevel = string.split(skill, ":")
                local id, level = idAndLevel[1], idAndLevel[2]
                table.insert(actorInfo.skillIds, tostring(id) .. "," .. tostring(level))
                if self._talentSkillId == nil then
                    self._talentSkillId = tonumber(id)
                end
            end
        end
        if gradeConfig.soulspirit_dz ~= nil then
            local skills = string.split(gradeConfig.soulspirit_dz, ";")
            for _, skill in ipairs(skills) do
                local idAndLevel = string.split(skill, ":")
                local id, level = idAndLevel[1], idAndLevel[2]
                table.insert(actorInfo.skillIds, tostring(id) .. "," .. tostring(level))
                if self._firstManualSkillId == nil then
                    self._firstManualSkillId = tonumber(id)
                end
            end
        end
        if gradeConfig.soulspirit_passive ~= nil then
            local skills = string.split(gradeConfig.soulspirit_passive, ";")
            for _, skill in ipairs(skills) do
                local idAndLevel = string.split(skill, ":")
                local id, level = idAndLevel[1], idAndLevel[2]
                table.insert(actorInfo.skillIds, tostring(id) .. "," .. tostring(level))
            end
        end

        if properties.appear_skill ~= nil then
            local skillId = properties.appear_skill
            local idAndLevel = string.split(skillId, ":")
            local id, level = idAndLevel[1], idAndLevel[2] or 1
            table.insert(actorInfo.skillIds, tostring(id) .. "," .. tostring(level))
            if self._appearSkillId == nil then
                self._appearSkillId = tonumber(id)
            end
        end
        -- 魂灵附加技能(伴生技能等)
        if soulSpiritInfo.additionSkills then
            for _, skillInfo in ipairs(soulSpiritInfo.additionSkills) do
                local id = tostring(skillInfo.key)
                local value = tostring(skillInfo.value)
                table.insert(actorInfo.skillIds, id .. "," .. value)
            end
        end
    else
        if soulSpiritInfo.skills ~= nil then
            actorInfo.skillIds = clone(soulSpiritInfo.skills)
        else
            actorInfo.skillIds = {}
        end
    end

    local skillIdsForAi = self:getSkillIdWithAiType(properties.npc_ai)
    for _, skillId in ipairs(skillIdsForAi) do
        table.insert(actorInfo.skillIds, skillId)
    end

    if soulSpiritInfo.addCoefficient and soulSpiritInfo.addCoefficient > 0 then
        self._soulspirit_property_coefficient = soulSpiritInfo.addCoefficient
    else
        self._soulspirit_property_coefficient = self:getPropertyCoefficient(soulSpiritInfo.id)
    end

    self._actorId = actorInfo.actorId
    self._isSoulSpirit = true
    self._addtionProperty = {} -- 属性数据缓存
    self._finalPropertyCache = {} -- 需要经过计算的属性值缓存

    QSoulSpiritModel.super.ctor(self, actorInfo, nil, nil)
end

function QSoulSpiritModel:getTalent()
    if not self._talentObj then
        local obj = {}
        local info =db:getCharacterByID(self:getActorID())
        obj.func = info.func
        obj.attack_type = info.attack_type
        obj.hatred = info.hatred
        obj.name = info.talent_name
        self._talentObj = obj
    end

    return self._talentObj
end

function QSoulSpiritModel:suicide()
    self:_cancelCurrentSkill()
    self:removeAllBuff()
    self.fsm__:doEvent("kill")
    self._isSuicided = true
end

function QSoulSpiritModel:isHealth()
    return self._jingling_func == 3
end

function QSoulSpiritModel:isDps()
    return self._jingling_func ~= 3
end

function QSoulSpiritModel:isT()
    return self._jingling_func ~= 3
end

function QSoulSpiritModel:getTalentFunc()
    if self:isHealth() then
        return "health"
    else
        return "dps"
    end
end

function QSoulSpiritModel:_applyStaticActorNumberProperties()
    --魂灵初始属性:
    --通常为属性/4
    --部分为计算后的固定值/4
    --其余不改变
    local ignore_field = {}
    local teammates = self:_getTeamHeroForProp()
    for fun_name, cfg in pairs(propertyFunction) do
        for i, _name in ipairs(cfg.compose) do
            ignore_field[_name] = true
        end
        local value = 0
        for i, team in ipairs(teammates) do
            value = value + team[fun_name](team) * self._soulspirit_property_coefficient
        end
        self:removePropertyValue(cfg.field, self)
        self:insertPropertyValue(cfg.field, self, "+", value)
    end
    self.removePropertyValue = function(actor, property_name, stub)
        if ignore_field[property_name] then
            return
        end
        QActor.removePropertyValue(actor, property_name, stub)
    end
    self.insertPropertyValue = function(actor, property_name, stub, operator, value)
        if ignore_field[property_name] then
            return
        end
        if adjectivePro[property_name] == true then
            value = teammates[1]:_getActorNumberPropertyValue(property_name)
        else
            value = 0
            for i, team in ipairs(teammates) do
                value = value + team:_getActorNumberPropertyValue(property_name) * self._soulspirit_property_coefficient
            end
        end
        QActor.insertPropertyValue(actor, property_name, stub, operator, value)
    end
    QSoulSpiritModel.super._applyStaticActorNumberProperties(self)
    self.removePropertyValue = QActor.removePropertyValue
    self.insertPropertyValue = QActor.insertPropertyValue
end


function QSoulSpiritModel:getFirstManualSkill()
    local firstManualSkill = self._firstManualSkill
    if self._firstManualSkill == nil then
        for _, skill in pairs(self._manualSkills) do
            if tonumber(skill:getId()) == self._firstManualSkillId then
                self._firstManualSkill = skill
                break
            end
        end
    end

    return self._firstManualSkill 
end

function QSoulSpiritModel:getRageLimitUpper()
    return 0
end

function QSoulSpiritModel:getNPCSkillId()
    return self._talentSkillId
end

function QSoulSpiritModel:getAppearSkillId()
    return self._appearSkillId
end

function QSoulSpiritModel:getSoulSpiritId()
    return self:getActorID()
end

function QSoulSpiritModel:getSoulSpiritQuality(id)
	local aptitudeInfo = db:getActorSABC(id)
    return aptitudeInfo.qc
end

function QSoulSpiritModel:getPropertyCoefficient(id)
    local quality = self:getSoulSpiritQuality(id)
    local configurationId = tostring(quality) .. "_SOUL_COMBAT_SUCCESSION"
    local value = db:getConfigurationValue(configurationId)

    return value
end

function QSoulSpiritModel:hasRage()
    return true
end

function QSoulSpiritModel:attack(...)
    local result = self.super.attack(self, ...)
    if result then
        self:changeRage(self._rageInfo.talent_rage, false, true)
    end
end

-- 魂灵击杀后给队友回复怒气
function QSoulSpiritModel:onSoulSpiritSkillTarget(bekill_rage)
    local heroes = {} 

    if self._type == ACTOR_TYPES.HERO_NPC then
        heroes = app.battle:getHeroes()
    elseif self._type == ACTOR_TYPES.NPC then
        heroes = app.battle:getEnemies()
    end

    for _, hero in ipairs(heroes) do
        if hero and not hero:isDead() then
            hero:changeRage(bekill_rage * hero._rageInfo.kill_coefficient / 4.0, nil, true)
        end
    end
end

return QSoulSpiritModel

