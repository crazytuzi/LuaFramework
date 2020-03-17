--[[
	2015年12月11日15:18:26
	wangyanwei
	翅膀升星 model
]]

_G.WingStarUpModel = Module:new();

WingStarUpModel.wingStarLevel = nil;			--玩家翅膀的星级
WingStarUpModel.wingStarProgress = nil;			--当前进度值
function WingStarUpModel:SetWingStarData(starLevel,progress)
	if starLevel and self.wingStarLevel ~= starLevel then	--星级发生了变化		
		self.wingStarLevel 		= starLevel;
		self.wingStarProgress 	= progress;
		self:sendNotification(NotifyConsts.WingStarLevelUp);
		return
	end
	self.wingStarLevel 		= starLevel;
	local addprogress = progress - self.wingStarProgress;
	self.wingStarProgress 	= progress;
	self:sendNotification(NotifyConsts.WingStarUpData,{addprogress = addprogress});
end

function WingStarUpModel:GetWingStarLevel()
	return self.wingStarLevel;
end

function WingStarUpModel:GetWingStarProgress()
	return self.wingStarProgress;
end