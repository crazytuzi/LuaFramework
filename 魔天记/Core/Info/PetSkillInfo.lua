require "Core.Info.SkillInfo";

PetSkillInfo = class("PetSkillInfo", SkillInfo);

function PetSkillInfo:New(id, level)
	local skLevel = level or 1;
	self = {};
	setmetatable(self, {__index = PetSkillInfo});
	self._timer = nil;
	self._isCooling = false;
	self._currCoolTime = 0;
	self:_Init(id, level);
	-- if(self.exp_cost ~= "") then
	-- 	local temp = ConfigSplit(self.exp_cost)
	-- 	self._updateNeedSkillItem = ProductManager.GetProductById(tonumber(temp[1]))
	-- 	self._updateNeedItemCount = tonumber(temp[2])
	-- end
	--
	-- local temp
  	self._passSkillAttr = {}
	if(self.stages[1].script == "add_attr") then
		for k, v in ipairs(self.stages[1].para) do
			temp = self:ConfigSplit(v)
			self._passSkillAttr[temp[1]] = tonumber(temp[2])
		end
	end
	
	-- local petSkillConfig = PetManager.GetPetSkillConfigById(id)
	-- if(petSkillConfig) then
	-- 	self._activeItem = {}
	-- 	local temp = ConfigSplit(self.exp_cost)
	-- 	self._activeItem.id = tonumber(temp[1])
	-- 	self._activeItem.count = tonumber(temp[2])	
	-- end
	-- self.exp = exp
	-- self.sId = sId or id
	--以服务器的id作为标识,有服务器id为已经获得了
	-- if(sId) then
	-- 	self._isActive = true
	-- end
	-- if((petId == nil) or(petId == "")) then
	-- 	self.petId = "-1"
	-- else
	-- 	self.petId = petId
	-- end
	
	return self;
end

function PetSkillInfo:GetPassSkillAttr()
	return self._passSkillAttr
end

-- function PetSkillInfo:CanActive()
-- 	if(self:GetIsActive()) then return false end
-- 	if(self._activeItem) then      
-- 		return BackpackDataManager.GetProductTotalNumBySpid(self._activeItem.id) >= self._activeItem.count
-- 	end
-- 	return false
-- end

function PetSkillInfo:ConfigSplit(str)
	if(str and str ~= "") then
		return string.split(str, "|")
	end
	
	return nil
end

-- -- 设置主动或者被动 0被动，1主动
-- function PetSkillInfo:SetType(skilType)
-- 	self.skillType = skilType
-- end

-- --idx:-1 代表没有 0代表天生技能
-- function PetSkillInfo:SetIndex(index)
-- 	self.skillIndex = index
-- end

-- function PetSkillInfo:GetServerId()
-- 	return self.sId
-- end

-- function PetSkillInfo:GetIsActive()
-- 	return self._isActive or false
-- end 