--[[
	AchievementVO
	2015年5月20日, PM 12:03:55
	wangyanwei
]]

_G.AchievementVO = {};

function AchievementVO:new()
	local obj = setmetatable({},{__index = self});
	obj.achievementId = nil;		--成就ID
	obj.achievementValue = nil;		--成就value
	obj.achievementState = nil;		--领奖状态
	return obj
end

--获取当前的阶段
function AchievementVO:GetAchievementId()
	return self.achievementId;
end

--获取这个成就类型的value值
function AchievementVO:GetAchievementValue()
	return self.achievementValue;
end

--修改这个成就类型的value值
function AchievementVO:SetAchievementValue(value)
	self.achievementValue = value
end

--当前阶段是否可以领奖
function AchievementVO:IsGetReward()
	local cfg = t_achievement[self.achievementId];
	if self.achievementState == 1 and self.achievementValue >= cfg.val then
		return true
	end
	return false
end

--当前的状态
function AchievementVO:GetRewardState()
	return self.achievementState or 0
end

--修改当前的状态
function AchievementVO:SetRewardState(state)
	self.achievementState = state
end

--获取这个ID的奖励字符串
function AchievementVO:GetIdRewardStr()
	local cfg = t_achievement[self.achievementId];
	if not cfg.exp or cfg.exp == 0 then
		return cfg.reward
	end
	if cfg.reward == '' then
		return '7,' .. cfg.exp
	end
	return ('7,' .. cfg.exp .. '#' .. cfg.reward)
end

--获取这个阶段的点数
function AchievementVO:GetIDPoint()
	return t_achievement[self.achievementId].point or 0
end

--点数是否已领取
function AchievementVO:IsGetPoint()
	return self.achievementState == 0
end