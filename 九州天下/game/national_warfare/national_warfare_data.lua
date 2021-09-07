NationalWarfareData = NationalWarfareData or BaseClass(BaseEvent)

NationalWarfareData.YunBiaoState = {
	HasNotOpen = 0,			-- 未开启
	Opening = 1,			-- 正在开启
	Finished = 2,			-- 已经结束
	ActOpen = 3,			-- 运镖双倍活动开启
}
NationalWarfareData.SceneId = {
	[2002] = 1,
	[2102] = 2,
	[2202] = 3,
	[2303] = 4,
	[2304] = 5,
}
NationalWarfareData.YingJiuNpcId = {5905, 5908, 5911}
NationalWarfareData.YingJiuLastPhaseNpcId = 5906

function NationalWarfareData:__init()
	if NationalWarfareData.Instance then
		print_error("[NationalWarfareData] Attempt to create singleton twice!")
		return
	end
	NationalWarfareData.Instance = self

	self.camp_war_cfg = nil
	self.citan_other_cfg = nil
	self.citan_color_cfg = nil
	self.citan_npc_cfg = nil
	self.banzhuan_npc_cfg = nil
	self.banzhuan_other_cfg = nil
	self.banzhuan_color_cfg = nil
	self.banzhuan_day_count = 0
	self.scene_role = {}
	self.neizheng_banzhuan_end_time = 0
	self.has_relive_pillar = 0
	self.pos_list = {}
	self.camp_role_count = {}

	self.citan_list = {
		task_phase = 0,						-- 任务阶段
		task_aim = 0,						-- 当前目标：0.无目标；1.去找敌国NPC刷情报；2.去找本国NPC提交情报
		get_qingbao_color = 0,				-- 拿到的情报颜色
		cur_qingbao_color = 0,				-- 当前刷到的情报颜色	
		task_aim_camp = 0,					-- 目标阵营
		yesterday_unaccept_times = 0,		-- 昨日未参加任务的次数
		cur_buy_times = 0,					-- 当前购买的次数
		next_refresh_camp_info_timestmap = 0,		-- 下一次可以国家搬砖的采集的时间
		is_lower_reward = 0,                -- 是否免费复活(回到本国)
	}
	self.banzhuan_list = {
		task_phase = 0,						-- 任务阶段
		task_aim = 0,						-- 当前目标
		get_color = 0,						-- 拿到的情报颜色
		cur_color = 0,						-- 当前刷到的颜色			
		task_aim_camp = 0,					-- 目标阵营
		yesterday_unaccept_times = 0,		-- 昨日未参加任务的次数
		cur_buy_times = 0,					-- 当前购买的次数
		next_refresh_camp_banzhuan_timestmap = 0,		-- 下一次可以国家搬砖的采集的时间
		is_lower_reward = 0,                -- 是否免费复活(回到本国)
	}
	self.yunbiao_user_count = 0
	self.yunbiao_user_list = {}
	self.yunbiao_index = 0

	self.yingjiu_cfg = nil
	self.yingjiu_other_cfg = nil


	self.dachen_item_list = {}
	self.dachen_reward_items = {}

	self.guoqi_item_list = {}

	self.yingjiu_info = {
		task_id = 999990,
		task_type = TASK_TYPE.YINGJIU,
		task_phase = 0,										-- 任务阶段
		task_seq = 0,										-- 当前任务序号
		task_aim_camp = 0,									-- 目标阵营
		yesterday_unaccept_times = 0,						-- 昨日未参加任务的次数
		param1 = 0,											-- 特殊参数1
		param2 = 0,											-- 特殊参数2
	}
	--self.get_yingjiu_task_info_by_seq = ListToMap(self:GetYingJiuCfg(), "seq")
	self.yingjiu_cfg = ListToMap(self:GetCampWarCfg().yingjiu or {}, "seq")
end

function NationalWarfareData:__delete()
	NationalWarfareData.Instance = nil
end

function NationalWarfareData:SetCampObjPos(pos_list)
	self.pos_list = pos_list or {}
end

function NationalWarfareData:GetCampObjPos()
	return self.pos_list
end

function NationalWarfareData:SetSceneRoleCountAck(protocol)
	self.scene_role.scene_id = protocol.scene_id 			-- 场景ID
	self.scene_role.scene_key = protocol.scene_key			-- 场景key
	self.scene_role.role_count = protocol.role_count		-- 玩家数量
	self.camp_role_count = protocol.camp_role_count
end

