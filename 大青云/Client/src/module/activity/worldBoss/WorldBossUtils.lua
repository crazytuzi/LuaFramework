--[[
世界boss工具类
2014年12月4日18:27:20
郝户
]]

_G.WorldBossUtils = {};

function WorldBossUtils:GetBirthTime(id)
	local cfg = t_monster[id];
	if not cfg then return {}; end
	local t = GetCommaTable(cfg.birth_time);
	local list = {};
	for i,str in ipairs(t) do
		table.push(list,CTimeFormat:daystr2sec(str));
	end
	table.sort( list, function(A, B) return A < B; end );
	return list;
end

--获取世界Boss下次刷新时间
function WorldBossUtils:GetNextBirthTime(id)
	local list = WorldBossUtils:GetBirthTime(id);
	if #list <= 0 then return -1; end
	local now = GetDayTime();
	if now < list[1] then  return list[1]; end
	for i,time in ipairs(list) do
		if now>time and i<#list then
			local nextTime = list[i+1];
			if now < nextTime then
				return nextTime;
			end
		end
	end
	return list[1];
end

--获取世界Boss下次剩余刷新时间
function WorldBossUtils:GetNextBirthLastTime(id)
	local nextTime = WorldBossUtils:GetNextBirthTime(id);
	if nextTime < 0 then return -1; end
	local now = GetDayTime();
	if now < nextTime then
		return nextTime - now;
	else
		return 24*3600-now + nextTime;
	end
end

function WorldBossUtils:GetUnionDiGongBossTime(fieldCfg)
	local info = UnionDiGongModel:getBossInfo(fieldCfg.id)
	if not info then
		return 0
	end
	local acCfg = t_activity[10013]
	if not acCfg then return 0 end

	local acTimeCfg = split(acCfg.openTime,'#');
	local startCfg = split(acTimeCfg[1],':');
	local endCfg = split(acTimeCfg[2],':');

	local time = info.lastKillTime + EIGHT_HOURS + 60 *fieldCfg.time
	local refreshDayTime = time % ONE_DAY
	-- print(refreshDayTime, 3600 * tonumber(startCfg[1]) + 60 * tonumber(startCfg[2]), 3600 * tonumber(endCfg[1]) + 60 * tonumber(endCfg[2]))
	if refreshDayTime >= (3600 * tonumber(startCfg[1]) + 60 * tonumber(startCfg[2])) and refreshDayTime < (3600 * tonumber(endCfg[1]) + 60 * tonumber(endCfg[2])) then
		--- 今天可以刷
		return time
	end
	-- 明天刷
	return 3600 * tonumber(startCfg[1]) + 60 * tonumber(startCfg[2])
end

function WorldBossUtils:GetNextBossBirthLastTime(fieldCfg)
	local info = UnionDiGongModel:getBossInfo(fieldCfg.id)
	if not info then
		return 0
	end
	local acCfg = t_activity[10013]
	if not acCfg then return 0 end

	local acTimeCfg = split(acCfg.openTime,'#');
	local startCfg = split(acTimeCfg[1],':');
	local endCfg = split(acTimeCfg[2],':');

	local time = info.lastKillTime + EIGHT_HOURS + 60 *fieldCfg.time
	local refreshDayTime = time % ONE_DAY
	-- print(refreshDayTime, 3600 * tonumber(startCfg[1]) + 60 * tonumber(startCfg[2]), 3600 * tonumber(endCfg[1]) + 60 * tonumber(endCfg[2]))
	if refreshDayTime >= (3600 * tonumber(startCfg[1]) + 60 * tonumber(startCfg[2])) and refreshDayTime < (3600 * tonumber(endCfg[1]) + 60 * tonumber(endCfg[2])) then
		--- 今天可以刷
		return time - GetLocalTime()
	end
	-- 明天刷
	return ONE_DAY - GetDayTime() + 3600 * tonumber(startCfg[1]) + 60 * tonumber(startCfg[2])
end

function WorldBossUtils:IsHaveWorldBossCanAtt()
	local mapid = MainPlayerController:GetMapId()

	local lv = MainPlayerModel.humanDetailInfo.eaLevel
	for k, v in pairs(ActivityWorldBoss.worldBossList or {}) do
		if lv >=  t_monster[v.monster].level then
			if v.state == 0 then
				for k1, v1 in pairs(t_worldboss) do
					if v1.map == mapid then
						return false
					end
				end
				return true
			end
		end
	end
	return false
end

function WorldBossUtils:IsHaveFieldBossCanAtt()
	local lv = MainPlayerModel.humanDetailInfo.eaLevel
	for index, cfg in ipairs(t_fieldboss) do
		if lv >= t_monster[cfg.bossId].level then
			local info = PersonalBossModel:GetFieldBossInfo(cfg.id)
			if info and info.state == 0 then
				return true
			end
		end
	end
	return false
end