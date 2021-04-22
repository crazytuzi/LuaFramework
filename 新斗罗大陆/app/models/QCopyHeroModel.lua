-- **************************************************
-- Author               : wanghai
-- FileName             : QCopyHeroModel.lua
-- Description          : 复制类model，类似heroModel 
-- Create time          : 2019-10-25 14:43
-- Last modified        : 2019-10-26 20:02
-- **************************************************

local QActor = import(".QActor")
local QSkill = import(".QSkill")
local QCopyHeroModel = class("QCopyHeroModel", QActor)

local QActorProp = import(".QActorProp")

function QCopyHeroModel:ctor(heroInfo, events, callbacks, additionalInfos, copySlots,hasEnchatSkill, hasGodSkill, isBattle, isSupport, isInStory, extraProp)
    local properties = db:getCharacterByID(heroInfo.actorId)
    properties = q.cloneShrinkedObject(properties)

    local data_properties = self:_getCharacterData(properties.id, properties.data_type, nil ,nil)
    data_properties = q.cloneShrinkedObject(data_properties)
    data_properties.id, data_properties.data_type, data_properties.npc_difficulty, data_properties.npc_level = nil, nil, nil, nil
    table.merge(properties,data_properties)

    properties.actor_id = properties.id
    local uuid = (isInStory and story_uuid()) or ((isBattle or IsServerSide) and replay_uuid() or uuid())
    properties.id = properties.id .. "_" .. uuid
    properties.udid = properties.id
    properties.uuid = uuid

    local superSkillInfo
    local attrListProp
    if additionalInfos then
        superSkillInfo = additionalInfos.superSkillInfos[tonumber(heroInfo.actorId)]
        attrListProp = additionalInfos.attrListProp
    end

    local actorInfo = {
        properties = properties,
        actorId = heroInfo.actorId,
        level = heroInfo.level,
        equipments = heroInfo.equipments,
        breakthrough = heroInfo.breakthrough,
        grade = heroInfo.grade,
        rankCode = heroInfo.rankCode,      
        combinations = heroInfo.combinations, 
        trainAttr = heroInfo.trainAttr,  
        slots = heroInfo.slots, 
        heroInfo = heroInfo,
        equipMasterLevel = heroInfo.equipMasterLevel,
        jewelryMasterLevel = heroInfo.jewelryMasterLevel,
        peripheralSkills = heroInfo.peripheralSkills,
        glyphs = heroInfo.glyphs,
        gemstones = heroInfo.gemstones or {},
        -- zuoqi = heroInfo.zuoqi,
        isSupport = isSupport,
        refineAttrs = heroInfo.refineAttrs,
        artifact = heroInfo.artifact,
        totemInfos = heroInfo.totemInfos,
        spar = heroInfo.spar or {},
        skills = heroInfo.skills,
        force = heroInfo.force,
        skinId = heroInfo.skinId,
        magicHerbs = heroInfo.magicHerbs,
        soulSpirit = heroInfo.soulSpirit,
        godSkillGrade = heroInfo.godSkillGrade,
        attrListProp = attrListProp or {},
    }
    if not hasGodSkill then actorInfo.godSkillGrade = 0 end 
    if not hasEnchatSkill then actorInfo.peripheralSkills = nil end 

    self._type = ACTOR_TYPES.HERO_NPC
    superSkillInfo = superSkillInfo or {}
    copySlots = copySlots or {}

    if heroInfo.slots then -- 正常游戏通过slots传递
        -- just have copy slots 
        local tmpSlotDict = {}
        for _, info in ipairs(heroInfo.slots) do
            for _, id in ipairs(copySlots) do
                if info.slotId == id then
                    table.insert(tmpSlotDict, info)
                end
            end
        end
        -- heroInfo.slots = tmpSlotDict

        actorInfo.skillIds = {}

        local slotInfoDict = {}
        for _, info in ipairs(tmpSlotDict) do
            slotInfoDict[tostring(info.slotId)] = info.slotLevel
        end
        for _, slotInfo in ipairs(tmpSlotDict) do
            local level = slotInfo.slotLevel
            local skillId = db:getSkillByActorAndSlot(properties.actor_id, slotInfo.slotId)
            if skillId and level then
                -- 羁绊技能
                if superSkillInfo.skill and slotInfo.slotId == 3 then
                    skillId = superSkillInfo.skill
                    self:setSuperSkillID(tostring(skillId))
                end
                local skillInfo = db:getSkillByID(skillId)
                if skillInfo.link_slot_level then
                    local slotLevel = slotInfoDict[tostring(skillInfo.link_slot_level)]
                    if slotLevel then
                        level = slotLevel
                    end
                end
                table.insert(actorInfo.skillIds, tostring(skillId) .. "," .. tostring(level))
            end
        end
    else
        actorInfo.skillIds = {}
        local skillSlot = db:getSkillSlotConfigByActor(heroInfo.actorId)
        local manualSkillId = skillSlot["slot_3"]
        for _, slotId in ipairs(copySlots) do
            table.insert(actorInfo.skillIds, tostring(skillSlot["slot_" .. slotId]) .. "," .. tostring(heroInfo.level))
        end
    end

    if actorInfo.peripheralSkills then -- 附魔技能
        for _, obj in ipairs(actorInfo.peripheralSkills) do
            local skill_id, level = obj.id, obj.level
            table.insert(actorInfo.skillIds, tostring(skill_id) .. "," .. tostring(level))
        end
    end

    table.insert(actorInfo.skillIds, 300001)
    QCopyHeroModel.super.ctor(self, actorInfo, events, callbacks, extraProp)

    self:setAdditionalManualSkillDamagePercent(superSkillInfo.multiple or 0)
    self._actorId = heroInfo.actorId
    self._isHero = false

    if app.battle ~= nil and app.battle:isInTutorial() then 
        local obj = {}
        local info = db:getCharacterByID(self:getActorID())
        obj.func = info.func
        obj.attack_type = info.attack_type
        obj.hatred = info.hatred
        obj.name = info.talent_name
        
        obj.skill_1 = heroInfo.skills[1]
        local skilldata2 = db:getSkillByID(heroInfo.skills[2])
        if skilldata2.type == "active" then
            obj.skill_2 = heroInfo.skills[2]
        end
        self._talentObj = obj
    end

    self._isSupportHero = false
    self._artifact = actorInfo.artifact
