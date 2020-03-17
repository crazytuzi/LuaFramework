--[[
运营活动-坐骑首日
2015年3月23日14:08:48
haohu
]]

_G.MountFirstDay = OperAct:new( OperActConsts.ID_MountFirstDay );

-- 是否已达成
function MountFirstDay:GetReachState()
	local _, needMountLvl = self:GetCondition()
	local currentLvl = MountModel:GetMountLvl() or 0;
	return currentLvl > needMountLvl;
end