function NationalWarfareData:GetSceneRoleCountAck()
	return self.scene_role
end

function NationalWarfareData:GetCurSceneCampRoleCount()
	return self.camp_role_count
end

------------------- 刺探信息
function NationalWarfareData:SetCampCitanStatus(protocol)
	self.citan_list.task_phase = protocol.task_phase
	self.citan_list.task_aim = protocol.task_aim
	self.citan_list.get_qingbao_color = protocol.get_qingbao_color
	self.citan_list.cur_qingbao_color = protocol.cur_qingbao_color
	self.citan_list.task_aim_camp = protocol.task_aim_camp
	self.citan_list.yesterday_unaccept_times = protocol.yesterday_unaccept_times
	self.citan_list.cur_buy_times = protocol.cur_buy_times
	self.citan_list.next_refresh_camp_info_timestmap = protocol.next_refresh_camp_info_timestmap
	self.citan_list.has_share_color = protocol.has_share_color
	self.citan_list.is_lower_reward = protocol.is_relive_in_myslef_camp
end

function NationalWarfareData:GetCampCitanStatus()
	return self.citan_list
end

function NationalWarfareData:GetCampCitanDayCount()
	local citan_day_count = self:GetCiTanOtherCfg().max_accept_times or 0
	local buytimes = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_CITAN_BUY_TIMES) --已购买次数
	local complete_times = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_CITAN_ACCEPT_TIMES) --接受次数

	return citan_day_count + buytimes - complete_times
end

function NationalWarfareData:GetCitanTaskCfg()
	if self.citan_list.task_phase <= 0 then return end
	local citan_task_cfg = {}
	citan_task_cfg.task_type = TASK_TYPE.CITAN
	citan_task_cfg.task_aim = self.citan_list.task_aim
	citan_task_cfg.task_aim_camp = self.citan_list.task_aim_camp
	citan_task_cfg.task_id = 999992
	citan_task_cfg.task_name = self:GetCiTanOtherCfg().task_name
	local flag = self.citan_list.task_aim == 1 or self.citan_list.get_qingbao_color <= 0
	citan_task_cfg.task_info = flag and string.format(self:GetCiTanOtherCfg().task_information_1, 
		Language.Common.CampNameAbbr[self.citan_list.task_aim_camp]) or self:GetCiTanOtherCfg().task_information_2

	return citan_task_cfg
end 

function NationalWarfareData:GetCiTanNpc(npc_id, camp_type, task_type)
	local npc_cfg = self:GetCiTanNpcCfg()
	if task_type then
		for k,v in pairs(npc_cfg) do
			if v.accept_npc == npc_id and v.camp_type == camp_type then
				return true
			end
		end
	else
		for k,v in pairs(npc_cfg) do
			if v.refresh_npc == npc_id and v.camp_type == camp_type then
				return true
			end
		end
	end
	return false
end

function NationalWarfareData:GetCiTanNpcCfg()
	if not self.citan_npc_cfg then
		self.citan_npc_cfg = self:GetCampWarCfg().citan_npc or {}
	end
	return self.citan_npc_cfg
end

function NationalWarfareData:GetCiTanOtherCfg()
	if not self.citan_other_cfg then
		self.citan_other_cfg = self:GetCampWarCfg().citan_other[1] or {}
	end
	return self.citan_other_cfg
end

function NationalWarfareData:GetCiTanColorCfg(is_lower_reward)
	if not self.citan_color_cfg or not is_lower_reward then
		self.citan_color_cfg = self:GetCampWarCfg().citan_info or {}
	end
	if is_lower_reward and is_lower_reward == 1 then
		self.citan_color_cfg = {}
		local temp_cfg = self:GetCampWarCfg().relive_reward or {}
		if temp_cfg ~= {} then
	 		for i,v in ipairs(temp_cfg) do
	 			if v.task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN then
	 			    table.insert(self.citan_color_cfg,v)
	 			end
	 		end
	 	end
	end
	return self.citan_color_cfg
end

function NationalWarfareData:GetCiTanRefreshNpc()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in pairs(self:GetCiTanNpcCfg()) do
		if v.camp_type == vo.camp then
			return v.refresh_npc
		end
	end

	return nil
end

function NationalWarfareData:GetCiTanLeftTime()
	local total_time = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_BUY_CAMP_TASK_CITAN_TIMES)
	local buytimes = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_CITAN_BUY_TIMES)

	return total_time - buytimes
end

