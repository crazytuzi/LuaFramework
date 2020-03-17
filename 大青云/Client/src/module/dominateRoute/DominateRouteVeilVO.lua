--[[
	标题VO
	2015年6月5日, PM 12:06:36
	wangyanwei
]]

_G.DominateRouteVeilVO = {};

function DominateRouteVeilVO:new()
	local obj = setmetatable({},{__index = self});
	obj.id = 0;
	obj.rewardState = 0;
	obj.starNum = 0;
	
	return obj
end

function DominateRouteVeilVO:GetVeilId()
	return self.id;
end

function DominateRouteVeilVO:SetRewardState(state)
	self.rewardState = state;
end

function DominateRouteVeilVO:GetRewardState()
	return self.rewardState;
end

function DominateRouteVeilVO:SetStarNum(num)
	self.starNum = num;
end

function DominateRouteVeilVO:AddStarNum(num)
	self.starNum = self.starNum + num;
end

function DominateRouteVeilVO:GetStarNum()
	return self.starNum;
end