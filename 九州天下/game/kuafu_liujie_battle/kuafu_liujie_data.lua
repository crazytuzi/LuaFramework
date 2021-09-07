KuafuGuildBattleData = KuafuGuildBattleData or BaseClass()

KuafuLiuJieSceneId = {}
KuaFfLiuJieSceneIdName = {
	[1] = "庚金",
	[2] = "甲木",
	[3] = "癸水",
	[4] = "丁火",
	[5] = "戊土",
}

function KuafuGuildBattleData:__init()
	if KuafuGuildBattleData.Instance ~= nil then
		print_error("[KuafuGuildBattleData] Attemp to create a singleton twice !")
	end
	KuafuGuildBattleData.Instance = self
	self.notify_equip_list = {}
	self.is_hook = true
	self.capture_captive_appearance_end_time = 0					-- 麻袋结束时间戳  0代表已经结束

	self.zhuansheng_info = {}
	self.rank_info = {}

	self.notify= {}

	self.guild_rank_info = {}
	self.guild_battle_info = {}
	self:DisPoseTaskCfg()

	self.cross_camp_battle_cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto")
	self.task_reward_cfg = ListToMap(self.cross_camp_battle_cfg.task_cfg, "task_index", "task_id")

	RemindManager.Instance:Register(RemindName.ShowKfBattleRemind, BindTool.Bind(self.HasGuildBattleTask, self))
	RemindManager.Instance:Register(RemindName.ShowKfBattlePreRemind, BindTool.Bind(self.ShowKfBattlePreRemind, self))
end

function KuafuGuildBattleData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShowKfBattleRemind)
	RemindManager.Instance:UnRegister(RemindName.ShowKfBattlePreRemind)

	KuafuGuildBattleData.Instance = nil
end

function KuafuGuildBattleData:GetStartFlushTime()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").boss_cfg[1]
	return cfg.start_refresh_time
end

function KuafuGuildBattleData:GetStartFlushTime2()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").boss_cfg[1]
	return cfg.start_refresh_time1
end

function KuafuGuildBattleData:IsInRemindTime()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local os_time = TimeUtil.NowDayTimeStart(now_time) or 0
	local should_times = {
		should_time_1 = os_time + self:GetStartFlushTime(), --14
		should_time_2 = os_time + self:GetStartFlushTime() + 3600,					 --15
		should_time_3 = os_time + self:GetStartFlushTime() + 7200,					 --16
		should_time_4 = os_time + self:GetStartFlushTime2(), --22
		should_time_5 = os_time + self:GetStartFlushTime2() + 3600,
		should_time_6 = os_time + self:GetStartFlushTime2() + 7200
	}
	for i=1,6 do
		if should_times["should_time_" .. i] - now_time < 15 and should_times["should_time_" .. i] - now_time > 0 then
			return true,i
		end
	end
	return false,0
end

function KuafuGuildBattleData:SetGuildBattleInfo(protocol)
	self.guild_battle_info.kf_reward_flag = bit:d2b(protocol.kf_reward_flag)
	self.guild_battle_info.guild_reward_flag = bit:d2b(protocol.guild_reward_flag)
	self.guild_battle_info.is_can_reward = protocol.is_can_reward
	self.guild_battle_info.kf_battle_list = protocol.kf_battle_list
	table.sort(self.guild_battle_info.kf_battle_list, SortTools.KeyLowerSorter("sort"))
end

-- 获取帮派占领信息
function KuafuGuildBattleData:GetGuildBattleInfo()
	return self.guild_battle_info
end

-- 获取全服奖励状态
function KuafuGuildBattleData:GetKfRewardNum()
	if self.guild_battle_info.kf_reward_flag[32] == 0 and self.guild_battle_info.is_can_reward == 1 then
		return 1
	end
	return 0
end

-- 是否有领取全服奖励
function KuafuGuildBattleData:GetIsReward()
	for i,v in ipairs(self.guild_battle_info.kf_battle_list) do
		if self.guild_battle_info.kf_reward_flag[32 - (v.index - 1)] == 1 then
			return true
		end
	end
	return false
end

--是否是我的帮派
function KuafuGuildBattleData:GetIsGuildOwn(index)
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(self.guild_battle_info.kf_battle_list) do
		if index == v.index and role_vo.server_id == v.server_id and role_vo.guild_id == v.guild_id then
			return true
		end
	end
	return false