function NationalWarfareData:GetIsCiTanNpcByCamp(npc_id, camp)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local camp_type = camp or vo.camp
	for k, v in pairs(self:GetCiTanNpcCfg()) do
		if v.camp_type == camp_type then
			if v.accept_npc == npc_id and v.submit_npc == npc_id then
				return true
			end
		else
			if v.refresh_npc == npc_id then
				return true
			end
		end
	end
	return false
end

------------------- 搬砖信息
function NationalWarfareData:SetCampBanzhuanStatus(protocol)
	self.banzhuan_list.task_phase = protocol.task_phase
	self.banzhuan_list.task_aim = protocol.task_aim
	self.banzhuan_list.color = protocol.color
	self.banzhuan_list.get_color = protocol.get_color
	self.banzhuan_list.cur_color = protocol.cur_color
	self.banzhuan_list.task_aim_camp = protocol.task_aim_camp
	self.banzhuan_list.yesterday_unaccept_times = protocol.yesterday_unaccept_times
	self.banzhuan_list.cur_buy_times = protocol.cur_buy_times
	self.banzhuan_list.next_refresh_camp_banzhuan_timestmap = protocol.next_refresh_camp_banzhuan_timestmap
	self.banzhuan_list.has_share_color = protocol.has_share_color
	self.banzhuan_list.is_lower_reward = protocol.is_relive_in_myslef_camp
end

function NationalWarfareData:GetCampBanzhuanStatus()
	return self.banzhuan_list
end

function NationalWarfareData:GetCampBanzhuanDayCount()
	self.banzhuan_day_count = self:GetBanZhuanOtherCfg().max_accept_times
	local buytimes = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_BANZHUAN_BUY_TIMES) --已购买次数
	local complete_times = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_BANZHUAN_ACCEPT_TIMES) --接受次数

	return self.banzhuan_day_count + buytimes - complete_times
end

--带国家类型的
function NationalWarfareData:GetBanZhuanNpc(npc_id, camp_type, task_type)
	-- local npc_cfg = self:GetBanZhuanNpcCfg()
	-- for k,v in pairs(npc_cfg) do
	-- 	if v.accept_npc == npc_id and v.camp_type == camp_type then
	-- 		return true
	-- 	end
	-- end
	-- return false

	local npc_cfg = self:GetBanZhuanNpcCfg()
	if task_type then
		for k,v in pairs(npc_cfg) do
			if v.accept_npc == npc_id and v.camp_type == camp_type then
				return true
			end
		end
	else
		for k,v in pairs(npc_cfg) do
			if v.refresh_npc == npc_id and v.camp_type == camp_type then
				return true
			end
		end
	end
	return false
end

function NationalWarfareData:GetBanZhuanAllNpc(npc_id)
	local npc_cfg = self:GetBanZhuanNpcCfg()
	for k,v in pairs(npc_cfg) do
		if v.accept_npc == npc_id then
			return true
		end
	end
	return false
end

function NationalWarfareData:GetBanZhuanNpcCfg()
	if not self.banzhuan_npc_cfg then
		self.banzhuan_npc_cfg = self:GetCampWarCfg().banzhuan_npc or {}
	end
	return self.banzhuan_npc_cfg
end

function NationalWarfareData:GetBanZhuanOtherCfg()
	if not self.banzhuan_other_cfg then
		self.banzhuan_other_cfg = self:GetCampWarCfg().banzhuan_other[1] or {}
	end
	return self.banzhuan_other_cfg
end

function NationalWarfareData:GetBanZhuanColorCfg(is_lower_reward)
	if not self.banzhuan_color_cfg or not is_lower_reward then
		self.banzhuan_color_cfg = self:GetCampWarCfg().banzhuan_color or {}
	end
	if is_lower_reward and is_lower_reward == 1 then
		self.banzhuan_color_cfg = {}
		local temp_cfg = self:GetCampWarCfg().relive_reward or {}
		if temp_cfg ~= {} then
	 		for i,v in ipairs(temp_cfg) do
	 			if v.task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN then
	 			    table.insert(self.banzhuan_color_cfg,v)
	 			end
	 		end
	 	end
	end
	return self.banzhuan_color_cfg
end

