--[[
法宝：model
2015年1月28日10:40:38
haohu
]]

LingQiModel = Module:new();

-- 法宝等阶
LingQiModel.level = 0; -- 0 ~ 10, 0为未开启
-- 当前使用法宝模型的等阶
LingQiModel.modelLevel = 0;
-- 法宝熟练度
LingQiModel.proficiency = 0;
-- 熟练度等级
LingQiModel.lvlProficiency = 0; -- 0 ~ 5, 
-- 进阶祝福值
LingQiModel.blessing = 0;
-- 进阶时自动购买
LingQiModel.autoBuy = false;
--属性丹喂养数量
LingQiModel.pillNum = 0;

-- <attribute type="int" name="level" comment="法宝等阶"/>
-- <attribute type="int" name="modelLevel" comment="法宝使用模型的等阶(≤法宝等阶)"/>
-- <attribute type="int" name="proficiency" comment="法宝熟练度"/>
-- <attribute type="int" name="lvlProficiency" comment="熟练度等级"/>
-- <attribute type="int" name="blessing" comment="进阶祝福值"/>
function LingQiModel:SetInfo(info)
	self:SetModelLevel(info.modelLevel)
	self:SetLvlProficiency(info.lvlProficiency)
	self:SetProficiency(info.proficiency)
	self:SetLevel(info.level)
	self:SetBlessing(info.blessing)
	self:SetPillNum(info.pillNum)
	ZiZhiModel:SetZZNum(4, info.zizhiNum)
end

--------------------------- 等阶 -------------------------------
function LingQiModel:GetLevel()
	return self.level;
end

function LingQiModel:SetLevel(level)
	local oldLevel = self.level
	if level == oldLevel then return end
	local levelUp = level - oldLevel
	self.level = level
	if oldLevel ~= 0 then -- == 0 的情况：1)刚登陆 2)刚开启
	self:sendNotification(NotifyConsts.LingQiLevelUp, levelUp)
	self:OnLevelUp()
	end
end

--------------------------- 模型等阶 -------------------------------
function LingQiModel:SetModelLevel(modelLevel)
	if modelLevel == self.modelLevel then return end
	self.modelLevel = modelLevel
	self:sendNotification(NotifyConsts.LingQiModelChange)
	local mainPlayer = MainPlayerController:GetPlayer();
	if mainPlayer then
		mainPlayer:SetLingQi(self.modelLevel)
	end
end

function LingQiModel:GetModelLevel()
	return self.modelLevel
end

--------------------------- 熟练度 -------------------------------
function LingQiModel:GetProficiency()
	return self.proficiency;
end

function LingQiModel:SetProficiency(proficiency)
	local lvlPrfcncy = self.lvlProficiency
	if lvlPrfcncy == LingQiConsts.MaxLvlProficiency then
		self.proficiency = LingQiUtils:GetProficiencyCeiling(self.level, lvlPrfcncy)
	else
		self.proficiency = proficiency
	end
	self:sendNotification(NotifyConsts.LingQiProficiency)
end

--------------------------- 熟练度等阶 -------------------------------
function LingQiModel:GetLvlProficiency()
	return self.lvlProficiency
end

function LingQiModel:SetLvlProficiency(lvlProficiency)
	if self.lvlProficiency == lvlProficiency then return end
	self.lvlProficiency = lvlProficiency
	if self.lvlProficiency == LingQiConsts.MaxLvlProficiency then
		self:SetProficiency()
	end
	local lvlProficiencyUp = lvlProficiency - self.lvlProficiency
	self:sendNotification(NotifyConsts.LingQiPrfcncyLevelUp, lvlProficiencyUp)
	if self.lvlProficiency == LingQiConsts.MaxLvlProficiency then
		self:OnLvlProficiencyJustFull()
	end
end

--------------------------- 祝福值 -------------------------------
function LingQiModel:GetBlessing()
	return self.blessing
end

function LingQiModel:SetBlessing(blessing)
	if self.blessing == blessing then return end
	self.blessing = blessing
	self:sendNotification(NotifyConsts.LingQiBlessing)
end

----------------------------------------- 熟练度等级刚刚满时，提醒升阶引导 -------------------------------
function LingQiModel:OnLvlProficiencyJustFull()
	if self.level < LingQiConsts:GetMaxLevel() then
		UIItemGuide:Open(7);
	end
end

----------------------------------------- 属性丹 -------------------------------
function LingQiModel:SetPillNum(num)
	self.pillNum = num;
	self:sendNotification(NotifyConsts.LingQiSXDChanged);
end

function LingQiModel:GetPillNum()
	return self.pillNum;
end

local timerKey
function LingQiModel:OnLevelUp()
	-- if timerKey then
	-- 	TimerManager:UnRegisterTimer( timerKey )
	-- 	timerKey = nil
	-- end
	-- timerKey = TimerManager:RegisterTimer( function()
	MainLingQiUI:Hide()
	UILingQiShow:Show()
	-- 	timerKey = nil
	-- end, 1000, 1 )
end