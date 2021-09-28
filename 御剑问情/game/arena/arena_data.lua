ArenaData = ArenaData or BaseClass()

FIELD1V1_STATUS =
{
	AWAIT = 0,					-- 等待
	PREPARE = 1,				-- 准备
	PROCEED = 2,				-- 进行中
	OVER = 3,					-- 结束
}

ArenaData.MaxListItem = 5
function ArenaData:__init()
	if ArenaData.Instance then
		print_error("[ArenaData] Attemp to create a singleton twice !")
	end
	ArenaData.Instance = self

	self.scene_user_list = {} 								-- 场景对象信息
	self.scene_status = -1									-- 当前状态 0 发起方等待中 1准备 2战斗开始 3战斗完成
	self.scene_next_time = -1								-- 当前状态倒计时

	self.user_info = nil									-- 用户信息
	self.last_rank = 0										-- 上次排名
	self.role_info_list = {}								-- 挑战列表用户信息
	self.report_info = {}									-- 战报
	self.rank_info = {}										-- 英雄榜
	self.guanghui_info = {}									-- 光辉
	self.capability_list={}									-- 当前玩家的战力表

	self.cur_best_rank_index = 0
	self.cur_best_rank_pos_index = 0

	self.config = ConfigManager.Instance:GetAutoConfig("challengefield_auto")
	self.history_rank_reward_cfg = ListToMap(self.config.history_rank_reward, "index")
	self.fight_result = {
		rank_up = 0,
	}
	RemindManager.Instance:Register(RemindName.ArenaChallange, BindTool.Bind(self.GetRedPointState, self))
	RemindManager.Instance:Register(RemindName.ArenaReward, BindTool.Bind(self.GetRedPointRewardState, self))
	RemindManager.Instance:Register(RemindName.ArenaTupo, BindTool.Bind(self.GetArenaTupoRemind, self))
	RemindManager.Instance:Register(RemindName.ArenaExchange, BindTool.Bind(self.GetArenaExchangeRemind, self))
end

function ArenaData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ArenaChallange)
	RemindManager.Instance:UnRegister(RemindName.ArenaReward)
	RemindManager.Instance:UnRegister(RemindName.ArenaTupo)
	RemindManager.Instance:UnRegister(RemindName.ArenaExchange)
	ArenaData.Instance = nil
end

function ArenaData:GetArenaRankListMaxPage()
	local role_info = self.rank_info or {}
	local max_page = math.ceil(#role_info / ArenaData.MaxListItem)
	return max_page
end

function ArenaData:GetCurRankItemNumByIndex(index)
	local role_info = self.rank_info or {}
	local num = math.modf(#role_info / ArenaData.MaxListItem)
	local max_page = self:GetArenaRankListMaxPage()
	if index <= max_page then
		return ArenaData.MaxListItem
	else
		return num
	end
end

function ArenaData:GetArenaRankInfo()
	if self.rank_info and next(self.rank_info) then
		return self.rank_info
	end
end

-- 获取当前积分
function ArenaData:GetCurJifen()
	if self.user_info then
		return self.user_info.jifen
	else
		return nil
	end
end

-- 获取排名
function ArenaData:GetRankByUid(uid)
	local rank = 0
	if self.user_info then
		if uid == GameVoManager.Instance:GetMainRoleVo().role_id then
			rank = self.user_info.rank
		else
			for k,v in pairs(self.user_info.rank_list) do
				if v.user_id == uid then
					rank = v.rank
					break
				end
			end
			if rank == 0 then
				for k,v in pairs(self.rank_info) do
					if v.user_id == uid then
						rank = v.rank
						break
					end
				end
			end
		end
	end
	return rank
end

function ArenaData:GetRankRewardData()
	local data = self.config.rank_reward
	if data then
		return data
	end
end

function ArenaData:SetCapabilityList(role_id, capability)
	self.capability_list[role_id] = capability
end

function ArenaData:GetOtherRoleCapability(role_id)
	local capability = 0
	if self.capability_list[role_id] then
		capability = self.capability_list[role_id]
	end

	return capability
end

function ArenaData:ClearCapabilityList()
	self.capability_list = nil
	self.capability_list = {}
end


function ArenaData:SetRoleInfo(role_info)
	if role_info then
		--self.role_info_list[role_info.role_id] = role_info
		for k,v in pairs(role_info) do
			self.role_info_list[v.role_id] = v
			-- 防止机器人性别错误
			self.role_info_list[v.role_id].sex = PlayerData.Instance:GetSexByProf(v.prof)
		end
	end
end

-- 获取玩家信息
function ArenaData:GetRoleInfoByUid(uid)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if uid == main_role_vo.role_id then
		return main_role_vo
	end
	return self.role_info_list[uid]
end

function ArenaData:SetGuangHuiData(data)
	self.guanghui_info.guanghui = data.guanghui
	self.guanghui_info.delta_guanghui = data.delta_guanghui
	PlayerData.Instance:SetAttr("guanghui", data.guanghui)
	if data.delta_guanghui > 0 then
        TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddGuangHui, data.delta_guanghui))
    end