function NationalWarfareData:GetBanZhuanTaskCfg()
	if self.banzhuan_list.task_phase <= 0 then return end
	local banzhuan_task_cfg = {}
	banzhuan_task_cfg.task_type = TASK_TYPE.BANZHUAN
	banzhuan_task_cfg.task_aim = self.banzhuan_list.task_aim
	banzhuan_task_cfg.task_aim_camp = self.banzhuan_list.task_aim_camp
	banzhuan_task_cfg.task_id = 999991
	banzhuan_task_cfg.task_name = self:GetBanZhuanOtherCfg().task_name
	local flag = self.banzhuan_list.task_aim == 1 or self.banzhuan_list.get_color <= 0
	banzhuan_task_cfg.task_info = flag and string.format(self:GetBanZhuanOtherCfg().task_information_1, 
		Language.Common.CampNameAbbr[self.banzhuan_list.task_aim_camp]) or self:GetBanZhuanOtherCfg().task_information_2

	return banzhuan_task_cfg
end

-- 设置运镖时间
function NationalWarfareData:SetCampBanZhuanEndTime(end_time)
	self.neizheng_banzhuan_end_time = end_time
end

-- 获取搬砖是否开启
function NationalWarfareData:GetCampBanZhuanIsOpen()
	return self.neizheng_banzhuan_end_time >= TimeCtrl.Instance:GetServerTime()
end

function NationalWarfareData:GetBanZhuanState()
	local is_open = self:GetCampBanZhuanIsOpen()
	local banzhuan_num = CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.BANZHUAN)
	if is_open then
		return NationalWarfareData.YunBiaoState.Opening
	else
		if banzhuan_num > 0 then
			return NationalWarfareData.YunBiaoState.HasNotOpen
		else
			return NationalWarfareData.YunBiaoState.Finished
		end
	end
end

--当前颜色奖励列表
function NationalWarfareData:GetRewardList(color, task_type,is_lower_reward)
	local color_cfg = task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN and self:GetBanZhuanColorCfg(is_lower_reward) or self:GetCiTanColorCfg(is_lower_reward)
	if color_cfg == nil then return end
	local reward_list = {}
	for i = 1, 3 do
		if color ~= 0 and color_cfg[color].rewards[i-1] then
			table.insert(reward_list, color_cfg[color].rewards[i-1])
		elseif color_cfg[#color_cfg].rewards[i-1] then
			table.insert(reward_list, color_cfg[#color_cfg].rewards[i-1])	
		end
	end

	return reward_list
end

-- 寻路到xx国家的npc
function NationalWarfareData:MoveTaskNpc(npc_cfg, task_camp)
	if npc_cfg == nil then return end

	local role_camp = GameVoManager.Instance:GetMainRoleVo().camp
	for k,v in pairs(npc_cfg) do
		if v.camp_type == task_camp then
			if role_camp == task_camp then
				GuajiCtrl.Instance:MoveToNpc(v.accept_npc, nil, CampData.Instance:GetCampScene(task_camp), nil, nil, true)
			else
				GuajiCtrl.Instance:MoveToNpc(v.refresh_npc, nil, CampData.Instance:GetCampScene(task_camp), nil, nil, true)
			end
		end
	end
end

-- 寻路到采集物
function NationalWarfareData:MoveTaskGather(sence_id)
	local banzhuan_cfg = self:GetBanZhuanOtherCfg()
	local list = ConfigManager.Instance:GetSceneConfig(sence_id).gathers
	local target = Scene.Instance:SelectMinDisGather(banzhuan_cfg.gather_id)
	local x, y = 0, 0

	if target then
		x, y = target:GetLogicPos()
	else
		local target_distance = 1000000
		local p_x, p_y = Scene.Instance:GetMainRole():GetLogicPos()
		for k, v in pairs(list) do
			if v.id == banzhuan_cfg.gather_id then
				if not AStarFindWay:IsBlock(v.x, v.y) then
					local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
					if distance < target_distance then
						target_distance = distance
						x = v.x
						y = v.y
					end
				end
			end
		end
	end
	MoveCache.param1 = banzhuan_cfg.gather_id
	MoveCache.end_type = MoveEndType.GatherById

	GuajiCtrl.Instance:MoveToPos(sence_id, x, y, 4, 2)
end

function NationalWarfareData:GetBanZhuanOtherCampNpc(camp)
	local list = {}
	local npc_cfg = self:GetBanZhuanNpcCfg()
	for k, v in pairs(npc_cfg) do
		if camp ~= v.camp_type then
			table.insert(list, v.refresh_npc)
		end
	end

	return list
end

function NationalWarfareData:GetBanZhuanRefreshNpc(camp)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local camp_type = camp or vo.camp
	for k, v in pairs(self:GetBanZhuanNpcCfg()) do
		if v.camp_type == camp_type then
			return v.refresh_npc
		end
	end

	return nil
end

function NationalWarfareData:GetBanZhuanLeftTime()
	local total_time = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_BUY_CAMP_TASK_BANZHUAN_TIMES)
	local buytimes = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_BANZHUAN_BUY_TIMES)

	return total_time - buytimes
end

function NationalWarfareData:SetBanZhuanHasReceive(enabled)
	self.has_rece_banzhuan = enabled
end

function NationalWarfareData:GetBanZhuanHasReceive()
	return self.has_rece_banzhuan or false
end

function NationalWarfareData:GetIsBanZhuanNpcByCamp(npc_id, camp)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local camp_type = camp or vo.camp
	for k, v in pairs(self:GetBanZhuanNpcCfg()) do
		if v.camp_type == camp_type then
			if v.accept_npc == npc_id and v.submit_npc == npc_id then
				return true
			end
		else
			if v.refresh_npc == npc_id then
				return true
			end
		end
	end
	return false
end
--------------------运镖信息----------------------------------
function NationalWarfareData:SetCampYunbiaoUsers(protocol)
	self.yunbiao_user_count = protocol.count
	self.yunbiao_user_list = protocol.user_info_list
end

function NationalWarfareData:GetCampYunbiaoUsers()
	return self.yunbiao_user_list
end

function NationalWarfareData:GetYunBiaoMaCheShowList()
	local show_list = {}
	local vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in pairs(self.yunbiao_user_list) do
		if nil == show_list[v.camp] then
			show_list[v.camp] = true
		end
	end

	for i = 1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		if nil == show_list[i] or (i == vo.camp and not YunbiaoData.Instance:GetIsHuShong()) then
			show_list[i] = false
		end
	end

	return show_list
end

function NationalWarfareData:GetYunBiaoState()
	local husong_act_isover = ActivityData.Instance:GetActivityIsOver(ACTIVITY_TYPE.HUSONG)
	local husong_act_isopen = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG)
	local is_open = CampData.Instance:GetCampYunbiaoIsOpen()
	local yunbiao_num = CampData.Instance:GetDayCounterList(1)

	if is_open then
		return NationalWarfareData.YunBiaoState.Opening
	else
		if yunbiao_num > 0 then
			return NationalWarfareData.YunBiaoState.HasNotOpen
		else
			if husong_act_isover then
				return NationalWarfareData.YunBiaoState.Finished
			else
				if husong_act_isopen then
					return NationalWarfareData.YunBiaoState.Opening
				else
					return NationalWarfareData.YunBiaoState.ActOpen
				end
			end
		end
	end
