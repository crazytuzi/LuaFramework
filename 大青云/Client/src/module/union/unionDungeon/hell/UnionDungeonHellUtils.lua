--[[
帮派副本:地宫炼狱 工具类
2015年2月11日20:37:16
haohu
]]

_G.UnionDungeonHellUtils = {};

function UnionDungeonHellUtils:GetRewardProvider(stratum)
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local rewardCfg = t_hellReward[level];
	local rewardStr = rewardCfg and rewardCfg["layer"..stratum];
	return rewardStr and RewardManager:Parse(rewardStr);
end

-- 获取地宫炼狱层数文本
function UnionDungeonHellUtils:GetStratumTxt( stratum )
	-- local str = UnionHellConsts.StratumTxtMap[stratum] or "missing"
	-- return string.format( "<i>%s</i>", str )
	return UnionHellConsts.StratumTxtMap[stratum] or "missing"
end

function UnionDungeonHellUtils:GetBossName( stratum )
	local cfg = t_guildHell[stratum];
	if not cfg then return end
	local monsterId = cfg.bossid
	local monsterCfg = t_monster[monsterId]
	if not monsterCfg then return end
	return monsterCfg.name
end

-- 获取某一层的时限 秒
function UnionDungeonHellUtils:GetLimitTime( stratum )
	local cfg = t_guildHell[stratum];
	return cfg and cfg.limitTime * 60; -- 将分钟转为秒
end


