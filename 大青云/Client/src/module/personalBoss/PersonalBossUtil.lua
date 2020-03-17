--[[
	2015年10月31日18:02:59
	wangyanwei
]]

_G.PersonalUtil = {};

--获取个人BOSS进入剩余总次数
function PersonalUtil:GetMaxEnterNum()
	local maxNum = 20;			--假数据
	
	local personalBossList = PersonalBossModel:GetPersonalBossDate();
	
	local num = 0;
	for index , personalVO in ipairs(personalBossList)do
		num = num + personalVO.num ;
	end
	return num;
end

--该BOSS今日是否有首通奖励
function PersonalUtil:GetIDIsFirst(bossId)
	local personalBossList = PersonalBossModel:GetPersonalBossDate();
	
	for index , personalVO in ipairs(personalBossList)do
		if personalVO.bossId == bossId then
			local cfg = t_personalboss[personalVO.id];
			if not cfg then return true end
			return personalVO.isfirst
		end
	end
	
	return true
end

--根据BOSSID获取配置
function PersonalUtil:GetBossIDCfg(bossId)
	for _ , vo in ipairs(t_personalboss) do
		if vo.bossId == bossId then
			return vo;
		end
	end
	return nil;
end

--地宫BOSSID获取配置
function PersonalUtil:GetCaveBossIDCfg(bossId)
	for _ , vo in ipairs(t_swyj) do
		if vo.bossId == bossId then
			return vo;
		end
	end
	return nil;
end

--获取挂机次数
function PersonalUtil:GetAutoNumCfg()
	local cfg = {
		[1] = '1次',
		[2] = '2次',
		[3] = '3次',
		[4] = '4次',
		[5] = '5次',
		[6] = '6次',
		[7] = '7次',
		[8] = '8次',
		[9] = '9次',
		[10] = '10次',
		[11] = '11次',
		[12] = '12次',
		[13] = '13次',
		[14] = '14次',
		[15] = '15次',
	}
	return cfg
end

--------------------------------------------------------------------------------------野外BOSS----------------------------------------------------------

local ONE_DAY = 24 * 60 * 60

function PersonalUtil:GetNextBirthLastTime(id)
	local info = PersonalBossModel:GetFieldBossInfo(id)
	if not info then
		return 0
	end
	local acCfg = t_activity[10012]
	if not acCfg then return 0 end

	local fieldCfg = t_fieldboss[id]
	if not fieldCfg then return 0 end
	local acTimeCfg = split(acCfg.openTime,'#');
	local startCfg = split(acTimeCfg[1],':');
	local endCfg = split(acTimeCfg[2],':');

	local time = info.lastKillTime + EIGHT_HOURS + (fieldCfg.time or 30) * 60
	local refreshDayTime = time % ONE_DAY
	if refreshDayTime >= (3600 * tonumber(startCfg[1]) + 60 * tonumber(startCfg[2])) and refreshDayTime < (3600 * tonumber(endCfg[1]) + 60 * tonumber(endCfg[2])) then
		--- 今天可以刷
		return time - GetLocalTime()
	end
	-- 明天刷
	return ONE_DAY - refreshDayTime + 3600 * tonumber(startCfg[1]) + 60 * tonumber(startCfg[2])
end

function PersonalUtil:GetFieldRefreshTime(id)
	local info = PersonalBossModel:GetFieldBossInfo(id)
	if not info then
		return 0
	end
	local acCfg = t_activity[10012]
	if not acCfg then return 0 end

	local fieldCfg = t_fieldboss[id]
	if not fieldCfg then return 0 end
	local acTimeCfg = split(acCfg.openTime,'#');
	local startCfg = split(acTimeCfg[1],':');
	local endCfg = split(acTimeCfg[2],':');

	local time = info.lastKillTime + EIGHT_HOURS + (fieldCfg.time or 30) * 60
	local refreshDayTime = time % ONE_DAY
	if refreshDayTime >= (3600 * tonumber(startCfg[1]) + 60 * tonumber(startCfg[2])) and refreshDayTime < (3600 * tonumber(endCfg[1]) + 60 * tonumber(endCfg[2])) then
		--- 今天可以刷
		return time
	end
	-- 明天刷
	return 3600 * tonumber(startCfg[1]) + 60 * tonumber(startCfg[2])
end

--8：00
--23:30
--秘境boss
function PersonalUtil:GetPalaceRefreshTime(id)
	local info = PersonalBossModel:GetPalaceBossInfo(id)
	if not info then
		return 0
	end
	
	local time = GetDayTime()
	if time > (23*3600 + 30 *60) or time < 8*3600 then
		return 8 *3600
	end
	return time + 1800 - time%1800
end