end

function NationalWarfareData:SetYunBiaoCurIndex(index)
	self.yunbiao_index = index
end

function NationalWarfareData:GetYunBiaoCurIndex()
	return self.yunbiao_index
end

function NationalWarfareData:GetYunBiaoRewardByIndex(index, give_times)
	local cfg = ConfigManager.Instance:GetAutoConfig("husongcfg_auto")
	-- local yunbiao_color = YunbiaoData.Instance:GetTaskColor()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local task_reward_factor = 0
	local reward_list = {}
	for k, v in pairs(cfg.task_reward_factor_list) do
		if index == v.task_color then
			task_reward_factor = v.factor / 100 
		end
	end
	for k, v in pairs(cfg.task_reward_list) do
		if role_level >= v.min_limit_level and role_level <= v.max_limit_level then
			for k1, v1 in pairs(v.reward_item) do
				local tab = {}
				tab.item_id = v1.item_id
				if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG) or CampData.Instance:GetCampYunbiaoIsOpen() then
					tab.num = math.floor(v1.num * task_reward_factor * (give_times + 1))
				else
					tab.num = math.floor(v1.num * task_reward_factor * give_times)
				end
				tab.is_bind = v1.is_bind
				table.insert(reward_list, tab)
			end
		end
	end
	return reward_list
end

function NationalWarfareData:GetIsYunBiaoNPC(npc_id)
	local campwarconfig = ConfigManager.Instance:GetAutoConfig("campwarconfig_auto")
	local yunbiao_other_cfg = campwarconfig.yunbiao_other[1]
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if yunbiao_other_cfg and yunbiao_other_cfg["camp" .. vo.camp .. "_accept_npc"] == npc_id then
		return true
	end

	return false
end

