--[[
神兵：model
2015年1月28日10:40:38
haohu
]]

MagicWeaponModel = Module:new();

-- 神兵等阶
MagicWeaponModel.level = 0; -- 0 ~ 10, 0为未开启
-- 当前使用神兵模型的等阶
MagicWeaponModel.modelLevel = 0;
-- 神兵熟练度
MagicWeaponModel.proficiency = 0;
-- 熟练度等级
MagicWeaponModel.lvlProficiency = 0; -- 0 ~ 5, 
-- 进阶祝福值
MagicWeaponModel.blessing = 0;
-- 进阶时自动购买
MagicWeaponModel.autoBuy = false;
--属性丹喂养数量
MagicWeaponModel.pillNum = 0;

-- <attribute type="int" name="level" comment="神兵等阶"/>
-- <attribute type="int" name="modelLevel" comment="神兵使用模型的等阶(≤神兵等阶)"/>
-- <attribute type="int" name="proficiency" comment="神兵熟练度"/>
-- <attribute type="int" name="lvlProficiency" comment="熟练度等级"/>
-- <attribute type="int" name="blessing" comment="进阶祝福值"/>
function MagicWeaponModel:SetInfo(info)
	self:SetModelLevel( info.modelLevel )
	self:SetLvlProficiency( info.lvlProficiency )
	self:SetProficiency( info.proficiency )
	self:SetLevel( info.level )
	self:SetBlessing( info.blessing )
	self:SetPillNum(info.pillNum)
	ZiZhiModel:SetZZNum(3, info.zizhiNum)
end

--------------------------- 等阶 -------------------------------

function MagicWeaponModel:GetLevel()
	return self.level;
end

function MagicWeaponModel:SetLevel(level)
	local oldLevel = self.level
	if level == oldLevel then return end
	local levelUp = level - oldLevel
	self.level = level
	if oldLevel ~= 0 then -- == 0 的情况：1)刚登陆 2)刚开启
		self:sendNotification( NotifyConsts.MagicWeaponLevelUp, levelUp )
		self:OnLevelUp()
	end
end

--------------------------- 模型等阶 -------------------------------

function MagicWeaponModel:SetModelLevel(modelLevel)
	if modelLevel == self.modelLevel then return end
	self.modelLevel = modelLevel
	self:sendNotification( NotifyConsts.MagicWeaponModelChange )
	local mainPlayer = MainPlayerController:GetPlayer();
	if mainPlayer then
		mainPlayer:SetMagicWeapon( self.modelLevel )
	end
end

function MagicWeaponModel:GetModelLevel()
	return self.modelLevel
end

--------------------------- 熟练度 -------------------------------

function MagicWeaponModel:GetProficiency()
	return self.proficiency;
end

function MagicWeaponModel:SetProficiency( proficiency )
	local lvlPrfcncy = self.lvlProficiency
	if lvlPrfcncy == MagicWeaponConsts.MaxLvlProficiency then
		self.proficiency = MagicWeaponUtils:GetProficiencyCeiling( self.level, lvlPrfcncy )
	else
		self.proficiency = proficiency
	end
	self:sendNotification( NotifyConsts.MagicWeaponProficiency )
end

--------------------------- 熟练度等阶 -------------------------------

function MagicWeaponModel:GetLvlProficiency()
	return self.lvlProficiency
end

function MagicWeaponModel:SetLvlProficiency(lvlProficiency)
	if self.lvlProficiency == lvlProficiency then return end
	self.lvlProficiency = lvlProficiency
	if self.lvlProficiency == MagicWeaponConsts.MaxLvlProficiency then
		self:SetProficiency()
	end
	local lvlProficiencyUp = lvlProficiency - self.lvlProficiency
	self:sendNotification( NotifyConsts.MagicWeaponPrfcncyLevelUp, lvlProficiencyUp )
	if self.lvlProficiency == MagicWeaponConsts.MaxLvlProficiency then
		self:OnLvlProficiencyJustFull()
	end
end

--------------------------- 祝福值 -------------------------------

function MagicWeaponModel:GetBlessing()
	return self.blessing
end

function MagicWeaponModel:SetBlessing( blessing )
	if self.blessing == blessing then return end
	self.blessing = blessing
	self:sendNotification( NotifyConsts.MagicWeaponBlessing )
end

----------------------------------------- 熟练度等级刚刚满时，提醒升阶引导 -------------------------------

function MagicWeaponModel:OnLvlProficiencyJustFull()
	if self.level < MagicWeaponConsts:GetMaxLevel() then
		UIItemGuide:Open(7);
	end
end

----------------------------------------- 属性丹 -------------------------------
function MagicWeaponModel:SetPillNum(num)
	self.pillNum = num;
	self:sendNotification(NotifyConsts.ShenBingSXDChanged);
end

function MagicWeaponModel:GetPillNum()
	return self.pillNum;
end

local timerKey
function MagicWeaponModel:OnLevelUp()
	-- if timerKey then
	-- 	TimerManager:UnRegisterTimer( timerKey )
	-- 	timerKey = nil
	-- end
	-- timerKey = TimerManager:RegisterTimer( function()
		MainMagicWeaponUI:Hide()
		UIMagicWeaponShow:Show()
	-- 	timerKey = nil
	-- end, 1000, 1 )
end
