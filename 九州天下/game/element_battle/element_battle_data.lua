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

	self.qunxian_cfg = nil
	self.qunxian_other_cfg = nil
	self.reward_Result_info = {}
end

function ElementBattleData:__delete()
	ElementBattleData.Instance = nil
	self.reward_Result_info = {}
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

function ElementBattleData:SetRewardResultInfo(protocol)
	self.reward_Result_info = {}
	self.reward_Result_info.daily_chestshop_score = protocol.daily_chestshop_score
	self.reward_Result_info.item_list = protocol.item_list
end

function ElementBattleData:GetRewardResultInfo(protocol)
	return self.reward_Result_info
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

--获得自己排名信息
function ElementBattleData:GetOwnRankData()
	local id = GameVoManager.Instance:GetMainRoleVo().role_id
	for i, v in ipairs(self.rankinfo.rank_list) do
		if id == v.uid then
			return v
		end
	end
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

-- 读取群仙配置
function ElementBattleData:GetQunxianCfg()
	if not self.qunxian_cfg then
		self.qunxian_cfg = ConfigManager.Instance:GetAutoConfig("qunxianlundouconfig_auto")
	end
	return self.qunxian_cfg
end

function ElementBattleData:GetQunxianOtherCfg()
	if not self.qunxian_other_cfg then
		self.qunxian_other_cfg = self:GetQunxianCfg().other[1] or {}
	end
	return self.qunxian_other_cfg
end

function ElementBattleData:GetGuajiXY()
	local config = self:GetQunxianOtherCfg()
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
		local total_reward = {reward_item = self:GetVectorReward(flag)}
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
		return total_reward
	end
end