function NationalWarfareData:GetYunBiaoNpcInfo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local campwarconfig = ConfigManager.Instance:GetAutoConfig("campwarconfig_auto")
	local npc_id = campwarconfig.yunbiao_other[1]["camp" .. vo.camp .. "_accept_npc"] or 0
	local campconfg_auto = ConfigManager.Instance:GetAutoConfig("campconfg_auto")
	local scene_id = campconfg_auto.other[1]["scene_id_" .. vo.camp] or 0
	return npc_id, scene_id
end

function NationalWarfareData:SetShowYunBiao(show_yunbiao_word)
	self.show_yunbiao_word = show_yunbiao_word
end

function NationalWarfareData:GetShowYunBiao()
	return self.show_yunbiao_word
end
--------------------------------------------------------------

--------------------大臣信息----------------------------------
function NationalWarfareData:SetCampDachenActStatus(protocol)
	self.dachen_item_list = protocol.item_list
end

function NationalWarfareData:SetKillCampDachen(protocol)
	self.dachen_reward_items = protocol.reward_items
	self.camp_type = protocol.camp_type
	self.reward_times = protocol.reward_times
end

-- 获取大臣活动状态信息
function NationalWarfareData:GetCampDachenActStatus()
	return self.dachen_item_list
end

-- 获取击杀大臣奖励
function NationalWarfareData:GetKillCampDachen()
	return self.dachen_reward_items
end

function NationalWarfareData:GetKillCampDachenreward_times()
	return self.reward_times
end

-- 获取大臣倍击杀的国家
function NationalWarfareData:GetKillCampDaChenCampType()
	return self.camp_type
end

-- 获取大臣开启的国家信息
function NationalWarfareData:GetDaChenCampInfo()
	local dachen_info = self:GetCampDachenActStatus()
	for i=1,3 do
		if dachen_info[i] ~= nil and dachen_info[i].act_status >= 1 then
			return dachen_info[i]
		end
	end
end

-- 获取大臣其他信息配置
function NationalWarfareData:GetDachenOtherInfo()
	return ConfigManager.Instance:GetAutoConfig("campwarconfig_auto").dachen_other
end

-- 获取大臣刷新所在的国家
function NationalWarfareData:GetCampDachen()
	local dachen_info = self:GetCampDachenActStatus()
	if dachen_info then
		for i = 1, 3 do
			if dachen_info[i].act_status >= 1 then
				return i 
			end
		end 
	end
end

-- 大臣防守奖励
function NationalWarfareData:GetDachenFangShouRewardsData()
	local data = self:GetDachenOtherInfo()[1].defend_rewards
	local rewards_data = {}
	for i=1, #data + 1 do
		rewards_data[i] = data[i - 1]
	end
	return rewards_data
end

-- 大臣刷新时间
function NationalWarfareData:GetDachenShuaXinTime()
	local dachen_cfg = ConfigManager.Instance:GetAutoConfig("campwarconfig_auto").dachen_act_time
	local week_day = TimeCtrl.Instance:GetTheDayWeek()
	for i,v in ipairs(dachen_cfg) do
		if week_day - 1 == v.week then
			return v
		end
	end
end

-- 获取大臣任务的时间
function NationalWarfareData:GetDachenTaskTime()
	local dachen_act_time = ConfigManager.Instance:GetAutoConfig("campwarconfig_auto").dachen_act_time
	local cur_time = TimeCtrl.Instance:GetServerTime()
 	local x = os.date("%H", cur_time)        							-- 小时
	local f = os.date("%M", cur_time) 		 							-- 分钟
	local week_day = TimeCtrl.Instance:GetTheDayWeek()                  -- 今天星期几
	local task_time = tonumber(x .. f)
	local hour, min = ""

	for i,v in ipairs(dachen_act_time) do
		if week_day - 1 == v.week then
			if task_time < v.camp_1_showtime then
				hour, min = math.floor(v.camp_1_showtime / 100), string.format("%02d", v.camp_1_showtime % 100)
				return hour .. ":" .. min
			elseif task_time >= v.camp_1_showtime and task_time < v.camp_2_showtime then
				hour, min = math.floor(v.camp_2_showtime / 100), string.format("%02d", v.camp_2_showtime % 100)
				return hour .. ":" .. min
			elseif task_time >= v.camp_2_showtime and task_time < v.camp_3_showtime then
				hour, min = math.floor(v.camp_3_showtime / 100), string.format("%02d", v.camp_3_showtime % 100)
				return hour .. ":" .. min
			elseif task_time >= v.camp_3_showtime then
				hour, min = math.floor(v.camp_1_showtime / 100), string.format("%02d", v.camp_1_showtime % 100)
				return Language.NationalWarfare.ToDay .. hour .. ":" .. min
			end
		end
	end
