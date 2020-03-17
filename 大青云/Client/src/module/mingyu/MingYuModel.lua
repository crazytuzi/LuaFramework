--[[
玉佩：model
2015年1月28日10:40:38
haohu
]]

MingYuModel = Module:new();

-- 玉佩等阶
MingYuModel.level = 0; -- 0 ~ 10, 0为未开启
-- 当前使用玉佩模型的等阶
MingYuModel.modelLevel = 0;
-- 玉佩熟练度
MingYuModel.proficiency = 0;
-- 熟练度等级
MingYuModel.lvlProficiency = 0; -- 0 ~ 5, 
-- 进阶祝福值
MingYuModel.blessing = 0;
-- 进阶时自动购买
MingYuModel.autoBuy = false;
--属性丹喂养数量
MingYuModel.pillNum = 0;

-- <attribute type="int" name="level" comment="玉佩等阶"/>
-- <attribute type="int" name="modelLevel" comment="玉佩使用模型的等阶(≤玉佩等阶)"/>
-- <attribute type="int" name="proficiency" comment="玉佩熟练度"/>
-- <attribute type="int" name="lvlProficiency" comment="熟练度等级"/>
-- <attribute type="int" name="blessing" comment="进阶祝福值"/>
function MingYuModel:SetInfo(info)
	self:SetModelLevel( info.modelLevel )
	self:SetLvlProficiency( info.lvlProficiency )
	self:SetProficiency( info.proficiency )
	self:SetLevel( info.level )
	self:SetBlessing( info.blessing )
	self:SetPillNum(info.pillNum)
	ZiZhiModel:SetZZNum(2, info.zizhiNum)
end

--------------------------- 等阶 -------------------------------

function MingYuModel:GetLevel()
	return self.level;
end

function MingYuModel:SetLevel(level)
	local oldLevel = self.level
	if level == oldLevel then return end
	local levelUp = level - oldLevel
	self.level = level
	if oldLevel ~= 0 then -- == 0 的情况：1)刚登陆 2)刚开启
		self:sendNotification( NotifyConsts.MingYuLevelUp, levelUp )
		self:OnLevelUp()
	end
end

--------------------------- 模型等阶 -------------------------------

function MingYuModel:SetModelLevel(modelLevel)
	if modelLevel == self.modelLevel then return end
	self.modelLevel = modelLevel
	self:sendNotification( NotifyConsts.MingYuModelChange )
	local mainPlayer = MainPlayerController:GetPlayer();
	if mainPlayer then
		mainPlayer:SetMingYu( self.modelLevel )
	end
end

function MingYuModel:GetModelLevel()
	return self.modelLevel
end

--------------------------- 熟练度 -------------------------------

function MingYuModel:GetProficiency()
	return self.proficiency;
end

function MingYuModel:SetProficiency( proficiency )
	local lvlPrfcncy = self.lvlProficiency
	if lvlPrfcncy == MingYuConsts.MaxLvlProficiency then
		self.proficiency = MingYuUtils:GetProficiencyCeiling( self.level, lvlPrfcncy )
	else
		self.proficiency = proficiency
	end
	self:sendNotification( NotifyConsts.MingYuProficiency )
end

--------------------------- 熟练度等阶 -------------------------------

function MingYuModel:GetLvlProficiency()
	return self.lvlProficiency
end

function MingYuModel:SetLvlProficiency(lvlProficiency)
	if self.lvlProficiency == lvlProficiency then return end
	self.lvlProficiency = lvlProficiency
	if self.lvlProficiency == MingYuConsts.MaxLvlProficiency then
		self:SetProficiency()
	end
	local lvlProficiencyUp = lvlProficiency - self.lvlProficiency
	self:sendNotification( NotifyConsts.MingYuPrfcncyLevelUp, lvlProficiencyUp )
	if self.lvlProficiency == MingYuConsts.MaxLvlProficiency then
		self:OnLvlProficiencyJustFull()
	end
end

--------------------------- 祝福值 -------------------------------

function MingYuModel:GetBlessing()
	return self.blessing
end

function MingYuModel:SetBlessing( blessing )
	if self.blessing == blessing then return end
	self.blessing = blessing
	self:sendNotification( NotifyConsts.MingYuBlessing )
end

----------------------------------------- 熟练度等级刚刚满时，提醒升阶引导 -------------------------------

function MingYuModel:OnLvlProficiencyJustFull()
	if self.level < MingYuConsts:GetMaxLevel() then
		UIItemGuide:Open(7);
	end
end

----------------------------------------- 属性丹 -------------------------------
function MingYuModel:SetPillNum(num)
	self.pillNum = num;
	self:sendNotification(NotifyConsts.MingYuSXDChanged);
end

function MingYuModel:GetPillNum()
	return self.pillNum;
end

local timerKey
function MingYuModel:OnLevelUp()
	-- if timerKey then
	-- 	TimerManager:UnRegisterTimer( timerKey )
	-- 	timerKey = nil
	-- end
	-- timerKey = TimerManager:RegisterTimer( function()
		MainMingYuUI:Hide()
		UIMingYuShow:Show()
	-- 	timerKey = nil
	-- end, 1000, 1 )
end