end
--是否领取帮派奖励
function KuafuGuildBattleData:GetGuildRewardFlag(index)
	return self.guild_battle_info.guild_reward_flag[32 - (index - 1)] == 0 and true or false
end

--跨服帮派战通知信息
function KuafuGuildBattleData:SetGuildBattleNotifyInfo(protocol)
	self.notify.notify_type = protocol.notify_type
	self.notify.param_1 = protocol.param_1
	self.notify.param_2 = protocol.param_2
end

function KuafuGuildBattleData:GetNotifyInfo()
	return self.notify
end

--跨服帮派排行信息
function KuafuGuildBattleData:SetGuildBattleRankInfoResp(protocol)
	self.guild_rank_info = protocol.scene_list
end

function KuafuGuildBattleData:GetGuildBattleRankInfoResp()
	return self.guild_rank_info
end

--排行榜信息
function KuafuGuildBattleData:SetGuildBattleSceneInfo(protocol)
	self.rank_info.flag_list = protocol.flag_list
	self.rank_info.guild_join_num_list = protocol.guild_join_num_list
	self.rank_info.rank_list_count = protocol.rank_list_count
	self.rank_info.first_place_list = protocol.first_place_list
	self.rank_info.rank_list = protocol.rank_list
end

function KuafuGuildBattleData:GetRankInfo()
	return self.rank_info
end

function KuafuGuildBattleData:GetSceneIdByIndex(index)
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto")
	if nil == cfg or nil == cfg.city[1] then
		return 0
	end

	return cfg.city[1].scene_id
end