end

function NationalWarfareData:GetDaChenStatus()
	local is_open = false
	local act_time = 0
	local dachen_act_list = self:GetCampDachenActStatus()
	for k, v in pairs(dachen_act_list) do
		if v.act_status == 1 then
			is_open = true
			act_time = v.act_status_switch_timestamp - TimeCtrl.Instance:GetServerTime()
		end
	end

	return is_open, act_time
end

function NationalWarfareData:GetDaChenStandbyCD()
	local standby_cd = 0
	local dachen_act_list = self:GetCampDachenActStatus()
	for k, v in pairs(dachen_act_list) do
		if v.act_status == 1 then
			standby_cd = v.standby_cd
		end
	end

	return standby_cd
end
------------------------------国旗-----------------------------------------------------------
function NationalWarfareData:SetCampGuoQiActStatus(protocol)
	self.guoqi_item_list = protocol.item_list
end

-- 获取国旗活动状态信息
function NationalWarfareData:GetCampGuoQiActStatus()
	return self.guoqi_item_list
end

-- 获取国旗倍击杀的国家
function NationalWarfareData:GetKillCampGuoQiCampType()
	return self.camp_type
end

-- 获取国旗开启的国家信息
function NationalWarfareData:GetGuoQiCampInfo()
	local guoqi_info = self:GetCampGuoQiActStatus()
	if nil ~= next(guoqi_info) then
		for i=1,3 do
			if guoqi_info[i].act_status >= 1 then
				return guoqi_info[i]
			end
		end
	end
end

-- 获取国旗其他信息配置
function NationalWarfareData:GetGuoQiOtherInfo()
	return ConfigManager.Instance:GetAutoConfig("campwarconfig_auto").flag_other
end

-- 获取国旗配置刷新时间
function NationalWarfareData:GetGuoQiActCfgInfo()
	return ConfigManager.Instance:GetAutoConfig("campwarconfig_auto").flag_act_time
end

-- 获取国旗刷新所在的国家
function NationalWarfareData:GetCampGuoQi()
	local guoqi_info = self:GetCampGuoQiActStatus()
	if guoqi_info then
		for i = 1, 3 do
			if guoqi_info[i] ~= nil and guoqi_info[i].act_status >= 1 then
				return i 
			end
		end 
	end
end

-- 国旗防守奖励
function NationalWarfareData:GetGuoQiFangShouRewardsData()
	local data = self:GetGuoQiOtherInfo()[1].defend_rewards
	local rewards_data = {}
	for i=1, #data + 1 do
		rewards_data[i] = data[i - 1]
	end
	return rewards_data
end

-- 国旗刷新时间
function NationalWarfareData:GetGuoQiShuaXinTime()
	local guoqi_cfg = self:GetGuoQiActCfgInfo()
	local week_day = TimeCtrl.Instance:GetTheDayWeek()
	for i,v in ipairs(guoqi_cfg) do
		if week_day - 1 == v.week then
			return v
		end
	end
end

-- 获取国旗任务的时间
function NationalWarfareData:GetGuoQiTaskTime()
	local guoqi_act_time = self:GetGuoQiActCfgInfo()
	local cur_time = TimeCtrl.Instance:GetServerTime()
 	local x = os.date("%H", cur_time)        							-- 小时
	local f = os.date("%M", cur_time) 		 							-- 分钟
	local week_day = TimeCtrl.Instance:GetTheDayWeek()                  -- 今天星期几
	local task_time = tonumber(x .. f)
	local hour, min = ""

	for i,v in ipairs(guoqi_act_time) do
		if week_day - 1 == v.week then
			if task_time < v.camp_1_showtime then
				hour, min = math.floor(v.camp_1_showtime / 100), string.format("%02d", v.camp_1_showtime % 100)
				return hour .. ":" .. min
			elseif task_time >= v.camp_1_showtime and task_time < v.camp_2_showtime then
				hour, min = math.floor(v.camp_2_showtime / 100), string.format("%02d", v.camp_2_showtime % 100)
				return hour .. ":" .. min
			elseif task_time >= v.camp_2_showtime and task_time < v.camp_3_showtime then
				hour, min = math.floor(v.camp_3_showtime / 100), string.format("%02d", v.camp_3_showtime % 100)
				return hour .. ":" .. min
			elseif task_time >= v.camp_3_showtime then
				hour, min = math.floor(v.camp_1_showtime / 100), string.format("%02d", v.camp_1_showtime % 100)
				return Language.NationalWarfare.ToDay .. hour .. ":" .. min
			end
		end
	end
