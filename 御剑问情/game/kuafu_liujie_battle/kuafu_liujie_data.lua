KuafuGuildBattleData = KuafuGuildBattleData or BaseClass()

KuafuLiuJieSceneId = {}

KUAFU_BOSS_TYPE = {
	ELITE = 0,
	BOSS = 1,
}

function KuafuGuildBattleData:__init()
	if KuafuGuildBattleData.Instance ~= nil then
		print_error("[KuafuGuildBattleData] Attemp to create a singleton twice !")
	end
	KuafuGuildBattleData.Instance = self
	self.notify_equip_list = {}
	self.is_hook = true
	self.map_state = true
	self.is_first = true

	self.zhuansheng_info = {}
	self.rank_info = {}

	self.battle_rank_info = {}

	self.notify = {}

	self.monster_info_list = {}
	self.guild_monster_info_list = {}
	self.cankill_list = {}
	self.can_killnum = 0
	self.is_open = false
	self.liujie_log = nil

	self.guild_rank_info = {}
	self.guild_battle_info = {}
	self.tianjiang_enter_info = {}
	self.tianjiang_status_info = {}
	self.tianjiang_angry_info = {}

	self.shenwu_weary_info = {}
	self.shenwu_status_info = {}
	self:DisPoseTaskCfg()
	self.boss_xy = {}
	self.act_end_timestamp = 0

	self.scene_map_occupy_list = nil

	RemindManager.Instance:Register(RemindName.ShowKfBattleRemind, BindTool.Bind(self.HasGuildBattleTask, self))
	RemindManager.Instance:Register(RemindName.ShowKfBattlePreRemind, BindTool.Bind(self.ShowKfBattlePreRemind, self))
	RemindManager.Instance:Register(RemindName.TianjiangRemind, BindTool.Bind(self.ShowTianjiangRemind, self))
	RemindManager.Instance:Register(RemindName.ShenwuRemind, BindTool.Bind(self.ShowShenwuRemind, self))
	self.mianui_open_event = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function KuafuGuildBattleData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShowKfBattleRemind)
	RemindManager.Instance:UnRegister(RemindName.ShowKfBattlePreRemind)
	RemindManager.Instance:UnRegister(RemindName.TianjiangRemind)
	RemindManager.Instance:UnRegister(RemindName.ShenwuRemind)

	KuafuGuildBattleData.Instance = nil
	GlobalEventSystem:UnBind(self.mianui_open_event)
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function KuafuGuildBattleData:MainuiOpenCreate()
	self.timer = GlobalTimerQuest:AddRunQuest(function()
		RemindManager.Instance:Fire(RemindName.ShenwuRemind)
			end, 5)
end

function KuafuGuildBattleData:GetStartFlushTime()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").boss_cfg[1]
	return cfg.start_refresh_time
end

function KuafuGuildBattleData:GetStartFlushTime2()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").boss_cfg[1]
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

--跨服帮派战信息5745
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
	self.rank_info.rank_list = protocol.rank_list
	self.rank_info.scene_id = protocol.scene_id
end

function KuafuGuildBattleData:GetRankInfo()
	return self.rank_info
end

--场景内排行榜信息
function KuafuGuildBattleData:SetGuildBattleSceneInfoIn(protocol)
	self.battle_rank_info.flag_list = protocol.flag_list
	self.battle_rank_info.guild_join_num_list = protocol.guild_join_num_list
	self.battle_rank_info.rank_list_count = protocol.rank_list_count
	self.battle_rank_info.rank_list = protocol.rank_list
end

-- 小地图信息
function KuafuGuildBattleData:SetGuildBattleSceneMapInfo(protocol)
	local temp_scene_map_info = {}
	temp_scene_map_info.scene_id = protocol.scene_id
	temp_scene_map_info.occupy_list = protocol.flag_list
	self.scene_map_occupy_list = temp_scene_map_info
end

function KuafuGuildBattleData:GetGuildBattleSceneMapInfo()
	return self.scene_map_occupy_list
end

function KuafuGuildBattleData:GetBattleRankInfo()
	return self.battle_rank_info
end

function KuafuGuildBattleData:GetSceneIdByIndex(index)
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto")
	if nil == cfg or nil == cfg.city[1] then
		return 0
	end

	return cfg.city[1].scene_id
end


