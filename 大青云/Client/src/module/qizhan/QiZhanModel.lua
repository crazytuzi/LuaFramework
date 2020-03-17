--[[
骑战：model

]]

QiZhanModel = Module:new();

-- 骑战等阶
QiZhanModel.level = 0; -- 0 ~ 10, 0为未开启
-- 进阶祝福值
QiZhanModel.blessing = 0;
-- 进阶时自动购买
QiZhanModel.autoBuy = false;
--属性丹喂养数量
QiZhanModel.pillNum = 0;
--当前选中等阶
QiZhanModel.selectLevel = 0;
function QiZhanModel:SetInfo(info)
	local level = info.level;
	-- 是否有升级
	local levelUp = level - self.level;
	
	-------------------------------------------------
	self.level = level;
	
	-----------------------------------------------------------------------------
	self.blessing = info.blessing;
	self:sendNotification( NotifyConsts.QiZhanUpdate );
	if levelUp > 0 then
		self:sendNotification( NotifyConsts.QiZhanLevelUp );
	end
	--SkillController:OnLingZhenSkillChange()
	self.selectLevel = info.selectlevel;
	self:SetPillNum(info.pillNum);
end

-- 骑战等级上限
function QiZhanModel:GetMaxLevel()
	local maxlevel = 0;
	for i = 1001001,1001100 do
		if not t_ridewar[i] then
			maxlevel = i - 1;
			break;
		end
	end
	return maxlevel;
end

function QiZhanModel:SetBlessing( blessing )
	self.blessing = blessing;
	self:sendNotification( NotifyConsts.QiZhanBlessing );
end

function QiZhanModel:GetLevel()
	return self.level;
end

--骑战等阶
function QiZhanModel:GetQZLevel()
	local cfg = t_ridewar[self.level];
	if cfg then
		return cfg.qzlevel;
	end
	return 0;
end

function QiZhanModel:GetSelectLevel()
	return self.selectLevel;
end
function QiZhanModel:SetSelectLevel(selectLevel)
	self.selectLevel = selectLevel;
	self:sendNotification( NotifyConsts.ChangeQiZhanModel );
end

function QiZhanModel:GetBlessing()
	return self.blessing;
end

function QiZhanModel:SetPillNum(num)
	self.pillNum = num;
	self:sendNotification(NotifyConsts.QiZhanSXDChanged);
end

function QiZhanModel:GetPillNum()
	return self.pillNum;
end