require "Core.Info.BaseAttrInfo";
require "Core.Info.SkillInfo";
require "Core.Info.BaseAdvanceAttrInfo";
NewTrumpInfo = class("NewTrumpInfo");
NewTrumpInfo.State =
{
	NotActive = 0,
	CanActive = 1,
	HadActive = 2,
	HadDress = 3,
}

function NewTrumpInfo:New(data)
	self = {};
	setmetatable(self, {__index = NewTrumpInfo});
	self:_Init(data);
	return self;
end

function NewTrumpInfo:Init(data)
	self:_Init(data)
end


function NewTrumpInfo:_Init(data)
	self.id = data
	self.state = 0
	self.refineLev = {}
	self.configData = NewTrumpManager.GetTrumpConfigById(self.id)
	for i = 1, NewTrumpManager.MaxRefineLevel do
		self.refineLev[i] = {}
		local configData = NewTrumpManager.GetNewTrumpRefineConfigByIdAndLev(self.id, i)
		self.refineLev[i].curAttr = BaseAttrInfo:New()
		self.refineLev[i].maxAttr = BaseAttrInfo:New()
		self:SetMinAttr(self.refineLev[i].curAttr, configData)
		self:SetMaxAttr(self.refineLev[i].maxAttr, configData)
		self.refineLev[i].state = 0
		self.refineLev[i].name = configData.name
		self.refineLev[i].level = configData.refine_lev
		self.refineLev[i].condition = {}
		self.refineLev[i].reqMoney = configData.money
		self.refineLev[i].req_lev = configData.req_lev
		self.refineLev[i].gold = configData.gold
		for k, v in ipairs(configData.refine_req) do
			self.refineLev[i].condition[k] = {}
			local item = ConfigSplit(v)
			self.refineLev[i].condition[k].itemId = tonumber(item[1])
			self.refineLev[i].condition[k].itemCount = tonumber(item[2])
		end
		
	end
	self.attr = BaseAttrInfo:New()
	self.attr:Init(self.configData)
	self.activeSkill = SkillInfo:New(self.configData.act_skill, self.configData.act_skill_lev)
--	self.passSkill = SkillInfo:New(self.configData.pass_skill, self.configData.pass_skill_lev)
	
	--    if (data.rlv) then
	--        for k, v in ipairs(data.rlv) do
	--            self:SetRefineData(v)
	--            self:SetRefineState(v.lv, 1)
	--        end
	--    end
end

function NewTrumpInfo:SetMinAttr(attr, configData)
	local property = attr:GetProperty()
	for k, v in ipairs(property) do
		if(configData[v]) then
			attr[v] = configData[v] [1]
		end
	end
end

function NewTrumpInfo:SetMaxAttr(attr, configData)
	local property = attr:GetProperty()
	for k, v in ipairs(property) do
		if(configData[v]) then
			attr[v] = configData[v] [2]
		end
	end
end

function NewTrumpInfo:GetAllAttr()
	local attr = ConfigManager.Clone(self.attr)
	for k, v in ipairs(self.refineLev) do
		if(v.state == 0) then
			break
		elseif v.state == 1 then
			attr:Add(v.curAttr)
		end
		
	end
	return attr
end


function NewTrumpInfo:SetTrumpState(state)
	if(state) then
		self.state = state
	end
end

function NewTrumpInfo:SetAllRefineData(data)
	if(data) then
		for k, v in ipairs(data) do
			self:SetRefineData(v)
			self:SetRefineState(v.lv, 1)
		end
	end
end

function NewTrumpInfo:GetAllRefineData()
	return self.refineLev
end

function NewTrumpInfo:GetRefineDataByLevel(lev)
	return self.refineLev[lev]
end


function NewTrumpInfo:SetRefineData(data)
	self.refineLev[data.lv].curAttr:Init(data)
end

function NewTrumpInfo:SetRefineState(lv, state)
	self.refineLev[lv].state = state
end

function NewTrumpInfo:GetTrumpSkillInfo()
	return self.activeSkill
end

-- 获取上个等级是否激活
function NewTrumpInfo:GetLastLevelIsActive(level)
	if(level == 1) then
		return true
	end
	
	return(self.refineLev[level - 1].state == 1)
end

function NewTrumpInfo:IsTrumpHadRefine()
	if(self.refineLev) then
		for k, v in ipairs(self.refineLev) do
			if(v.state == 1) then
				return true
			end
		end
	end
	return false
end

function NewTrumpInfo:CanTrumpRefine()
	if(self.state < NewTrumpInfo.State.HadActive) then
		return false
	end
	
	local hero = HeroController.GetInstance()
	local money = MoneyDataManager.Get_money()	
	
	for k, v in ipairs(self.refineLev) do
		if(v.state == 0) then		
			if((money >= v.reqMoney) and
			(BackpackDataManager.GetProductTotalNumBySpid(v.condition[1].itemId) >= v.condition[1].itemCount)
			and hero.info.level >= v.req_lev) then
				return true
			else
				return false
			end
		end
	end
	return false
end

function NewTrumpInfo:GetCurRefineName()
	local refineData = nil
	for k, v in ipairs(self.refineLev) do
		if(v.state == 0) then
			break
		end
		refineData = v
	end
	
	if(refineData) then
		return refineData.name
	end
	
	return ""
	
end


function NewTrumpInfo:GetCurRefineName()
	local refineData = nil
	for k, v in ipairs(self.refineLev) do
		if(v.state == 0) then
			break
		end
		refineData = v
	end
	
	if(refineData) then
		return refineData.name
	end
	
	return ""
end

function NewTrumpInfo:GetCurRefineLev()
	local name = self:GetCurRefineName()
	if(name == "") then
		return ""
	end
	
	return string.sub(name, 7)
end

--获取自身属性
function NewTrumpInfo:GetSelfAttr()
	return self.attr
end 