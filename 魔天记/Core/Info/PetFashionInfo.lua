require "Core.Info.PetSkillInfo";
require "Core.Info.BaseAdvanceAttrInfo";

local PetFashionInfo = class("PetFashionInfo");
local _insert = table.insert
local MaxFashionLev = PetManager.MAXFASHIONLEVEL -- 最高幻形等级
--==============================--
--desc:宠物形象数据
--time:2017-08-03 09:20:10
--@data:宠物初始化形象数据 
--id：幻形ID lev:幻形等级
--@return 
--==============================--  
function PetFashionInfo:New(data)
	self = {};
	setmetatable(self, {__index = PetFashionInfo});
	self:_Init(data);
	return self;
end

function PetFashionInfo:_Init(data)	
	self._id = data.id	
	self._starLev = 0 -- 使用该外形宠物的星级
	self._attr = BaseAdvanceAttrInfo:New()	
	self._passiveAttr = BaseAdvanceAttrInfo:New()	
	self._active = false
	self._isUpdateAllSkill = true
	self:_InitSelfData()
	self:UpdateLevel(data.lev)	
end

function PetFashionInfo:_InitSelfData()
	
	local config = PetManager.GetPetConfig(self._id)
	self._name = config.name
	self._order = config.order
	self._icon = config.icon
	self._quality = config.quality
	self._active_level = config.active_level
	self._scale = config.scale
	self._effectType = config.effect_type
	self.model_effect = config.model_effect
	if(config.active_require ~= "") then
		local item = ConfigSplit(config.active_require)
		self._activeNeedId = tonumber(item[1])
		self._activeNeedCount = tonumber(item[2])		
	end
	self.model_id = config.model_id
	--'206101_1_1_1'伙伴技能格式  技能id_技能等级_所需星数
	self:_InitPetBaseSkill(config.skill_id) -- 初始化普攻
	self:_InitPetSkills(config.skillgroup_unlock) --初始化剩余技能
end

function PetFashionInfo:GetOrder()
	return self._order
end

function PetFashionInfo:GetScale()
	return self._scale
end

--获取激活的等级
function PetFashionInfo:GetActiveLevel()
	return self._active_level
end

function PetFashionInfo:GetModelEffect()
	return self.model_effect
end

function PetFashionInfo:GetIcon()
	return self._icon
end

function PetFashionInfo:_InitPetBaseSkill(skillId)
	self:AddSkill(skillId, 1)
end

function PetFashionInfo:GetName()
	return self._name
end

function PetFashionInfo:GetId()
	return self._id
end

function PetFashionInfo:GetQuality()
	return self._quality
end

function PetFashionInfo:GetModelId()
	return self.model_id
end

function PetFashionInfo:_InitPetSkills(skillGroup)
	if(skillGroup) then
		self._addSkill = {}
		for k, v in ipairs(skillGroup) do
			local temp = ConfigSplit(v)
			local skill = {}
			skill.info = PetSkillInfo:New(tonumber(temp[1]), tonumber(temp[2]))
			skill.unlockStartLev = tonumber(temp[3]) --解锁的总等级			 
			_insert(self._addSkill, skill)			
		end	
	end
end

--更新幻化等级
function PetFashionInfo:UpdateLevel(lev)
	self._fashionLev = lev or 1
	self._power = 0
	local config = PetManager.GetPetTransformConfig(self._id, self._fashionLev)
	if(config) then
		self._attr:Init(config)
		self._power = CalculatePower(self._attr)
		local temp = ConfigSplit(config.transform_cost)
		self._fashionNeedItemId = tonumber(temp[1])
		self._fashionNeedItemCount = tonumber(temp[2])	
		self._levelName = config.transform_name
	end
end

function PetFashionInfo:GetLevelName()
	return self._levelName
end

function PetFashionInfo:GetAttr()
	return self._attr
end

function PetFashionInfo:GetId()
	return self._id
end

function PetFashionInfo:GetFashionLev()
	return self._fashionLev
end

function PetFashionInfo:AddSkill(id, level)
	if(id > 0) then
		local sLevel = level or 1;
		local sk = PetSkillInfo:New(id, sLevel);
		if(sk.skill_type == 1) then
			if(self.baseSkills == nil) then
				self.baseSkills = {};
			end
			self.baseSkills[self:_GetSkillDefaultIndex(self.skill_id, id)] = sk;
		else
			if(self._addSkill == nil) then
				self._addSkill = {};
			end
			_insert(self._addSkill, {info = sk})
		end
	end
end

function PetFashionInfo:_GetSkillDefaultIndex(list, id)
	local index = 1;
	if(type(list) == "table") then
		for i, v in pairs(list) do
			if(v == id) then
				return index;
			end
			index = index + 1;
		end
	end
	return index;
end

