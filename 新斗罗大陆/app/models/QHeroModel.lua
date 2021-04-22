
--[[--

“魂师”类

从“角色”类继承，增加了经验值等属性

]]

local QActor = import(".QActor")
local QHeroModel = class("QHeroModel", QActor)

local QActorProp = import(".QActorProp")

QHeroModel.EXP_CHANGED_EVENT = "EXP_CHANGED_EVENT"
QHeroModel.LEVEL_UP_EVENT = "LEVEL_UP_EVENT"

function QHeroModel:ctor(heroInfo, events, callbacks, isReplay, additionalInfos, isBattle, isSupport, isInStory, additional_skills, extraProp)
    local properties = db:getCharacterByID(heroInfo.actorId)
    -- if properties == nil then
    --     echoError("Hero with id: %s not found!", tostring(heroInfo.actorId))
    -- end
    -- TOFIX: SHRINK
    properties = q.cloneShrinkedObject(properties)

    local data_properties = self:_getCharacterData(properties.id, properties.data_type, nil, nil)
    -- TOFIX: SHRINK
    data_properties = q.cloneShrinkedObject(data_properties)
    data_properties.id, data_properties.data_type, data_properties.npc_difficulty, data_properties.npc_level = nil, nil, nil, nil
    table.merge(properties, data_properties)

    properties.actor_id = properties.id
    local uuid = (isInStory and story_uuid()) or ((isBattle or IsServerSide) and replay_uuid() or uuid())
    properties.id = properties.id .. "_" .. uuid
    properties.udid = properties.id
    properties.uuid = uuid

    local superSkillInfo
    local combinationProp
    local unionSkillProp
    local avatarProp
    local archaeologyProp
    local teamGlyphInfo
    local badgeProp
    local mountCombinationProp
    local soulSpiritCombinationProp
    local soulTrialProp
    local attrListProp
    local godarmReformProp
    if additionalInfos then
        superSkillInfo = additionalInfos.superSkillInfos[tonumber(heroInfo.actorId)]
        combinationProp = additionalInfos.combinationProps[tonumber(heroInfo.actorId)]
        unionSkillProp = additionalInfos.unionSkillProp
        avatarProp = additionalInfos.avatarProp
        archaeologyProp = additionalInfos.archaeologyProp
        teamGlyphInfo = additionalInfos.teamGlyphInfo
        badgeProp = additionalInfos.badgeProp
        mountCombinationProp = additionalInfos.mountCombinationProp
        soulSpiritCombinationProp = additionalInfos.soulSpiritCombinationProp
        godarmReformProp = additionalInfos.godarmReformProp
        soulTrialProp = additionalInfos.soulTrialProp
        attrListProp = additionalInfos.attrListProp
    end 

    superSkillInfo = superSkillInfo or {}
    local actorInfo = {
        -- 全局属性
        combinationProp = combinationProp or heroInfo.combinationProp,
        unionSkillProp = unionSkillProp or heroInfo.unionSkillProp,
        avatarProp = avatarProp or heroInfo.avatarProp,
        archaeologyProp = archaeologyProp or heroInfo.archaeologyProp,
        teamGlyphInfo = teamGlyphInfo or heroInfo.teamGlyphInfo,
        badgeProp = badgeProp or {},
        mountCombinationProp = mountCombinationProp or heroInfo.mountCombinationProp,
        soulSpiritCombinationProp = soulSpiritCombinationProp or heroInfo.soulSpiritCombinationProp,
        godarmReformProp = godarmReformProp or heroInfo.godarmReformProp,
        soulTrialProp = soulTrialProp or heroInfo.soulTrialProp,
        attrListProp = attrListProp or heroInfo.attrListProp,
        -- 全局属性
        
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
        peripheralSkills = heroInfo.peripheralSkills,-- 附魔技能
        glyphs = heroInfo.glyphs,
        gemstones = heroInfo.gemstones or {},
        zuoqi = heroInfo.zuoqi,
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
    }

    self._type = ACTOR_TYPES.HERO
    if heroInfo.slots then -- 正常游戏通过slots传递
        actorInfo.skillIds = {}

        local slotInfoDict = {}
        for _, info in ipairs(heroInfo.slots) do
            slotInfoDict[tostring(info.slotId)] = info.slotLevel
        end

        for _, slotInfo in ipairs(heroInfo.slots) do
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
        self:setDeputyActorIDs(superSkillInfo.deputies)
    else
        if heroInfo.skills then -- 编辑模式通过skills传递
            actorInfo.skillIds = clone(heroInfo.skills)
            -- 羁绊技能
            if app.battle and app.battle:isPVPMode() and app.battle:isInEditor() then
                if heroInfo.super_skill and db:getAssistSkill(tonumber(heroInfo.actorId)) then -- 斗魂场编辑模式下使用传递过来的super_skill决定开启羁绊技能
                    local config = db:getAssistSkill(tonumber(heroInfo.actorId))
                    superSkillInfo = {skill = config.Super_skill, deputies = {}}
                    if config.Deputy_hero1 then
                        superSkillInfo.deputies[config.Deputy_hero1] = true
                    end
                    if config.Deputy_hero2 then
                        superSkillInfo.deputies[config.Deputy_hero2] = true
                    end
                    if config.Deputy_hero3 then
                        superSkillInfo.deputies[config.Deputy_hero3] = true
                    end
                else
                    superSkillInfo = {}
                end
            end
            if superSkillInfo.skill then
                local skillSlot = db:getSkillSlotConfigByActor(heroInfo.actorId)
                local manualSkillId = skillSlot["slot_3"]
                for index, skill in ipairs(actorInfo.skillIds) do
                    if skill == manualSkillId or skill == tostring(manualSkillId) then
                        actorInfo.skillIds[index] = tostring(superSkillInfo.skill)
                        break
                    elseif type(skill) == "string" then
                        local items = string.split(skill, ",")
                        if items[1] == tostring(manualSkillId) then
                            if items[2] == nil then
                                actorInfo.skillIds[index] = tostring(superSkillInfo.skill)
                                break
                            else
                                actorInfo.skillIds[index] = tostring(superSkillInfo.skill) .. "," .. items[2]
                                break
                            end
                        end
                    end
                end
                self:setSuperSkillID(tostring(superSkillInfo.skill))
            end
            self:setDeputyActorIDs(superSkillInfo.deputies)
        else
            actorInfo.skillIds = {}
        end
    end
    if heroInfo.peripheralSkills then -- 通过装备或其他方式获得的技能
        for _, obj in ipairs(heroInfo.peripheralSkills) do
            local skill_id, level = obj.id, obj.level
            table.insert(actorInfo.skillIds, tostring(skill_id) .. "," .. tostring(level))
        end
    end
    if heroInfo.artifact ~= nil then -- 武魂真身技能
        for _, artifactSkill in ipairs(heroInfo.artifact.artifactSkillList or {}) do
            table.insert(actorInfo.skillIds, tostring(artifactSkill.skillId) .. "," .. tostring(artifactSkill.skillLevel))
        end
    end
    if actorInfo.properties.appear_skill then
        self._appearSkillId = actorInfo.properties.appear_skill
        table.insert(actorInfo.skillIds, tostring(self._appearSkillId) .. "," .. tostring(1))
    end

    if additional_skills then
        local info = db:getCharacterByID(actorInfo.actorId)
        for _, skill_str in pairs(additional_skills) do
            local lis = string.split(skill_str, ":")
            local config = db:getSkillByID(lis[1])
            if config.god_arm_skill_add_for == nil or config.god_arm_skill_add_for == info.func then
                table.insert(actorInfo.skillIds, lis[1] .. "," .. lis[2])
            end
        end
    end

    if actorInfo.gemstones and #actorInfo.gemstones > 0 then
        local skill_str = db:getGemstoneGodSkillByGemstones(actorInfo.gemstones)
        if skill_str then
            table.mergeForArray(actorInfo.skillIds,string.split(skill_str, ";"))
        end

      -- 魂骨融合技能
        if actorInfo.gemstones ~= nil then
            local skillIds = db:getGemstoneMixSuitSkillByGemstones(actorInfo.gemstones)
            for i,id in ipairs(skillIds) do
                table.insert(actorInfo.skillIds, tostring(id) .. "," .. tostring(1))
            end
        end

    end

    table.insert(actorInfo.skillIds, 300001) -- beattacked_reduce_cd
    QHeroModel.super.ctor(self, actorInfo, events, callbacks, extraProp)

    -- 羁绊技能伤害增幅
    self:setAdditionalManualSkillDamagePercent(superSkillInfo.multiple or 0)
    
    self._exp = heroInfo.exp

    self._actorId = heroInfo.actorId
    self._isHero = true

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

-- function QHeroModel:getExp()
--     return self._exp
-- end

function QHeroModel:hit(...)
    -- 调用父类的 hit() 方法
    return QHeroModel.super.hit(self, ...)
    -- if damage > 0 then
    --     -- 每次攻击成功，增加 10 点 EXP
    --     self:increaseEXP(10)
    -- end
end

function QHeroModel:getTalent()
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

function QHeroModel:hasRage()
    return true
end

function QHeroModel:isSupportHero()
    return self._isSupportHero
end

function QHeroModel:setIsSupportHero(isSupportHero)
    self._isSupportHero = isSupportHero
end

function QHeroModel:isOpenArtifact()
    return self._artifact ~= nil
end

function QHeroModel:getAppearSkillId()
    return self._appearSkillId
end

return QHeroModel
