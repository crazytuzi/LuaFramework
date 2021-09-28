MAX_MULTI_BATTLEFILED_SKILL_COUNT = 4				-- 多人战场技能数量

ZHANCHANG_RESERVE_INFO_TIME_S = 3 * 60				-- 战场保留用户信息 时间

QUNXIANLUANDOU_RANK_NUM = 10						-- 三界战场 实时排行榜信息个数
QUNXIANLUANDOU_SHENSHI_REFRESH_TIME_S = 5 * 60		-- 神石刷新时间 （神石死亡后，5分钟后再刷一个）

QUNXIANLUANDOU_KILL_VALID_TIME_S = 30				-- 击杀有效间隔时间
QUNXIANLUANDOU_ASSIST_VALID_TIME_S = 5				-- 助攻有效时间
QUNXIANLUANDOU_REALIVE_TIME_S = 9					-- 复活时间

BATTLEFIELD_SHENSHI_MAX_OWNER_DISTENCE = 2			-- 战场神石 跟随距离
BATTLEFIELD_SHENSHI_DEST_POINT_DISTANCE = 10		-- 战场神石 到达目标点的允许范围
BATTLEFIELD_SHENSHI_MAX_PICK_UP_DISTANCE = 10		-- 神石拾取最远距离

QUNXIANLUANDOU_SIDE =
{
	SIDE_1 = 0,										-- 三界战场 边1
	SIDE_2 = 1,										-- 三界战场 边2
	SIDE_3 = 2,										-- 三界战场 边3

	SIDE_MAX = 3,
}

QUNXIANLUANDOU_NOTIFY_REASON =
{
	REASON_DEFAULT = 0,								-- 默认
	REASON_WIN = 1,									-- 获胜
	REASON_LOSE = 2,								-- 失败
	REASON_DRAW = 3,								-- 平局
}

ElementBattleData = ElementBattleData or BaseClass()

function ElementBattleData:__init()
	if ElementBattleData.Instance then
		ErrorLog("[ElementBattleData] attempt to create singleton twice!")
		return
	end
	ElementBattleData.Instance =self

	self.baseinfo = {}								-- 基础信息
	self.rankinfo = {}								-- 排行信息
	self.sideinfo = {}								-- 阵营信息
end

function ElementBattleData:__delete()
	ElementBattleData.Instance = nil
end

function ElementBattleData.GetSpecialToKill(s)
	if nil == s then
		return 0
	end
	return s%1000000
end

function ElementBattleData.GetSpecialToSide(s)
	if nil == s then
		return 0
	end
	return math.floor(s/1000000)
end

function ElementBattleData.GetKillToSpecial(s, k)
	if nil == s or nil == k then
		return 0
	end
	return k + s * 1000000
end

function ElementBattleData:SetBaseInfo(value)
	self.baseinfo = value
end

function ElementBattleData:GetBaseInfo()
	return self.baseinfo
end

function ElementBattleData:SetRankInfo(value)
	self.rankinfo = value
end

function ElementBattleData:SetSideInfo(value)
	self.sideinfo = value
	table.sort(self.sideinfo.scores, function(a, b) return a.score > b.score  end )
	for k, v in pairs(self.sideinfo.scores) do
		if v.score > 0 then
			v.islead = self:IsSideLead(v.side)
		end
		v.index = k
	end
end

function ElementBattleData:GetSideInfo()
	return self.sideinfo
end

--检测此阵营是否领先
function ElementBattleData:IsSideLead(_side)
	return _side == self.sideinfo.scores[1].side
end

function ElementBattleData:GetRankList()
	return self.rankinfo.rank_list
end

function ElementBattleData:GetRoleScore(uid)
	if nil == self.baseinfo.kill_honor then
		return 0
	end
	local rolejifen = self.baseinfo.kill_honor + self.baseinfo.assist_honor + self.baseinfo.extra_honor
	rolejifen = rolejifen + self.baseinfo.rob_shenshi_honor + self.baseinfo.free_reward_honor
	return rolejifen
end

function ElementBattleData:GetNextHonorForScore(score)
	local config = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto").reward
	for k, v in ipairs(config) do
		if score <= 0 then
			return v
		elseif config[k + 1] then
			if score < v.need_score_min then
				return v
			end
		else
			return v
		end
	end
	return nil
end

function ElementBattleData.CreateSideVo()
	local vo =
	{
		index = 0,
		side = 0,
		score = 0,
		islead = false, --是否领先
	}
	return vo
end

function ElementBattleData:GetCountdownTime()
	local shorttime = TimeCtrl.Instance:GetServerTime() - self.baseinfo.last_realive_here_timestamp
	return shorttime
end

function ElementBattleData:GetGuajiXY()
	local config = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto").other[1]
	return config.guaji_x, config.guaji_y
end

-- 得到获胜奖励 1 胜利，0失败
function ElementBattleData:GetVectorReward(flag)
	local config = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto").side_reward[1]
	flag = flag or 0
	local reward = {}
	if config then
		if flag == 0 then
			reward = config.lose_item
		else
			reward = config.win_item
		end
	end
	local temp = {}
	for k,v in pairs(reward) do
		table.insert(temp, v)
	end
	return temp
end

-- 得到已经领取的全部奖励
function ElementBattleData:GetFinishReward(score, flag)
	score = score or self:GetRoleScore() or 0
	local config = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto").reward
	if config then
		local total_reward = {reward_item = {}}
		for _,v in ipairs(config) do
			if v.need_score_min > score then
				break
			else
				for k1,v1 in pairs(v.reward_item) do
					local flag = true
					for k2,v2 in pairs(total_reward.reward_item) do
						if v1.item_id == v2.item_id then
							v2.num = v2.num + v1.num
							flag = false
							break
						end
					end
					if flag then
						table.insert(total_reward.reward_item, TableCopy(v1))
					end
				end
			end
		end
		if score >= 1000 then 
			for k,v in ipairs(total_reward.reward_item) do
				for k2,v2 in pairs(total_reward.reward_item) do 
					if v.item_id <= v2.item_id then
						local temp_k = total_reward.reward_item[k]
						total_reward.reward_item[k] = total_reward.reward_item[k2]
						total_reward.reward_item[k2] = temp_k
					end
				end
			end
		end

		return total_reward
	end
end

--获得阵营信息
function ElementBattleData:GetCampName(side)
	local config = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto").relive_pos
	for k,v in pairs(config) do
		if v.side == side then
			return v
		end
	end
end