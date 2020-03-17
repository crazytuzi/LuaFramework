--[[
竞技场
wangshuai
]]

_G.ArenaUtils = {};

-- 是否需要清除冷却时间
function ArenaUtils : TimeIsOk()
	local bo = false;
	local time = tonumber(ArenaModel:GetMyroleInfo().lastTime);
	if time > 2400 then 
		return true;
	else
		return false;
	end;
end;
-- 是否需要购买挑战次数 
function ArenaUtils : ChallengeNum()
	local bo = false;
	local maxnum = tonumber(ArenaModel:GetMyroleInfo().maxchall)
	local num = tonumber(ArenaModel:GetMyroleInfo().chal);
	if num >= maxnum then 
		return true
	else
		return false;
	end;
end;
-- 得到清除当前时间需要的元宝
function ArenaUtils : GetClaerTimeMoney()
	local time = tonumber(ArenaModel:GetMyroleInfo().lastTime);
	local t = toint(time/60)+1;
	return t;
end;