--获取当前积分的奖励列表
function KuafuGuildBattleData:GetScoreReward(score)
	local reward_info = {}
	local score_reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").score_reward
	if score_reward_cfg then
		for i=1,#score_reward_cfg do
			if score < score_reward_cfg[1].score then
				return score_reward_cfg[1]
			elseif score >= score_reward_cfg[#score_reward_cfg].score then
				return score_reward_cfg[#score_reward_cfg]
			elseif i + 1 <= #score_reward_cfg and score >= score_reward_cfg[i].score and score < score_reward_cfg[i + 1].score then
				return score_reward_cfg[i + 1]
			end
		end
	end
end

function KuafuGuildBattleData:GetMaxScoreReward(score)
	local score_reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").score_reward
	if score >= score_reward_cfg[#score_reward_cfg].score then
		return true
	end
	return false
end

function KuafuGuildBattleData:GetOwnReward(city_index)
	local own_reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").own_reward
	if own_reward_cfg then
		for k,v in pairs(own_reward_cfg) do
			if city_index == v.city_index then
				return v
			end
		end
	end
end

function KuafuGuildBattleData:DisPoseTaskCfg()
	self.task_cfg = {}
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").task_cfg
	for i,v in ipairs(cfg) do
		if self.task_cfg[v.task_index] == nil then
			self.task_cfg[v.task_index] = {}
			self.task_cfg[v.task_index].list = {}
		end
		local data = {}
		data.cfg = v
		data.statu = 0
		data.record = 0
		data.index = v.task_type + 1
		table.insert(self.task_cfg[v.task_index].list, data)
		if self.task_cfg[v.task_index].finish_num == nil then
			self.task_cfg[v.task_index].finish_num = 0
		end
		if KuafuLiuJieSceneId[v.scene_id] == nil then
			KuafuLiuJieSceneId[v.scene_id] = v.task_index
		end
	end
end

function KuafuGuildBattleData:SetGuildbattleTaskInfo(protocol)
	-- local scene_id = KuafuLiuJieSceneId[Scene.Instance:GetSceneId()]
	-- if scene_id == nil then
	-- 	return
	-- end
	self.task_finish_flag = protocol.task_finish_flag
	self:TaskMonitor(protocol.task_record[scene_id])
	self.task_record = protocol.task_record
	for i,v in ipairs(self.task_finish_flag) do
		local flag = bit:d2b(v)
		local finish_num = 0
		for z,c in ipairs(self.task_cfg[i - 1].list) do
			c.statu = flag[33 - c.index]
			if flag[33 - c.index] == 1 then
				finish_num = finish_num + 1
			end
		end
		self:FlushTask(i - 1, finish_num)
	end

	for i,v in ipairs(self.task_record) do
		for i1,v1 in ipairs(self.task_cfg[i - 1].list) do
			v1.record = v[v1.index]
		end
	end
	
end

function KuafuGuildBattleData:HasGuildBattleTask()
	if ClickOnceRemindList[RemindName.ShowKfBattleRemind] and ClickOnceRemindList[RemindName.ShowKfBattleRemind] == 0 then
		return ClickOnceRemindList[RemindName.ShowKfBattleRemind]
	end

	for k,v in pairs(self.task_cfg) do
		for key, value in pairs(v.list) do
			if 0 == value.statu then
				return 1
			end
		end
	end
	return 0
end

function KuafuGuildBattleData:FlushTask(index,num)
	self.task_cfg[index].finish_num = num
	local finish_task = {}
	local unfinish_task = {}
	for i,v in ipairs(self.task_cfg[index].list) do
		if v.statu == 1 then
			table.insert(finish_task,v)
		else
			table.insert(unfinish_task,v)
		end
	end
	self.task_cfg[index].list = {}
	for i,v in ipairs(unfinish_task) do
		table.insert(self.task_cfg[index].list, v)
	end
	for i,v in ipairs(finish_task) do
		table.insert(self.task_cfg[index].list, v)
	end
end

function KuafuGuildBattleData:GetTaskCfgInfo(index)
	return self.task_cfg[index]
end

function KuafuGuildBattleData:GetFinishTaskNum()
	local num = 0
	local total_num = 0 
	if self.task_cfg then
		for k, v in pairs(self.task_cfg) do
			num = num + v.finish_num
			total_num = total_num + #v.list
		end
	end
	return num, total_num
end

function KuafuGuildBattleData:GetMapInfo(index)
	local city = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").map_client
	if city then
		for k,v in pairs(city) do
			if v.city_index == index then
				return v
			end
		end
	end
end

-- 是否是本服占领
function KuafuGuildBattleData:GetCurItemIsthisServer(index)
	local server_id = GameVoManager.Instance:GetMainRoleVo().server_id
	for k,v in pairs(self.guild_battle_info.kf_battle_list) do
		if index == v.index and server_id == v.server_id then
			return true
		end
	end
	return false
end

function KuafuGuildBattleData:GetCurGuildNum(index)
	return self.rank_info.guild_join_num_list[index + 1]
end


function KuafuGuildBattleData:GetSceneFlagCfg(scene_id, id)
	local flag_cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").flag
	for k,v in pairs(flag_cfg) do
		if scene_id == v.scene_id and id == v.flag_id then
			return v
		end
	end
end

function KuafuGuildBattleData:GetOwnGuildName(monster_id)
	local role_vo = RoleData.Instance.role_vo
	for i=1, CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_FLAG_IN_SCENE do
		local t = self.rank_info.flag_list[i]

		if t.monster_id == monster_id then
			local guild_info = {}
			guild_info.guild_name = t.guild_name
			if role_vo.server_id == t.server_id and role_vo.guild_name == t.guild_name then
				guild_info.color = TEXT_COLOR.GREEN
			else
				guild_info.color = TEXT_COLOR.YELLOW
			end
			return guild_info
		end
	end
end

-- 获取全服奖励Index
function KuafuGuildBattleData:GetRewardIndex()
	local server_id = GameVoManager.Instance:GetMainRoleVo().server_id
	local reward_list = {}
	local i = 1
	for k,v in pairs(self.guild_battle_info.kf_battle_list) do
		if server_id == v.server_id then
			reward_list[i] = v.index
			i = i + 1
		end
	end
	return reward_list
end

function KuafuGuildBattleData:NotifyTaskProcessChange(task_id, func)
	self.task_change_callback = func
	self.monitor_task_id = task_id
end
function KuafuGuildBattleData:UnNotifyTaskProcessChange()
	self.task_change_callback = nil
end

function KuafuGuildBattleData:TaskMonitor(task_list)
	local scene_id = KuafuLiuJieSceneId[Scene.Instance:GetSceneId()]
	if task_list ~= nil and self.task_change_callback ~= nil then
		for k,v in ipairs(task_list) do
			if k - 1 == self.monitor_task_id then
				if v > self.task_record[scene_id + 1][k] then
					self.task_change_callback()
				end
				break
			end
		end
	end
end

function KuafuGuildBattleData:GetBossList()
	return self.boss_list
end

function KuafuGuildBattleData:GetBossNum()
	return self.boss_num
end

function KuafuGuildBattleData:SetBossInfo(protocol)
	self.boss_list = protocol.boss_list
	self.boss_num = 0
	local boss_list = {}
	local dead_boss = {}
	if self.boss_list then
		for k,v in pairs(self.boss_list) do
			if v.status == 0 then
				table.insert(dead_boss, v)
			else
				self.boss_num = self.boss_num + 1
				table.insert(boss_list, v)
			end
		end 
		for i,v in ipairs(dead_boss) do
			table.insert(boss_list,v)
		end
	end
	self.boss_list = boss_list
end

function KuafuGuildBattleData:IsLiuJieScene(scene_id)
	if scene_id == 3150 or
	   scene_id == 3151 or
	   scene_id == 3152 or
	   scene_id == 3153 or
	   scene_id == 3154 or
	   scene_id == 3155 then
		return true
	else
		return false
	end
end

function KuafuGuildBattleData:GetotherCfg()
	local other = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").other[1]
	return other
end

function KuafuGuildBattleData:GetBossCfg()
	local boss_cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").boss_cfg
	return boss_cfg
end

function KuafuGuildBattleData:GetTaskNum()
	local num = 0
	for i,v in pairs(self.task_cfg) do
		if v.list[1].statu == 0 then
			num = num + 1
		end
		if v.list[2].statu == 0 then
			num = num + 1
		end
	end
	return num
end

function KuafuGuildBattleData:CheckOpen()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = self:GetotherCfg()
	if level >= cfg.level_limit and day >= cfg.openserver_limit then
		return true
	else
		return false
	end
end

function KuafuGuildBattleData:GetReward()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").own_reward
	return cfg[1].server_reward_item
end

local AngelList = {
	[3150] = 120,
	[3151] = 120,
	[3152] = 120,
	[3153] = 120,
	[3154] = 120,
}
function KuafuGuildBattleData:GetAngelBySceneId(scene_id)
	return AngelList[scene_id] or 30
end

function KuafuGuildBattleData:GetCityShowItemCfg(id)
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").city
	local list = {}
	local  key = "zhucheng_show_item_id"
	if id == 0 then
		key = "zhucheng_show_item_id"
	else
		key = "weicheng_show_item_id"
	end
	for k,v in pairs(cfg) do
		if v.city_index == id then
			for i=1,3 do
				table.insert(list,v[key .. i])
			end
		end
	end
	return list
end

function KuafuGuildBattleData:GetShowImage(id)
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").own_reward
	return cfg[id].king_index_0
end

function KuafuGuildBattleData:CheckPre()
	local cfg = self:GetotherCfg()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local flag = true
	flag = level >= cfg.level_advance and not self:CheckOpen()
	return flag
end

function KuafuGuildBattleData:ShowKfBattlePreRemind()
	if self:CheckPre() then
		return KuafuGuildBattleCtrl.Instance:GetIsFirstOpenPreView()
	end
	return 0
end

-- 场景名字
function KuafuGuildBattleData:GetSceneName()
	if not self.scene_name then
		self.scene_name = {}
		local cfg = ConfigManager.Instance:GetAutoConfig("cross_camp_battle_auto").city
		for k, v in pairs(cfg) do
			self.scene_name[v.city_index] = {}
			self.scene_name[v.city_index].scene_name = v.scene_name
		end
	end
	return self.scene_name
end

function KuafuGuildBattleData:SetSelectBoss(value)
	self.is_select_boss = value or false
end

function KuafuGuildBattleData:GetSelectBoss()
	return self.is_select_boss or false
end

function KuafuGuildBattleData:GetRewardDataByIndex(task_index, task_id)
	local cfg = self.task_reward_cfg[task_index]
	return cfg and cfg[task_id] or nil
end

function KuafuGuildBattleData:GetIsDoubleRewardByIndex(index)
	local kf_battle_info = self.guild_battle_info.kf_battle_list[index]
	if kf_battle_info.is_our_guild == 1 and kf_battle_info.guild_id ~= 0 then
		return true
	end

	return false
end

function KuafuGuildBattleData:SetEndTime(end_time)
	self.capture_captive_appearance_end_time = end_time
end

function KuafuGuildBattleData:GetEndTime()
	return self.capture_captive_appearance_end_time
end

function KuafuGuildBattleData:GetNewTaskCfg()
	local task_cfg = {}
	for _, v in pairs(self.task_cfg) do
		for _, v1 in pairs(v.list) do
			table.insert(task_cfg, v1)
		end
	end

	return task_cfg
end