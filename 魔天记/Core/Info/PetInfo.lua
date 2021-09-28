require "Core.Info.PetSkillInfo";
require "Core.Info.BaseAdvanceAttrInfo";
local PetFashionInfo = require "Core.Info.PetFashionInfo";


PetInfo = class("PetInfo");

local correctAtt = 0.178
local correctHit = 0.187
local correctCrit = 0.187
local correctFatal = 0.191
local insert = table.insert
local maxRank = PetManager.MAXRANK
function PetInfo:New(data, isOther)
	self = {};
	setmetatable(self, {__index = PetInfo});
	isOther = isOther and isOther or false
	if(isOther) then
		self:_InitOther(data);
	else
		self:_Init(data);
	end
	
	return self;
end

function PetInfo:_InitOther(data)
	self.id = data.id
	
	self:UpdatePetFasionInfo(data.use_id)
	
	if(self._fashionInfo) then		
		self._fashionInfo:SetRankLevel(data.s)
	end
end

function PetInfo:_Init(data)
	self._attr = BaseAdvanceAttrInfo:New()
	self._advanceAttr = BaseAdvanceAttrInfo:New()
	
	self:UpdatePetFasionInfo(data.use_id)
	self:UpdateLevel(data.lev, data.exp)
	self:UpdateRank(data.star, data.adv_exp)
end

function PetInfo:GetPetLevelUpAttr()
	return self._attr
end

function PetInfo:UpdatePetFasionInfo(id)
	if(self._useId ~= id) then
		self._useId = id
		
		self._fashionInfo = PetFashionInfo:New({id = self._useId})
		self._fashionInfo:SetActive(true)
		if(self._rank) then
			self._fashionInfo:SetRankLevel(self._rank)
		end
		self.name = self._fashionInfo:GetName()
		self.model_id = self._fashionInfo:GetModelId()
		self.quality = self._fashionInfo:GetQuality()
        self.model_effect = self._fashionInfo:GetModelEffect()
	end
end

function PetInfo:UpdateLevel(lev, exp)
	--log(exp)
	self._exp = exp or 0
	self._lev = lev or 1
	self._power = 0
	
	local config = PetManager.GetPetUpdateConfig(self._lev)
	
	if(config) then
		self._attr:Init(config)
		self._levelPower = CalculatePower(self._attr)
		self._maxExp = config.levelup_cost	
	end
	--log(self._maxExp)
	
end

function PetInfo:GetMaxExp()
	return self._maxExp
end

function PetInfo:GetExp()
	if(self._lev == PetManager.MAXPETLEVEL) then
		return self._maxExp
	end
	return self._exp
end

function PetInfo:GetLevelPower()
	return self._levelPower
end

function PetInfo:GetLevel()
	return self._lev
end

function PetInfo:GetRankAttr()
	return self._advanceAttr
end

function PetInfo:GetRankPower()
	return self._rankPower
end

function PetInfo:UpdateRank(rank, exp)
	self._advExp = exp or 0
	self._rank = rank or 1
	local config = PetManager.GetPetAdvanceConfig(self._rank)
	if(config) then
		self._partner_id = config.partner_id --可激活的伙伴id
		self._advanceAttr:Init(config)
		self._rankPower = CalculatePower(self._advanceAttr)
		self._rankLevel = config.stage
		local temp = ConfigSplit(config.need_item)
		if(temp) then
			self._advanceNeedItemId = tonumber(temp[1])
			self._advanceNeedItemCount = tonumber(temp[2])
		end
		self._advMaxExp = config.advance_cost		
	end
	
	if(self._fashionInfo) then		
		self._fashionInfo:SetRankLevel(self._rank)
	end
end

--返回当前等阶的可激活伙伴
function PetInfo:GetCurRankFashionId()
	return self._partner_id
end

function PetInfo:GetAdvanceNeedItemId()
	return self._advanceNeedItemId
end

function PetInfo:GetAdvanceNeedItemCount()
	return self._advanceNeedItemCount
end

function PetInfo:GetAdvanceNeedItem()
	return ProductManager.GetProductById(self._advanceNeedItemId)
end

function PetInfo:CoolSkill(skill, blDelayCool)
	if(skill) then
		local cd_rdc = self.cd_rdc or 0;
		local r =(100 - cd_rdc) / 100;
		if(blDelayCool) then
			skill:ResetDelayCooling(r)
		else
			skill:StartCool(r);
		end
	end
end

function PetInfo:GetPower()	
	return self:GetLevelPower()
end

function PetInfo:GetRank()
	return self._rank
end

function PetInfo:GetShowStar()
	if(self._rank == maxRank) then
		return 10
	else
		return self._rank % 10
	end
end

function PetInfo:GetRankLevel()
	return self._rankLevel
end

function PetInfo:GetRankMaxExp()
	return self._advMaxExp
end

function PetInfo:GetRankExp()
	if(self._rank == maxRank) then
		return self._advMaxExp		
	end
	return self._advExp
end

function PetInfo:AddSkill(id, level)
	if(id > 0) then
		if(self._fashionInfo) then
			self._fashionInfo:AddSkill(id, level)
		end		
	end
end

function PetInfo:_GetSkillDefaultIndex(list, id)
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

function PetInfo:GetBaseSkill()
	if(self._fashionInfo) then
		return self._fashionInfo:GetBaseSkill()
	end
	return nil;
end

function PetInfo:GetSkillByIndex(index)
	if(self._fashionInfo) then
		return self._fashionInfo:GetSkillByIndex(index)
	end
	return nil;
end

function PetInfo:GetSkill(id)	
	if(self._fashionInfo) then
		return self._fashionInfo:GetSkill(id)
	end
	return nil;
end

function PetInfo:GetPetFashionInfo()
	return self._fashionInfo
end

function PetInfo:Dispose()
	
end

-- 是否能使用经验道具
function PetInfo:GetCanUseExpItem()
	
	if((self._lev >= PlayerManager.GetPlayerInfo().level) or(self._lev >= PetManager.MAXPETLEVEL)) then
		return false
	end
	return PetManager.CanUpdatePet()
end


-- 是否能进阶
function PetInfo:GetCanAdvance()
	if(self.rank == PetManager.MAXRANK) then
		return false
	end
	return self:GetCanUpdateStar()
end

function PetInfo:GetCanUpdateStar()
	return BackpackDataManager.GetProductTotalNumBySpid(self._advanceNeedItemId) >= self._advanceNeedItemCount
end

function PetInfo:GetCurUsePetId()
	return self._useId
end

function PetInfo:GetPassiveAttr()
	if(self._fashionInfo) then
		return self._fashionInfo:GetPassiveAttr()
	end
	return nil
end

function PetInfo:GetIsMaxLevel()
	return(self._lev == PetManager.MAXPETLEVEL)	or(self._lev >= PlayerManager.GetPlayerInfo().level)
end