--获取当前积分的奖励列表
function KuafuGuildBattleData:GetScoreReward(score)
	local reward_info = {}
	local score_reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").score_reward
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
	local score_reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").score_reward
	if score >= score_reward_cfg[#score_reward_cfg].score then
		return true
	end
	return false
end

function KuafuGuildBattleData:GetOwnReward(city_index)
	local own_reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").own_reward
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
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").task_cfg
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


function KuafuGuildBattleData:GetMapInfo(index)
	local city = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").city
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
	local flag_cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").flag
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
	if 1 == protocol.is_upedate then
		self.is_open = false
	end
	self.boss_list = boss_list
	self:SetLiuJieBossAnimator()
end

function KuafuGuildBattleData:SetOpenState(state)
	self.is_open = state
end

function KuafuGuildBattleData:GetOpenState()
	return self.is_open
end

--是否有能击杀的BOSS
function KuafuGuildBattleData:HaveBossCanKill()
	local cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in pairs(self.boss_list) do
		if v.status == 1 and my_level >= cfg[v.boss_id].level then
			return true
		end
	end
	return false
end

function KuafuGuildBattleData:IsLiuJieScene(scene_id)
	if scene_id == 1450 or
	   scene_id == 1460 or
	   scene_id == 1461 or
	   scene_id == 1462 or
	   scene_id == 1463 or
	   scene_id == 1464 then
		return true
	else
		return false
	end
end

function KuafuGuildBattleData:SetLiuJieBossAnimator()
	MainUICtrl.Instance:GetLiuJieBossImageAnimator()
end



function KuafuGuildBattleData:GetotherCfg()
	local other = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").other[1]
	return other
end

function KuafuGuildBattleData:GetBossCfg()
	local boss_cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").boss_cfg
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
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").own_reward
	return cfg[1].server_reward_item
end

local AngelList = {
	[1460] = 120,
	[1461] = 120,
	[1462] = 120,
	[1463] = 120,
	[1464] = 120,
}
function KuafuGuildBattleData:GetAngelBySceneId(scene_id)
	return AngelList[scene_id] or 30
end

function KuafuGuildBattleData:GetCityShowItemCfg(id)
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").city
	local list = {}
	local  key = "zhucheng_show_item_id"
	if id == 0 then
		key = "zhucheng_show_item_id"
	else
		key = "weicheng_show_item_id"
	end
	for k,v in pairs(cfg) do
		if v.city_index == id then
			for i=1,4 do
				table.insert(list,v[key .. i])
			end
		end
	end
	return list
end

function KuafuGuildBattleData:GetShowImage(id)
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_guildbattle_auto").own_reward
	return cfg[id].index_0
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

local has_tianjiang_remind = false --每天第一次上线提醒，每在线1小时再提醒
function KuafuGuildBattleData:ShowTianjiangRemind()
	if ClickOnceRemindList[RemindName.TianjiangRemind] == 0 then
		return 0
	else
		if RemindManager.Instance:RemindToday(RemindName.TianjiangRemind) and not has_tianjiang_remind then
			has_tianjiang_remind = true
			ClickOnceRemindList[RemindName.TianjiangRemind] = 0
			RemindManager.Instance:CreateIntervalRemindTimer(RemindName.TianjiangRemind)
			return 0
		end
	end
	local cur_count, max_count = self:GetTiangJiangCount()
	if cur_count < max_count then
		return 1
	end
	return 0
end

function KuafuGuildBattleData:ShowShenwuRemind()
	if ClickOnceRemindList[RemindName.ShenwuRemind] == 0 then
		return 0
	end
	if not self:Istired() then
		return self:IsShenWuBossOpen() and 1 or 0
	end
	return 0
end

function KuafuGuildBattleData:SetMonsterData(protocol)
	self.monster_info_list = protocol.boss_list or {}
	table.sort(self.monster_info_list, function(a, b)
		if a.next_refresh_time ~= b.next_refresh_time then
			return a.next_refresh_time < b.next_refresh_time
		end
		return a.boss_id < b.boss_id
	end)
end

function KuafuGuildBattleData:SetCrossGuildBattleMonsterInfo(protocol)
    self.guild_monster_info_list = protocol.scene_list or {}
end

function KuafuGuildBattleData:GetCrossGuildBattleMonsterInfo()
    return self.guild_monster_info_list
end


function KuafuGuildBattleData:GetMonsterData()
	return self.monster_info_list
end

function KuafuGuildBattleData:GetSceneMapState()
	return self.map_state
end

function KuafuGuildBattleData:SetSceneMapState(state)
	self.map_state = state
end

function KuafuGuildBattleData:SendKuaFuLiuJieLog(protocol)
	self.liujie_log = protocol
end

function KuafuGuildBattleData:GetKuaFuLiuJieLog()
	return self.liujie_log
end


function KuafuGuildBattleData:GetTianjiangBossCfg()
	if nil == self.tianjiang_boss_cfg then
		self.tianjiang_boss_cfg = ConfigManager.Instance:GetAutoConfig("cross_tianjiang_boss_auto")
	end
	return self.tianjiang_boss_cfg
end

function KuafuGuildBattleData:GetShenWuBossCfg()
	if nil == self.shenwu_boss_cfg then
		self.shenwu_boss_cfg = ConfigManager.Instance:GetAutoConfig("cross_shenwu_boss_auto")
	end
	return self.shenwu_boss_cfg
end

function KuafuGuildBattleData:GetShenWuBossOpenTime()
	local cfg = self:GetShenWuBossCfg()
	if cfg then
		local other_cfg = cfg.other[1]
		return other_cfg.open_time, other_cfg.close_time
	end
end

function KuafuGuildBattleData:IsShenWuBossOpen()
	local cfg = self:GetShenWuBossCfg()
	if cfg then
		local other_cfg = cfg.other[1]
		local open_h = math.floor(other_cfg.open_time / 100)
		local open_m = other_cfg.open_time % 100
		local close_h = math.floor(other_cfg.close_time / 100)
		local close_m = other_cfg.close_time % 100
		local server_time = TimeCtrl.Instance:GetServerTime()
		if server_time > 0 then
			local time_table = os.date("*t", server_time)
			local cur_s = time_table.hour * 3600 + time_table.min*60 + time_table.sec
			if cur_s >= open_h * 3600 + open_m * 60 and cur_s <= close_h * 3600 + close_m * 60 then
				return true
			end
		end
	end
	return false
end

function KuafuGuildBattleData:GetTianjiangBossList(monster_type)
	local tj_boss_cfg = self:GetTianjiangBossCfg()
	if tj_boss_cfg.monster then
		local list = {}
		for _,v in pairs(tj_boss_cfg.monster) do
			if v.monster_type == monster_type then
				table.insert(list,v)
			end
		end
		return list
	end
	return nil
end

function KuafuGuildBattleData:GetLayerEliteList(scene_id)
	local list = {}
	local tj_elite_cfg = self:GetTianjiangBossList(KUAFU_BOSS_TYPE.ELITE)
	for _,v in ipairs(tj_elite_cfg) do
		if v.scene_id == scene_id then
			table.insert(list, v)
		end
	end
	return list
end

function KuafuGuildBattleData:GetLayerBossList(scene_id)
	local list = {}
	local tj_boss_cfg = self:GetTianjiangBossList(KUAFU_BOSS_TYPE.BOSS)
	for k,v in pairs(tj_boss_cfg) do
		if v.scene_id == scene_id then
			local boss_info = self:GetTianJiangStatusByBossId(v.monster_id, scene_id)
			local vo = TableCopy(v)
			vo.status = 1
			vo.index = k
			if boss_info then
				vo.status = boss_info.status == 1 and 0 or 1
			end
			table.insert(list, vo)
		end
	end
	table.sort(list, SortTools.KeyLowerSorters("status", "index"))
	return list
end

function KuafuGuildBattleData:SetTianJiangBossEnterInfo(enter_info)
	self.tianjiang_enter_info = enter_info
end

function KuafuGuildBattleData:GetTianJiangBossCost()
	local tj_boss_cfg = self:GetTianjiangBossCfg()
	if tj_boss_cfg.cost then
		for k,v in pairs(tj_boss_cfg.cost) do
			if self.tianjiang_enter_info.enter_count and self.tianjiang_enter_info.enter_count == v.enter_times then
				return v
			end
		end
		return tj_boss_cfg.cost[#tj_boss_cfg.cost]
	end
end

-- 获取天将进入信息
function KuafuGuildBattleData:GetTianJiangBossEnterInfo()
	return self.tianjiang_enter_info
end

function KuafuGuildBattleData:SetTianjiangBossStatusInfo(protocol)
	self.tianjiang_status_info[protocol.scene_id] = protocol.boss_list
end

function KuafuGuildBattleData:SetTianjiangBossAngryInfo(protocol)
	self.tianjiang_angry_info = protocol
end

-- 获取天将boss状态信息
function KuafuGuildBattleData:GetTianjiangBossStatusInfo()
	return self.tianjiang_status_info
end

--获取天将boss当前愤怒值
function KuafuGuildBattleData:GetTianjiangBossAngryInfo()
	return self.tianjiang_angry_info.angry_val or 0
end

function KuafuGuildBattleData:GetTianjiangBossTimeInfo()
	return self.tianjiang_angry_info.kick_out_timestamp or 0
end

function KuafuGuildBattleData:SetShenWuBosswearyInfo(weary_info)
	self.shenwu_weary_info = weary_info
end

-- 获取神武疲劳信息
function KuafuGuildBattleData:GetShenWuBosswearyInfo()
	return self.shenwu_weary_info
end

function KuafuGuildBattleData:SetShenWuBossStatusInfo(protocol)
	self.shenwu_status_info[protocol.scene_id] = protocol.boss_list
end

-- 获取神武状态信息
function KuafuGuildBattleData:GetShenWuBossEnterInfo()
	return self.shenwu_status_info
end

function KuafuGuildBattleData:GetSwBossInfo(scene_id)
    return self.shenwu_status_info[scene_id]
end

function KuafuGuildBattleData:GetTianJiangStatusByBossId(boss_id, scene_id)
    if nil ~= self.tianjiang_status_info[scene_id] then
    	return self.tianjiang_status_info[scene_id][boss_id]
    end
end

function KuafuGuildBattleData:GetTianJiangCurStatusByBossId(boss_id, scene_id)
    if nil ~= self.tianjiang_status_info[scene_id] then
        for k,v in pairs(self.tianjiang_status_info[scene_id]) do
            if v.monster_id == boss_id then
                return math.max(0, v.next_refresh_timestamp - TimeCtrl.Instance:GetServerTime())
            end
        end
    end
    return 0
end

function KuafuGuildBattleData:IsTianJiangBossFlush(protocol)
	for k1, v1 in pairs(self.tianjiang_status_info) do
		if nil == v1 then
			return 0, false
		end

		for k2, v2 in pairs(v1) do
			local temp = protocol.boss_list[k2]

			if nil == temp then
				return 0, false
			end

			if v2.next_refresh_timestamp ~= temp.next_refresh_timestamp then
				local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[k2]
				if 0 == monster_cfg.headid then
					return 0, false
				end
				if 1 == temp.status then
					return k2, true
				end
			end
		end
	end

	return 0, false
end


function KuafuGuildBattleData:GetTjStatusByBossId(boss_id, scene_id)
	local boss_info = self.tianjiang_status_info[scene_id]
	if boss_info then
		return boss_info[boss_id] and boss_info[boss_id].next_refresh_timestamp or 0
	end
	return 0
end

-- 获取层信息
function KuafuGuildBattleData:GetTianjiangSceneList()
	local cfg = self:GetTianjiangBossCfg()
	if cfg then
		return cfg.layer
	end
end

-- 获取层信息
function KuafuGuildBattleData:GetShenWuSceneList()
	local cfg = self:GetShenWuBossCfg()
	if cfg then
		return cfg.layer
	end
end

-- 获取场景层信息
function KuafuGuildBattleData:GetTjSceneList(scene_id)
	local layer = self:GetTianjiangSceneList()
	if layer then
		for _,v in ipairs(layer) do
			if v.scene_id == scene_id then
				return v
			end
		end
	end
	return nil
end

function KuafuGuildBattleData:GetSwSceneList(scene_id)
	local layer = self:GetShenWuSceneList()
	if layer then
		for _,v in ipairs(layer) do
			if v.scene_id == scene_id then
				return v
			end
		end
	end
	return nil
end

--通过场景获取愤怒值
function KuafuGuildBattleData:GetActiveMaxValue(scene_id)
    local cfg = self:GetTjSceneList(scene_id)
	if cfg then
		return cfg.angry_val_limit
	end
	return 0
end

function KuafuGuildBattleData:GetTjBossRewards(scene_id, monster_id)
	local list = {}
	if nil == scene_id or nil == monster_id then
		return list
	end
	local show_item_list = {}
	local tianjiang_cfg = self:GetLayerBossList(scene_id)
	for k,v in pairs(tianjiang_cfg) do
		if v.monster_id == monster_id then
			show_item_list = v.show_item
		end
	end
	for k,v in pairs(show_item_list) do
		list[k + 1] = v.item_id
	end
	return list
end


function KuafuGuildBattleData:GetShenWuBossList()
	local shenwu_cfg = self:GetShenWuBossCfg()
	if shenwu_cfg then
		return shenwu_cfg.monster
	end
end

function KuafuGuildBattleData:GetBossStatusByBossId(scene_id, monster_id)
	if self.shenwu_status_info[scene_id] then
		return self.shenwu_status_info[scene_id][monster_id]
	end
end


function KuafuGuildBattleData:GetLayerSwBossList(scene_id)
	local list = {}
	local sw_boss_cfg = self:GetShenWuBossList()
	for k,v in pairs(sw_boss_cfg) do
		if v.scene_id == scene_id then
			local boss_info = self:GetBossStatusByBossId(scene_id, v.monster_id)
			local vo = TableCopy(v)
			vo.status = 1
			vo.index = k
			if boss_info then
				vo.status = boss_info.status == 1 and 0 or 1
			end
			table.insert(list, vo)
		end
	end
	table.sort(list, SortTools.KeyLowerSorters("status", "index"))
	return list
end

--通过场景配置和怪物ID保存位置
function KuafuGuildBattleData:RegMonsterXY(scene_cfg, boss_id)
	if not scene_cfg or not boss_id then return end

	for _,v in ipairs(scene_cfg.monsters) do
		if v.id == boss_id then
			self.boss_xy[boss_id] = {}
			self.boss_xy[boss_id].x, self.boss_xy[boss_id].y = v.x, v.y
		end
	end
end

function KuafuGuildBattleData:GetBossXY(boss_id)
	return self.boss_xy[boss_id]
end
-- 天将boss其他配置
function KuafuGuildBattleData:GetTianJiangBossOther()
	local tj_boss_other = self:GetTianjiangBossCfg()
	if tj_boss_other.other then
		return tj_boss_other.other[1]
	end
end

function KuafuGuildBattleData:GetShenWuBossOther()
	local sw_boss_other = self:GetShenWuBossCfg()
	if sw_boss_other.other then
		return sw_boss_other.other[1]
	end
end

function KuafuGuildBattleData:GetShenWuBossCost()
	local sw_boss_cfg = self:GetShenWuBossCfg()
	if sw_boss_cfg.cost then
		for k,v in pairs(sw_boss_cfg.cost) do
			if self.shenwu_weary_info.weary_val_limit and self.shenwu_weary_info.weary_val_limit == v.weary_val then
				return v
			end
		end
		return sw_boss_cfg.cost[#sw_boss_cfg.cost]
	end
end

-- 获取神武奖励
function KuafuGuildBattleData:GetShenWuBossRewardList(monster_id)
	if nil == monster_id then
		return reward_list
	end
	local reward_list = {}
	local show_item_list = {}
	local boss_list = self:GetShenWuBossList()
	for k,v in pairs(boss_list) do
		if v.monster_id == monster_id then
			show_item_list = v.show_item
		end
	end
	for k,v in pairs(show_item_list) do
		reward_list[k + 1] = v
	end
	return reward_list
end

function KuafuGuildBattleData:GetTiangJiangCount()
	local vip_count = VipData.Instance:GetFBSaodangCount(VIPPOWER.TIANJIANG_ENTER_TIMES)
	local cur_count = 0
	local max_count = 0
	if self.tianjiang_enter_info.enter_count then
		cur_count = self.tianjiang_enter_info.enter_count
		max_count = self.tianjiang_enter_info.can_enter_count + vip_count
	end
	return cur_count, max_count
end

-- 是否最大进入次数
function KuafuGuildBattleData:GetTiangJiangIsMaxCount()
	local cur_count, max_count = self:GetTiangJiangCount()
	return cur_count >= max_count
end

--当前最大次数是否已达到最高Vip时的最大次数
function KuafuGuildBattleData:GetIsMaxVipCount()
	local cur_count, max_count = self:GetTiangJiangCount()
	local enter_times_max_vip = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.TIANJIANG_ENTER_TIMES, VipData.Instance:GetVipMaxLevel())
	return max_count == enter_times_max_vip
end

--是否进入疲劳
function KuafuGuildBattleData:Istired()
	local other_cfg = self:GetShenWuBossOther()
	local weary_info = self:GetShenWuBosswearyInfo()
	if not other_cfg or not weary_info.weary_val then
		return false
	end
	return weary_info.weary_val >= weary_info.weary_val_limit + other_cfg.weary_val_limit
end

function KuafuGuildBattleData:SetShenWuBossEndTime(act_end_timestamp)
	self.act_end_timestamp = act_end_timestamp
end

function KuafuGuildBattleData:GetShenWuBossSceneEndTime()
	return self.act_end_timestamp
end