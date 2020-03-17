--[[
	节选VO
	2015年6月5日, AM 11:43:19
	wangyanwei
]]

_G.DominateRouteStageVO = {};

function DominateRouteStageVO:new()
	local obj = setmetatable({},{__index = self});
	obj.id = 0;				--ID
	obj.starLevel = 0;		--评价1-3星
	obj.state = 0;			--首通领取状态  0 不能领取 1  可以领取  2已领取
	obj.num = 0;			--剩余扫荡次数 
	obj.timeNum = 0; 		--剩余扫荡时间
	obj.maxNum = 0; 		--最高次数
	
	return obj
end

function DominateRouteStageVO:SetTimeNum(timeNum)
	self.timeNum = timeNum;
end

function DominateRouteStageVO:GetTimeNum()
	return self.timeNum;
end

function DominateRouteStageVO:GetStageID()
	return self.id;
end

function DominateRouteStageVO:SetStageState(state)
	self.state = state;
end

function DominateRouteStageVO:GetStageState()
	return self.state;
end

function DominateRouteStageVO:SetStageLevel(level)
	if self.starLevel < level then
		self.starLevel = level;
	end
end

function DominateRouteStageVO:GetStageLevel()
	return self.starLevel;
end

function DominateRouteStageVO:SetDaliyNum(num)
	self.num = num;
end

function DominateRouteStageVO:GetDaliyNum()
	return self.num;
end

function DominateRouteStageVO:SetMaxNum(num)
	self.maxNum = num;
end

function DominateRouteStageVO:GetMaxNum()
	return self.maxNum;
end