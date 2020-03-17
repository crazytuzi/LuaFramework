--[[
宝甲：model
2015年4月28日17:12:38
zhangshuhui
]]

BaoJiaModel = Module:new();

-- 宝甲等阶
BaoJiaModel.level = 0; -- 0 ~ 10, 0为未开启
-- 进阶祝福值
BaoJiaModel.blessing = 0;
-- 进阶时自动购买
BaoJiaModel.autoBuy = false;

function BaoJiaModel:SetInfo(info)
	local level = info.level;
	-- 是否有升级
	local levelUp = level - self.level;
	
	self.level = info.level;
	self.blessing = info.blessing;
	
	self:sendNotification( NotifyConsts.BaoJiaUpdate );
	if levelUp > 0 then
		self:sendNotification( NotifyConsts.BaoJiaLevelUp );
	end
end

function BaoJiaModel:SetBlessing( blessing )
	self.blessing = blessing;
	self:sendNotification( NotifyConsts.BaoJiaBlessing );
end

function BaoJiaModel:GetLevel()
	return self.level;
end

function BaoJiaModel:GetBlessing()
	return self.blessing;
end