end

function ArenaData:GetRoleGuangHuiData()
	if self.guanghui_info then
		return self.guanghui_info
	end
end

-- 获取玩家信息
function ArenaData:GetOtherPlayersInfo()
	return self.role_info_list
end

-- 获取玩家挑战信息
function ArenaData:GetRoleTiaoZhanInfoByUid(uid)
	local info = nil
	if self.user_info then
		for k,v in pairs(self.user_info.rank_list) do
			if v.user_id == uid then
				info = v
				break
			end
		end
	end
	return info
end

-- 奖励是否可领取
function ArenaData:GetCurSeqJiFenRewardIsGet(seq)
	if self.user_info then
		return self.user_info.jifen_reward_flag[seq]
	end
end

-- 获取积分奖励配置
function ArenaData:GetJIfenConfig()
	return self.config.jifen_reward
end

function ArenaData:GetJiFenRewardByIndex(seq)
	local role_lev = GameVoManager.Instance:GetMainRoleVo().level
	local cfg
	for i,v in ipairs(self.config.jifen_reward_detail) do
		if v.seq == seq and role_lev >= v.role_level then
			cfg = v
		end
	end
	return cfg
end

--获取其他配置
function ArenaData:GetOtherConfig()
	return self.config.other[1]
end

-- 获取可领取积分奖励数量
function ArenaData:GetJiFenMayGetReardNum()
	local num = 0
	local flag = self:GetIsCanFetchRankReward()
	if flag then
		num = num + 1
	end
	return num
end

-- 总挑战次数
function ArenaData:GetSumTiaoZhanNum()
	local sum_num = 0
	if self.user_info then
		sum_num = self.user_info.free_day_times + self.user_info.buy_join_times
	end
	return sum_num
end

-- 剩余次数
function ArenaData:GetResidueTiaoZhanNum()
	local num = 0
	if self.user_info then
		num = self:GetSumTiaoZhanNum() - self.user_info.join_times
	end
	return num
end

-- 是否获胜
function ArenaData:IsWin()
	if self.scene_user_list and self.scene_user_list[2] then
		return self.scene_user_list[2].hp <= 0
	end
	return false
end

function ArenaData:GetTargetInfo()
	if self.scene_user_list and self.scene_user_list[2] then
		return self.scene_user_list[2]
	end
	return nil
end

