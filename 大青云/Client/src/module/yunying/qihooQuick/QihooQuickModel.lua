--[[
	2015年9月21日, PM 02:39:33
	wangyawnei
]]
_G.QihooQuickModel = Module:new();


QihooQuickModel.qihooRewardState = false;
function QihooQuickModel:OnQihooQuickData(state)
	self.qihooRewardState = state;
end

function QihooQuickModel:IsGetReward()
	return self.qihooRewardState;
end