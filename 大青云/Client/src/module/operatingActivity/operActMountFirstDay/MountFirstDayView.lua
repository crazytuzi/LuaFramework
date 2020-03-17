--[[
运营活动-坐骑首日view
2015年3月23日20:02:19
haohu
]]

_G.UIMountFirstDay = UIOperActBase:new( "UIMountFirstDay", OperActConsts.ID_MountFirstDay );

function UIMountFirstDay:Create()
	self:AddSWF("OperAct_MountFirstDayPanel.swf", true, nil);
end

function UIMountFirstDay:OnLoaded( objSwf )
	objSwf.btnGet.click = function() self:OnBtnGetClick(); end
	objSwf.numLoader.loadComplete = function() self:OnNumLoadComplete() end
end

function UIMountFirstDay:OnShow()
	self:ShowTime();
	self:ShowRewardNum();
end

function UIMountFirstDay:ShowTime()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local operAct = self:GetOperAct();
	local restTime = operAct:GetRestTime();
	local hour, min, sec = CTimeFormat:sec2format( restTime );
	local timeStr = string.format("%02dc%02dc%02d", hour, min, sec); -- c代表冒号，用于numLoader加载num目录下的冒号图片
	objSwf.timeLoader:drawStr( timeStr );
end

function UIMountFirstDay:ShowRewardNum()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local operAct = self:GetOperAct();
	objSwf.numLoader.num = operAct:GetRewardNum();
end

function UIMountFirstDay:OnBtnGetClick()
	self:GetReward();
end

function UIMountFirstDay:OnNumLoadComplete()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local num = objSwf.numLoader;
	local numPos = objSwf.numPos;
	num._x = numPos._x + (numPos._width - num._width) * 0.5;
	num._y = numPos._y + (numPos._height - num._height) * 0.5;
end

function UIMountFirstDay:OnObtainStateChange()
	
end

function UIMountFirstDay:OnUsedTimeChange()
	self:ShowTime();
end

function UIMountFirstDay:OnRewardNumChange()
	self:ShowRewardNum();
end