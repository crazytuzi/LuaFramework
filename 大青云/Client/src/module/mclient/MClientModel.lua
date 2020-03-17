--[[
微端
lizhuangzhuang
2015年5月14日15:05:06 
]]

_G.MClientModel = Module:new()

MClientModel.hasGetReward = false;

function MClientModel:SetHasGetReward(state)
	self.hasGetReward = state==1;
end

function MClientModel:GetHasGetReward()
	return self.hasGetReward;
end

