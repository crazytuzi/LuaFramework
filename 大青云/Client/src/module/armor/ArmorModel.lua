--[[
宝甲：model
2015年1月28日10:40:38
haohu
]]

ArmorModel = Module:new();

-- 宝甲等阶
ArmorModel.level = 0; -- 0 ~ 10, 0为未开启
-- 当前使用宝甲模型的等阶
ArmorModel.modelLevel = 0;
-- 宝甲熟练度
ArmorModel.proficiency = 0;
-- 熟练度等级
ArmorModel.lvlProficiency = 0; -- 0 ~ 5,
-- 进阶祝福值
ArmorModel.blessing = 0;
-- 进阶时自动购买
ArmorModel.autoBuy = false;
--属性丹喂养数量
ArmorModel.pillNum = 0;

-- <attribute type="int" name="level" comment="宝甲等阶"/>
-- <attribute type="int" name="modelLevel" comment="宝甲使用模型的等阶(≤宝甲等阶)"/>
-- <attribute type="int" name="proficiency" comment="宝甲熟练度"/>
-- <attribute type="int" name="lvlProficiency" comment="熟练度等级"/>
-- <attribute type="int" name="blessing" comment="进阶祝福值"/>
function ArmorModel:SetInfo(info)
	self:SetModelLevel( info.modelLevel )
	self:SetLvlProficiency( info.lvlProficiency )
	self:SetProficiency( info.proficiency )
	self:SetLevel( info.level )
	self:SetBlessing( info.blessing )
	self:SetPillNum(info.pillNum)
	ZiZhiModel:SetZZNum(1, info.zizhiNum)
end

--------------------------- 等阶 -------------------------------

function ArmorModel:GetLevel()
	return self.level;
end

function ArmorModel:SetLevel(level)
	local oldLevel = self.level
	if level == oldLevel then return end
	local levelUp = level - oldLevel
	self.level = level
	if oldLevel ~= 0 then -- == 0 的情况：1)刚登陆 2)刚开启
		self:sendNotification( NotifyConsts.ArmorLevelUp, levelUp )
		self:OnLevelUp()
	end
end

--------------------------- 模型等阶 -------------------------------

function ArmorModel:SetModelLevel(modelLevel)
	if modelLevel == self.modelLevel then return end
	self.modelLevel = modelLevel
	self:sendNotification( NotifyConsts.ArmorModelChange )
	local mainPlayer = MainPlayerController:GetPlayer();
	if mainPlayer then
--		mainPlayer:SetMagicWeapon( self.modelLevel )
	end
end

function ArmorModel:GetModelLevel()
	return self.modelLevel
end

--------------------------- 熟练度 -------------------------------

function ArmorModel:GetProficiency()
	return self.proficiency;
end

function ArmorModel:SetProficiency( proficiency )
	local lvlPrfcncy = self.lvlProficiency
	if lvlPrfcncy == ArmorConsts.MaxLvlProficiency then
		self.proficiency = ArmorUtils:GetProficiencyCeiling( self.level, lvlPrfcncy )
	else
		self.proficiency = proficiency
	end
	self:sendNotification( NotifyConsts.ArmorProficiency )
end

--------------------------- 熟练度等阶 -------------------------------

function ArmorModel:GetLvlProficiency()
	return self.lvlProficiency
end

function ArmorModel:SetLvlProficiency(lvlProficiency)
	if self.lvlProficiency == lvlProficiency then return end
	self.lvlProficiency = lvlProficiency
	if self.lvlProficiency == ArmorConsts.MaxLvlProficiency then
		self:SetProficiency()
	end
	local lvlProficiencyUp = lvlProficiency - self.lvlProficiency
	self:sendNotification( NotifyConsts.ArmorPrfcncyLevelUp, lvlProficiencyUp )
	if self.lvlProficiency == ArmorConsts.MaxLvlProficiency then
		self:OnLvlProficiencyJustFull()
	end
end

--------------------------- 祝福值 -------------------------------

function ArmorModel:GetBlessing()
	return self.blessing
end

function ArmorModel:SetBlessing( blessing )
	if self.blessing == blessing then return end
	self.blessing = blessing
	self:sendNotification( NotifyConsts.ArmorBlessing )
end

----------------------------------------- 熟练度等级刚刚满时，提醒升阶引导 -------------------------------

function ArmorModel:OnLvlProficiencyJustFull()
	if self.level < ArmorConsts:GetMaxLevel() then
		UIItemGuide:Open(7);
	end
end

----------------------------------------- 属性丹 -------------------------------
function ArmorModel:SetPillNum(num)
	self.pillNum = num;
	self:sendNotification(NotifyConsts.ArmorSXDChanged);
end

function ArmorModel:GetPillNum()
	return self.pillNum;
end

local timerKey
function ArmorModel:OnLevelUp()
	-- if timerKey then
	-- 	TimerManager:UnRegisterTimer( timerKey )
	-- 	timerKey = nil
	-- end
	-- timerKey = TimerManager:RegisterTimer( function()
		MainArmorUI:Hide()
		UIArmorShow:Show()
	-- 	timerKey = nil
	-- end, 1000, 1 )
end