-- 结算信息
function ArenaData:GetResultData()
	local add_jifen = 0
	if self.config.other[1] then
		add_jifen = self:IsWin() and self.config.other[1].win_add_jifen or self.config.other[1].lose_add_jifen
	end
	local data = DungeonData.CreatePassVo()
	data.fb_type = Scene.Instance:GetSceneType()
	data.is_passed = self:IsWin() and 1 or 0
	data.tip1 = ""
	if self.user_info then
		if self.last_rank ~= self.user_info.rank then
			data.param = true
			data.tip1 = string.format(Language.Field1v1.ResultTip1, self.last_rank, self.user_info.rank)
		else
			data.tip1 = string.format(Language.Field1v1.ResultTip2)
		end

		if nil == self.user_info.jifen then return end
		local jifenValue = 0
		jifenValue = self.user_info.jifen - add_jifen
		data.tip2 = string.format(Language.Field1v1.ResultTip3, jifenValue, add_jifen)
		data.tip2 = HtmlTool.BlankReplace(HtmlTool.GetHtml(data.tip2, COLOR3B.WHITE, 26))
		if self:IsWin() then
			data.tip3 = string.format(Language.Field1v1.ResultTip4, self.user_info.best_rank_pos)
			if self.user_info_gold.reward_bind_gold ~= 0 and self.user_info_gold.reward_bind_gold ~= nil then
				data.tip4 = string.format(Language.Field1v1.ResultTip5, self.user_info_gold.reward_bind_gold)
				data.tip5 = Language.NationalBoss.ResultTip4
				self.user_info_gold.reward_bind_gold = 0
			end
		end
	end
	return data
end

function ArenaData:GetFightTime()
	if self.scene_next_time then
		return self.scene_next_time
	end
end

function ArenaData:SetFightResult()
	if self.last_rank ~= self.user_info.rank then
		self.fight_result.rank_up = self.last_rank - self.user_info.rank
	else
		self.fight_result.rank_up = 0
	end
end

function ArenaData:SetFightResult2(data)
	if data then
		self.fight_result.rank_up = data.old_rank_pos - data.new_rank_pos
	end
end

function ArenaData:GetFightResult()
	return self.fight_result
end

-- 获取配置排名声望奖励
function ArenaData:GetRankRewardByRank(rank)
	local reward_config = self.config.rank_reward
	local reward = 0
	for i,v in ipairs(reward_config) do
		if rank - 1 >= v.min_rank_pos and rank - 1 <= v.max_rank_pos then
			reward = v.reward_guanghui
			break
		end
	end
	return reward
end

-- 获取下次结算声望
function ArenaData:GetNextJieShuanShengWangByRank(rank)
	local min_sw, max_sw = self:GetCurRanJieShuanShengWangByRank(rank)
	return self:GetIsMaxJieShuan() and max_sw or min_sw
end