function PetFashionInfo:GetBaseSkill()
	local sk = self.baseSkills;
	if(sk) then
		return sk[1];
	end
	return nil;
end

function PetFashionInfo:GetSkillByIndex(index)
	if(self._addSkill) then
		if(self._addSkill[index] and(self._starLev >= self._addSkill[index].unlockStartLev) and(self._addSkill[index].info.skill_type ~= 3)) then
			return self._addSkill[index].info;
		end
	end
	return nil;
end

function PetFashionInfo:GetSkill(id)	
	if(self.baseSkills) then
		for k, v in pairs(self.baseSkills) do
			if(v and v.id == id) then
				return v
			end
		end
	end
	if(self._addSkill) then
		for k, v in ipairs(self._addSkill) do
			if(v.info and v.info.id == id and self._starLev >= v.unlockStartLev) then
				return v.info
			end
		end
	end
	return nil;
end

function PetFashionInfo:GetAllAddSkills()
	if(self._isUpdateAllSkill) then
		
		self:_ResetSkillActive()
		-- for k, v in ipairs(self._addSkill) do			 		
		-- 	v.active =(self._starLev >= v.unlockStartLev) and self._active
		-- end
		self._isUpdateAllSkill = false
	end
	return self._addSkill
end

function PetFashionInfo:_ResetSkillActive()
	if(self._addSkill) then
		for k, v in ipairs(self._addSkill) do
			v.active =(self._starLev >= v.unlockStartLev) and self._active
	 
		end
	end
end

--设置使用改外形的宠物的等级 以便计算出哪些技能能用
-- 返回是否需要更新
function PetFashionInfo:SetRankLevel(starLev)	
	starLev = starLev or 0
	if(self._starLev ~= starLev) then	
		self._isUpdateAllSkill = true
	end
	self._starLev = starLev
	
	return self._isUpdateAllSkill
end

function PetFashionInfo:GetCanActive()
	if(self._active) then return false end
	return BackpackDataManager.GetProductTotalNumBySpid(self._activeNeedId) >= self._activeNeedCount
end

--幻化是否满级
function PetFashionInfo:GetIsMax()
	return self._fashionLev >= MaxFashionLev
end

--给排序使用
function PetFashionInfo:SetCurNeedItemCount(count1, count2)
	self._curActiveNeedItemCount = count1
	self._curFashionNeedItemCount = count2
end

--给排序使用
function PetFashionInfo:GetCurActiveNeedItemCount()
	return self._curActiveNeedItemCount or 0
end

function PetFashionInfo:GetCurFashionNeedItemCount()
	return self._curFashionNeedItemCount or 0
end

--给排序使用
function PetFashionInfo:GetCanActiveBySort()
	if(self._active) then return false end
	return self:GetCurActiveNeedItemCount() >= self._activeNeedCount
end

--排序使用判断条件
function PetFashionInfo:GetCanFashionUpdateBySort()
	if(self._fashionLev == MaxFashionLev or(self._active == false)) then return false end
	return self:GetCurFashionNeedItemCount() >= self._fashionNeedItemCount
end

function PetFashionInfo:GetCanUpdate()
	if(not self._active) then return false end
	if(self:GetFashionLev() == 4) then return false end
	return BackpackDataManager.GetProductTotalNumBySpid(self._fashionNeedItemId) >= self._fashionNeedItemCount
end

--获取是否已经激活
function PetFashionInfo:GetIsActive()
	return self._active
end

--设置激活状态
function PetFashionInfo:SetActive(v)	 
	self._active = v
	self._isUpdateAllSkill = true
end

function PetFashionInfo:GetActiveNeedItem()
	return ProductManager.GetProductById(self._activeNeedId)
end

function PetFashionInfo:GetActiveNeedItemId()
	return self._activeNeedId
end

function PetFashionInfo:GetActiveNeedItemCount()
	return self._activeNeedCount
end

function PetFashionInfo:GetFashionNeedItem()
	return ProductManager.GetProductById(self._fashionNeedItemId)
end

function PetFashionInfo:GetFashionNeedItemId()
	return self._fashionNeedItemId
end

function PetFashionInfo:GetFashionNeedItemCount()
	return self._fashionNeedItemCount
end

function PetFashionInfo:GetPower()
	return self._power
end

function PetFashionInfo:GetPassiveAttr()
	self._passiveAttr:Reset()
	self:_ResetSkillActive()
	
	if(self._addSkill) then	
		for k, v in ipairs(self._addSkill) do		
			if(v.active) then
				self._passiveAttr:Add(v.info:GetPassSkillAttr())
			end
		end
	end
	
	return self._passiveAttr
end	

function PetFashionInfo:GetEffectConfig()
	if(self._effectConfig == nil) then
		self._effectConfig = PetManager.GetEffectConfigById(self._effectType)
	end
	
	return self._effectConfig
end

return PetFashionInfo 