end

function QCopyHeroModel:hit(...)
    return QCopyHeroModel.super.hit(self, ...)
end

function QCopyHeroModel:getTalent()
    if not self._talentObj then
        local obj = {}
        local info = db:getCharacterByID(self:getActorID())
        obj.func = info.func
        obj.attack_type = info.attack_type
        obj.hatred = info.hatred
        obj.name = info.talent_name
        local info = db:getBreakthroughHeroByHeroActorLevel(self:getActorID(), 0)
        obj.skill_1 = db:getSkillByActorAndSlot(self:getActorID(), info.skill_id_1)
        obj.skill_2 = db:getSkillByActorAndSlot(self:getActorID(), info.skill_id_2)
        self._talentObj = obj
    end
    return self._talentObj
end

function QCopyHeroModel:hasRage()
    return true
end

function QCopyHeroModel:isSupportHero()
    return self._isSupportHero
end

function QCopyHeroModel:setIsSupportHero(isSupportHero)
    self._isSupportHero = isSupportHero
end

function QCopyHeroModel:isOpenArtifact()
    return self._artifact ~= nil
end

-- 复制英雄不会涨怒气，防止自动释放大招
function QCopyHeroModel:changeRage(dRage, support, showTip)
end

function QCopyHeroModel:isCopyHero()
    return true
end

function QCopyHeroModel:triggerGodSkill()
    local actorInfo = self._actorInfo
    if not actorInfo.godSkillGrade or actorInfo.godSkillGrade < 1 then return false end 
    local id_string = db:getGodSkillByIdAndGrade(actorInfo.actorId, actorInfo.godSkillGrade).skill_id
    local skillIds = string.split(id_string, ";")
    local skill = self._skills[tonumber(skillIds[1])]

    if skill:getBuffId1() ~= "" and skill:getBuffTargetType1() == QSkill.BUFF_SELF then
        local buff = self:applyBuff(skill:getBuffId1(), self, skill)
        if buff then
            buff:resetCoolDown()
        end
    end
    if skill:getBuffId2() ~= "" and skill:getBuffTargetType2() == QSkill.BUFF_SELF then
        local buff = self:applyBuff(skill:getBuffId2(), self, skill)
        if buff then
            buff:resetCoolDown()
        end
    end
    if skill:getBuffId3() ~= "" and skill:getBuffTargetType3() == QSkill.BUFF_SELF then
        local buff = self:applyBuff(skill:getBuffId3(), self, skill)
        if buff then
            buff:resetCoolDown()
        end
    end

    return true
end

function QCopyHeroModel:useTalentSKill()
    local skill = self:getTalentSkill()
    if skill == nil then return false end
    skill:resetCoolDown()
    self:attack(skill)

    return true
end

function QCopyHeroModel:useManualSkill()
    local skill = self:getFirstManualSkill()
    if skill == nil then return false end
    skill:resetCoolDown()
    self:attack(skill, true)

    return true
end

function QCopyHeroModel:useActiveSkill()
    local skill = self._activeSkillsByPriority[1]
    if skill == nil then return false end
    skill:resetCoolDown()
    self:attack(skill)

    return true
end

function QCopyHeroModel:increaseHp(hp, attacker, skill, not_add_to_log, ignoreSyncTreat, ...)
    if app.battle:isInTotemChallenge() and app.battle:getTotemChallengeAffix(self).kind == 27 then
        hp = 0
    end
    return QCopyHeroModel.super.increaseHp(self, hp, attacker, skill, not_add_to_log, ignoreSyncTreat, ...)
end

function QCopyHeroModel:useChargeSkill()
    if self._chargeSkill == false then return false end
    local chargeSkill = self._chargeSkill
    if chargeSkill == nil then
        for _, skill in pairs(self:getActiveSkills()) do
            if skill:getSkillType() == skill.ACTIVE and skill:getTriggerCondition() == skill.TRIGGER_CONDITION_DRAG_ATTACK then
                chargeSkill = skill
                break
            end
        end

        if chargeSkill == nil then
            self._chargeSkill = false
            return false
        else
            self._chargeSkill = chargeSkill
        end
    end

    if not self:canAttack(chargeSkill) then
        return false
    end

    if chargeSkill:isNeedATarget() then
        local target = self:getTarget()
        if target == nil or target:isDead() then
            return false
        elseif chargeSkill:isInSkillRange(self:getPosition(), target:getPosition(), self, target, false) == false then
            return false
        end
    end

    self:attack(chargeSkill, true)
    return true
end

return QCopyHeroModel