-- 下次是否大结算
function ArenaData:GetIsMaxJieShuan()
	local is_max = false
	local time_tab = TimeCtrl.Instance:GetServerTimeFormat()
	local config = self.config.rank_reward_time_cfg
	if config then
		if time_tab.hour + 1 == config[#config].honor then
			is_max = true
		end
	end
	return is_max
end

-- 获取排名结算声望  返回 普通结算 最终结算
function ArenaData:GetCurRanJieShuanShengWangByRank(rank)
	local min_sw, max_sw = 0, 0
	local config = self.config.rank_reward_time_cfg
	if config then
		local rnak_sw = self:GetRankRewardByRank(rank)
		min_sw = rnak_sw * (config[1].percent / 100)
		max_sw = rnak_sw * (config[#config].percent / 100)
	end
	return min_sw, max_sw
end

-- 是否1v1准备状态
function ArenaData.Is1v1Prepare()
	local boolean = false
	if ArenaData.Instance.scene_status == FIELD1V1_STATUS.PREPARE then
		boolean = true
	end
	return boolean
end

-- 获取本角色最好的排名
function ArenaData:GetBestRank()
	if self.user_info then
		return self.user_info.best_rank_pos
	end
end

-- 获取buff购买次数
function ArenaData:GetBuffBuyTimes()
	if self.user_info then
		return self.user_info.buy_buff_times
	end
end

-- 获取挑战次数购买次数
function ArenaData:GetBuyJoinTimesTimes()
	if self.user_info then
		return self.user_info.buy_join_times
	end
end

function ArenaData:GetUserInfo()
	if self.user_info then
		return self.user_info
	end
end

function ArenaData:GetUserInfoHasItem()
	if self.user_info then
		return #self.user_info.item_list > 0
	end
end

--挑战次数红点
function ArenaData:GetIsFreeDareTimes()
	local times = self:GetResidueTiaoZhanNum()
	if times > 0 then
		return true
	else
		return false
	end
end

--排名奖励红点
function ArenaData:GetIsCanFetchRankReward()
	local flag = self:GetUserInfoHasItem()
	if flag then
		return true
	else
		return false
	end
end

-- 主Ui上的提醒次数
function ArenaData:GetRemindNum()
	local tiaozhan_remind_num = self:GetResidueTiaoZhanNum()
	if ClickOnceRemindList[RemindName.ArenaChallange] and ClickOnceRemindList[RemindName.ArenaChallange] == 0 then
		tiaozhan_remind_num = 0
	end
	local num = tiaozhan_remind_num
	if num > 0 then
		return true
	else
		return false
	end
end

-- 主Ui上的提醒次数
function ArenaData:GetRewardRemindNum()
	local num = self:GetJiFenMayGetReardNum()
	if self.user_info and self.user_info.reward_guanghui > 0 then
		num = num + 1
	end
	if num > 0 then
		return true
	else
		return false
	end
end

function ArenaData:GetRedPointState()
	local open_fun_data = OpenFunData.Instance
	local is_open = open_fun_data:CheckIsHide("arena_view") and not IS_ON_CROSSSERVER
	if is_open then
		return self:GetRemindNum() and 1 or 0
	else
		return 0
	end
end

function ArenaData:GetRedPointRewardState()
	local open_fun_data = OpenFunData.Instance
	local is_open = open_fun_data:CheckIsHide("arena_view")	and not IS_ON_CROSSSERVER
	if is_open then
		return self:GetRewardRemindNum() and 1 or 0
	else
		return 0
	end
end

-----------------------
----突破
-------------------------

function ArenaData:SetBestRank(info)
	self.cur_best_rank_index = info.best_rank_break_level
	local best_rank_pos = info.best_rank_pos + 1
	self:SetBestRankPosIndex(best_rank_pos)
end

function ArenaData:SetBestRankPosIndex(best_rank_pos)
	self.cur_best_rank_pos_index = 0
	if best_rank_pos > 0 then
		for k,v in ipairs(self.config.history_rank_reward) do
			if best_rank_pos <= v.best_rank_pos + 1 then
			 	self.cur_best_rank_pos_index = v.index
			else
			 	break
			end
		end
	end
end
function ArenaData:GetHistoryRankCfg(index)
	index = index or self.cur_best_rank_index
	return self.history_rank_reward_cfg[index]
end

function ArenaData:GetBestRankPosIndex()
	return self.cur_best_rank_pos_index
end

function ArenaData:GetBestRankIndex()
	return self.cur_best_rank_index
end

function ArenaData:GetArenaTupoRemind()
	local open_fun_data = OpenFunData.Instance
	local is_open = open_fun_data:CheckIsHide("arena_view")
	if is_open then
		return self.cur_best_rank_pos_index > self.cur_best_rank_index and 1 or 0
	end
	return 0
end

function ArenaData:GetArenaExchangeRemind()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > 7 then
		return 0
	end
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	local itemid_list = ExchangeData.Instance:GetItemIdListByJobAndType(2, ArenaExchangeView.CURRENT_PRICE_TYPE, prof)
	for _, v2 in ipairs(itemid_list) do
		if v2[2] == 1 then
			return 1
		end
	end

	return 0
end

function ArenaData:RankPosChange(user_id, rank_pos)
	local info = ArenaData.Instance:GetUserInfo()
	if info then
		for k,v in pairs(info.rank_list) do
			if v.user_id == user_id then
				v.rank_pos = rank_pos
				v.rank = rank_pos + 1
			end
		end
	end
end