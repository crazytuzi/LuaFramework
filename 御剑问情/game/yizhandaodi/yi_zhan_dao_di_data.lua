YiZhanDaoDiData = YiZhanDaoDiData or BaseClass()

-- 踢出理由
KICKOUT_BATTLE_FIELD_REASON =
{
	KICKOUT_BATTLE_FIELD_REASON_INVALID = 0,
	KICKOUT_BATTLE_FIELD_REASON_DEAD_ISOUT = 1,										-- 复活次数没了
	KICKOUT_BATTLE_FIELD_REASON_TIMEOUT = 2,										-- 战场时间到了
}

-- 鼓舞类型
YIZHANDAODI_GUWU_TYPE =
{
	YIZHANDAODI_GUWU_TYPE_INVALID = 0,
	YIZHANDAODI_GUWU_TYPE_GONGJI = 1,
	YIZHANDAODI_GUWU_TYPE_MAXHP = 2,
}

YIZHANDAODI_RANK_NUM = 20

function YiZhanDaoDiData:__init()
	if YiZhanDaoDiData.Instance then
		print_error("[YiZhanDaoDiData] Attempt to create singleton twice!")
		return
	end
	YiZhanDaoDiData.Instance = self

	self.yi_zhan_dao_di_rank_info = {}
	self.yi_zhan_dao_di_title_change_info = {}
	self.yi_zhan_dao_di_lucky_info = {}
	self.yi_zhan_dao_di_kickout_info = {}
	self.yi_zhan_dao_di_user_info = {}
	self.last_first_info = {}

	self.yizhandaodi_cfg = ConfigManager.Instance:GetAutoConfig("yizhandaodiconfig_auto")
end

function YiZhanDaoDiData:__delete()
	self.last_first_info = nil
	YiZhanDaoDiData.Instance = nil
end

-- 排行榜信息
function YiZhanDaoDiData:SetYiZhanDaoDiRankInfo(protocol)
	self.yi_zhan_dao_di_rank_info = protocol.rank_list
end

function YiZhanDaoDiData:GetYiZhanDaoDiRankInfo()
	return self.yi_zhan_dao_di_rank_info
end

function YiZhanDaoDiData:IsUserInRank()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = game_vo.role_id
	for k, v in pairs(self.yi_zhan_dao_di_rank_info) do
		if role_id == v.uid then
			return true, k
		end
	end
	return false, -1
end

-- 称号改变
function YiZhanDaoDiData:SetYiZhanDaoDiTitleChangeInfo(protocol)
	self.yi_zhan_dao_di_title_change_info = protocol
end

function YiZhanDaoDiData:GetYiZhanDaoDiTitleChangeInfo()
	return self.yi_zhan_dao_di_title_change_info
end

-- 幸运玩家信息
function YiZhanDaoDiData:SetYiZhanDaoDiLuckyInfo(protocol)
	self.yi_zhan_dao_di_lucky_info = protocol
end

function YiZhanDaoDiData:GetLuckyRewardNameList()
	return self.yi_zhan_dao_di_lucky_info.luck_user_namelist or {}
end

function YiZhanDaoDiData:GetLuckyRewardNextFlushTime()
	return self.yi_zhan_dao_di_lucky_info.next_lucky_timestamp or 0
end

-- 踢出信息
function YiZhanDaoDiData:SetYiZhanDaoDiKickoutInfo(protocol)
	self.yi_zhan_dao_di_kickout_info = protocol
end

function YiZhanDaoDiData:GetYiZhanDaoDiKickoutInfo()
	return self.yi_zhan_dao_di_kickout_info
end

-- 主角信息
function YiZhanDaoDiData:SetYiZhanDaoDiUserInfo(protocol)
	self.yi_zhan_dao_di_user_info = protocol
end

function YiZhanDaoDiData:GetYiZhanDaoDiUserInfo()
	return self.yi_zhan_dao_di_user_info
end

function YiZhanDaoDiData:GetGuWuValue()
	if Scene.Instance:GetSceneType() ~= SceneType.ChaosWar then
		return 0
	end
	return self.yi_zhan_dao_di_user_info.gongji_guwu_per or 0
end

-- 上一次第一名玩家信息
function YiZhanDaoDiData:SetYiZhanDaoDiLastFirstInfo(protocol)
	self.last_first_info = protocol
end

function YiZhanDaoDiData:GetYiZhanDaoDiLastFirstInfo()
	return self.last_first_info
end

----------- 配置表 ----------

--排行榜奖励
function YiZhanDaoDiData:GetKillRankRewardCfg()
	if nil == self.rank_reward_cfg then
		self.rank_reward_cfg = self.yizhandaodi_cfg.kill_rank_reward
		table.sort(self.rank_reward_cfg, function(a, b)
			return a.rank < b.rank
		end)
	end

	return self.rank_reward_cfg
end

function YiZhanDaoDiData:GetOtherCfg()
	return self.yizhandaodi_cfg.other[1]
end