end

function NationalWarfareData:GetGuoQiStatus()
	local is_open = false
	local act_time = 0
	local guoqi_act_list = self:GetCampGuoQiActStatus()
	for k, v in pairs(guoqi_act_list) do
		if v.act_status == 1 then
			is_open = true
			act_time = v.act_status_switch_timestamp - TimeCtrl.Instance:GetServerTime()
		end
	end

	return is_open, act_time
end

function NationalWarfareData:GetGuoQiStandbyCD()
	local standby_cd = 0
	local guoqi_act_list = self:GetCampGuoQiActStatus()
	for k, v in pairs(guoqi_act_list) do
		if v.act_status == 1 then
			standby_cd = v.standby_cd
		end
	end

	return standby_cd
end
------------------------------营救-----------------------------------------------------------------------
function NationalWarfareData:SetSCCampYingjiuStatus(protocol)
	self.yingjiu_info.task_phase = protocol.task_phase
	self.yingjiu_info.task_seq = protocol.task_seq
	self.yingjiu_info.task_aim_camp = protocol.task_aim_camp
	self.yingjiu_info.yesterday_unaccept_times = protocol.yesterday_unaccept_times
	self.yingjiu_info.param1 = protocol.param1
	self.yingjiu_info.param2 = protocol.param2
end

function NationalWarfareData:GetCampWarCfg()
	if not self.camp_war_cfg then
		self.camp_war_cfg = ConfigManager.Instance:GetAutoConfig("campwarconfig_auto")
	end
	return self.camp_war_cfg
end

function NationalWarfareData:GetYingJiuOtherCfg()
	if not self.yingjiu_other_cfg then
		self.yingjiu_other_cfg = self:GetCampWarCfg().yingjiu_other[1] or {}
	end
	return self.yingjiu_other_cfg
end

function NationalWarfareData:GetYingJiuCfg()
	if not self.yingjiu_cfg then
		-- self.yingjiu_cfg = self:GetCampWarCfg().yingjiu or {}
		self.yingjiu_cfg = ListToMap(self:GetCampWarCfg().yingjiu or {}, "seq")
	end
	return self.yingjiu_cfg
end

function NationalWarfareData:GetYingJiuInfo()
	return self.yingjiu_info
end

function NationalWarfareData:GetYingJiuTaskInfoBySeq(seq)
	seq = seq or self.yingjiu_info.task_seq
	if self.yingjiu_cfg then
		return self.yingjiu_cfg[seq]
	end
end

function NationalWarfareData:IsYingJiuTaskAcceptNpc(npc_id, camp)
	local other_cfg = self:GetYingJiuOtherCfg()
	local cfg_npc_id = other_cfg["camp" .. camp .. "_accept_npc"]
	return cfg_npc_id == npc_id
end

function NationalWarfareData:CheckIsTalkNpc(npc_id)
	if npc_id == nil then return end
	local task_cfg = self:GetYingJiuTaskInfoBySeq(self.yingjiu_info.task_seq)
	if task_cfg == nil or task_cfg["camp" .. self.yingjiu_info.task_aim_camp .. "_param1"] == nil then
		return false
	end

	return npc_id == task_cfg["camp" .. self.yingjiu_info.task_aim_camp .. "_param1"]
end

function NationalWarfareData.GetYingJiuTimes()
	local other_cfg = NationalWarfareData.Instance:GetYingJiuOtherCfg()
	local accept_times = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_YINGJIU_ACCEPT_TIMES) or 0
	local buy_times = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_YINGJIU_BUY_TIMES) or 0
	local max_accept_times = other_cfg.max_accept_times or 0
	return accept_times, buy_times, max_accept_times
end

function NationalWarfareData:GetYingJiuLeftTime()
	local total_time = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_BUY_CAMP_TASK_YINGJIU_TIMES)
	local buytimes = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_CAMP_TASK_YINGJIU_BUY_TIMES)

	return total_time - buytimes
end

-------------------------气运塔专用区域----------------------------------
-- 获取气运塔配置数据
function NationalWarfareData:GetCampWarFateOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("campwarconfig_auto").qiyun_other[1] or {}
end


function NationalWarfareData:SetHasRelivePillar(num)
	self.has_relive_pillar = num
end

-- 获取当前场景是否有复活柱
function NationalWarfareData:GetHasRelivePillar()
	return self.has_relive_pillar == 1
end