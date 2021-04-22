--
-- zxs
-- 暗器属性类
--

local QActorProp = import(".QActorProp")
local QMountProp = class("QMountProp", QActorProp)

function QMountProp:ctor(options)
	QMountProp.super.ctor(self)

	self:initProp()
	self:setInfo(options)
end

function QMountProp:initProp()
	self._totalProp = {}
	self._actorProp = {}
	self._levelProp = {}
    self._gradeProp = {}
	self._masterProp = {}
	
    self._skillForce = 0
end

function QMountProp:setInfo(mountInfo)
	if self._mountInfo == nil then
		self._oldMountInfo = {}
	else
		self._oldMountInfo = self._mountInfo
	end
	self._mountInfo = mountInfo
    self._forceConfig = db:getForceConfigByLevel(self:getLevel())
    self._coConfig = db:getLevelCoefficientByLevel(tostring(self:getLevel()))


    --获取暗器自身的属性
    local needCount = false
	if self._mountInfo.zuoqiId ~= self._oldMountInfo.zuoqiId then
		needCount = true
		self._characterConfig = db:getCharacterByID(self:getMountId())
    	self:_countActorProperties(self._mountInfo.zuoqiId) 
    end

    --获取暗器的升级属性
	if needCount or self._mountInfo.enhanceLevel ~= self._oldMountInfo.enhanceLevel then
    	self:_countLevelProperties(self._mountInfo.enhanceLevel or 0) 
    end

    --获取暗器的升星属性
	if needCount or self._mountInfo.grade ~= self._oldMountInfo.grade then
    	self:_countGradeProperties(self._mountInfo.grade or 0) 
    end

    --计算暗器技能属性
    if needCount or self._mountInfo.slots ~= self._oldMountInfo.slots then
        self:_countSkillProperties(self._mountInfo.slots or {}) 
    end

    --计算所有的属性集合
    self:_countAllProp()
end

--计算自身属性
function QMountProp:_countActorProperties(zuoqiId)
	self._actorProp = {}
    local properties = db:getCharacterByID(zuoqiId)
    properties = db:getCharacterData(properties.id, properties.data_type)
    self:_analysisProp(self._actorProp, properties)
end

--计算的升级属性
function QMountProp:_countLevelProperties(level)
    self._levelProp = {}
	self._masterProp = {}
	local properties = db:getMountStrengthenBylevel(self._characterConfig.aptitude, level)
    self:_analysisProp(self._levelProp, properties)

    local masterProps, masterLevel = db:getMountMasterInfo(self._characterConfig.aptitude, level)
    for _, masterProp in ipairs(masterProps) do
        QActorProp:getPropByConfig(masterProp, self._masterProp)
    end
end

--计算升星的属性
function QMountProp:_countGradeProperties(gradeLevel)
	self._gradeProp = {}
    local gradeConfig = db:getGradeByHeroActorLevel(self._mountInfo.zuoqiId, gradeLevel)
    self:_analysisProp(self._gradeProp, gradeConfig)
end

--计算技能属性
function QMountProp:_countSkillProperties(slots)
    self._skillForce = 0
    local skillIds = {}
    for _, slotInfo in ipairs(slots) do
        local level = slotInfo.slotLevel
        local skills = db:getSkillsByActorAndSlot(self._mountInfo.zuoqiId, slotInfo.slotId)
        for i, skillId in ipairs(skills) do
            skillIds[skillId] = level
        end
    end

    for id, level in pairs(skillIds) do
        local skillData = db:getSkillDataByIdAndLevel(id, level)
        self._skillForce = self._skillForce + (skillData.battle_force or 0)
    end
end

--计算所有属性
function QMountProp:_countAllProp()
	self._totalProp = {}
    self:_analysisProp(self._totalProp, self._actorProp, "character")
    self:_analysisProp(self._totalProp, self._levelProp, "level")
    self:_analysisProp(self._totalProp, self._gradeProp, "grade") 

	for name,filed in pairs(self._field) do
		if filed.isFinal == true then
    		self:_countSingleProp(self._totalProp, name)
		end
	end
end

--[[
    获取战斗力
]]
function QMountProp:getBattleForce(islocal)
    if islocal == true then
        return self:getLocalBattleForce()
    end
    local force = 0
    if self._mountInfo.force ~= nil then
        force = self._mountInfo.force
    end
    return force
end

function QMountProp:getLevel()
	return self._mountInfo.enhanceLevel
end

function QMountProp:getActorId()
	return self._mountInfo.zuoqiId
end

function QMountProp:getMountId()
    return self._mountInfo.zuoqiId
end

function QMountProp:getTotalProp()       
	return self._totalProp or {}
end

function QMountProp:getTotalAndMasterProp()
    local totalProp = {}
    self:_analysisProp(totalProp, self._totalProp, "totalProp") 
    self:_analysisProp(totalProp, self._masterProp, "master")
    return totalProp or {}
end

return QMountProp