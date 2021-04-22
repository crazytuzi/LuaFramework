
--[[--

“NPC”类

从“角色”类继承，增加了经验值等属性

]]

local QActor = import(".QActor")
local QNpcModel = class("QNpcModel", QActor)

local QFileCache = import("..utils.QFileCache")

function QNpcModel:ctor(id, difficulty, level, events, callbacks, additional_skills, dead_skill, isBattle, isInStory, skinId)
    local properties = db:getCharacterByID(id)
    -- if properties == nil then
    --     echoError("NPC with id: %s not found!", tostring(id))
    -- end

    if app.battle and app.battle:isInEditor() then
        if level == -1 then
            level = 1
        end
    end

    -- TOFIX: SHRINK
    properties = q.cloneShrinkedObject(properties)

    local data_properties = self:_getCharacterData(properties.id, properties.data_type, difficulty, level)
    -- TOFIX: SHRINK
    data_properties = q.cloneShrinkedObject(data_properties)
    data_properties.id, data_properties.data_type, data_properties.npc_difficulty, data_properties.npc_level = nil, nil, nil, nil
    table.merge(properties, data_properties)

    properties.actor_id = id
    local uuid = (isInStory and story_uuid()) or ((isBattle or IsServerSide) and replay_uuid() or uuid())
    properties.id = id .. "_" .. uuid
    properties.udid = properties.id
    properties.uuid = uuid

    local actorInfo = {
        properties = properties,
        actorId = id,
        data_difficulty = difficulty,
        data_level = level,
        level = level,
        grade = properties.grade,
        skinId = skinId,                                        
    }
	self._type = ACTOR_TYPES.NPC
	local skillIds = {}
    if properties.innate_skill ~= nil then
        if db:getSkillByID(properties.innate_skill) ~= nil then table.insert(skillIds, properties.innate_skill) end
    end
    if properties.npc_skill ~= nil then
        if db:getSkillByID(properties.npc_skill) ~= nil then table.insert(skillIds, properties.npc_skill) end
    end
    if properties.npc_skill2 ~= nil then
        if db:getSkillByID(properties.npc_skill2) ~= nil then table.insert(skillIds, properties.npc_skill2)  end
    end
    if properties.npc_skill_list ~= nil then
        local skill_ids = string.split(tostring(properties.npc_skill_list), ";")
        for _, skill_id in ipairs(skill_ids) do
            table.insert(skillIds, skill_id)
        end
    end
    local skillIdsForAi = self:getSkillIdWithAiType(properties.npc_ai)
    for _, skillId in ipairs(skillIdsForAi) do
        table.insert(skillIds, skillId)
    end
    if additional_skills then
        for _, skillId in pairs(additional_skills) do
            table.insert(skillIds, skillId)
        end
    end
    self._deadSkill = dead_skill

    actorInfo.skillIds = skillIds
    
    QNpcModel.super.ctor(self, actorInfo, events, callbacks, {})

    -- @override 小怪的突破等级从character表中获取
    self._breakthrough_value = data_properties.breakthrough
end

function QNpcModel:hit(...)
    -- 调用父类的 hit() 方法
    return QNpcModel.super.hit(self, ...)
end

function QNpcModel:hasRage()
    return false
end

return QNpcModel
