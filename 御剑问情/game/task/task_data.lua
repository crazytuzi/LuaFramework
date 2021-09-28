TaskData = TaskData or BaseClass()

-- 任务状态
TASK_STATUS = {
	NONE = 0, 										-- 没有任务
	CAN_ACCEPT = 1,									-- 有可接任务
	ACCEPT_PROCESS = 2,								-- 有未完成的任务
	COMMIT = 3,										-- 有可提交任务
}

-- 任务类型
TASK_TYPE = {
	ZHU = 0,										-- 主线
	ZHI = 1,										-- 支线
	RI = 2,											-- 日常
	HU = 3,											-- 护送
	GUILD = 4,										-- 仙盟
	CAMP = 5,										-- 阵营任务
	HUAN = 6,										-- 跑环任务
	WEEK_HUAN = 7,									-- 周常任务

	GUAJI = 10,										-- 挂机任务
	LING = 11,										-- 护送灵石
	LINK = 12,										-- 打开面板
	GUAJIBOSS = 13,									-- 挂机BOSS
	DALIY = 14,										-- 每日任务
}

-- 任务完成条件
TASK_COMPLETE_CONDITION = {
	NPC_TALK = 0, 									-- 对话
	KILL_MONSTER = 1, 								-- 打怪
	GATHER = 2, 									-- 采集
	PASS_FB = 3, 									-- 通关副本
	ENTER_SCENE = 4, 								-- 进入场景
	COMPLETE_TASK = 5, 								-- 完成任务
	NOTHING = 6, 									-- 啥也不干
	HUG = 15, 										-- 抱东西
}

-- 任务接受后做的事
TASK_ACCEPT_OP = {
	-- 1- 6服务器在用
	ENTER_FB = 7,									-- 进入副本
	OPEN_GUIDE_FB_ENTRANCE = 8,						-- 打开引导副本界面
	ENTER_DAILY_TASKFB = 9,							-- 进入日常任务副本
}

TASK_COLOR = {
	[TASK_TYPE.ZHU] = COLOR.WHITE,		-- 白
	[TASK_TYPE.ZHI] = COLOR.GREEN,		-- 绿
	[TASK_TYPE.RI] = COLOR.BLUE,		-- 蓝
	[TASK_TYPE.HU] = COLOR.PURPLE,		-- 紫
	[TASK_TYPE.GUILD] = COLOR.ORANGE,	-- 橙
}

TASK_LINK_TYPE = {
	COMMON = 0,
	ZHUAN_SHENG = 1,
	GUA_JI = 2,
	LING = 3,
	LEVEL_UP = 4,
}

TASK_EVENT_TYPE = {
	accepted_update = 1,
	accepted_add = 2,
	accepted_remove = 3,
	accepted_list = 4,
	completed_list = 5,
	completed_add = 6,
	can_accept_list = 7,
	task_go_on = 8,
}
-- 转生任务指定npcId
TASK_ZHUAN_SHENG_NPC = 564564546
-- 等待可接任务返回

TASK_GUILD_AUTO = false
TASK_RI_AUTO = false
TASK_HUAN_AUTO = false -- 是否自动跑环
TASK_WEEK_HUAN_AUTO = false -- 是否自动周常

MAX_DAILY_TASK_COUNT = 10

TaskData.DoDailyTaskTime = 60
TaskData.DoGuildTaskTime = 60
TaskData.PIG_ID = 105

function TaskData:__init()
	if TaskData.Instance then
		print_error("[TaskData] Attemp to create a singleton twice !")
	end
	TaskData.Instance = self

	self.task_cfg_list = ConfigManager.Instance:GetAutoConfig("tasklist_auto").task_list
	self.task_cfg_other = ConfigManager.Instance:GetAutoConfig("tasklist_auto").other[1]
	self.daliy_task_reward_cfg = ConfigManager.Instance:GetAutoConfig("tasklist_auto").daily_task_reward
	self.guild_task_reward_cfg = ConfigManager.Instance:GetAutoConfig("tasklist_auto").guild_task_reward
	self.task_reward_roll_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("tasklist_auto").task_roll, "task_type")
	self.chapter_cfg_list = ConfigManager.Instance:GetAutoConfig("tasklist_auto").new_task
	self.open_effect_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("tasklist_auto").open_effect, "scene_id")

	self.reward_roll_info = {}						-- 转盘奖励物品
	self.task_cfg_list_dic = {}						-- 任务配置列表，以任务类型为key, cfg列表为值

	self.virtual_xiulian_task_cfg = nil
	self.virtual_begold_task_cfg = nil
	self.virtual_ling_task_cfg = nil
	self.virtual_guajiboss_task_cfg = nil

	self.accepted_info_list = {}					-- 已接任务列表(任务信息参考ProtocolStruct.ReadTaskInfo)
	self.completed_id_list = {}						-- 已完成任务id列表
	self.can_accept_id_list = {}					-- 可接任务id列表
	self.cur_task_id = 0
	self.guild_task_info = {}
	self.paohuan_task_info = {}

	self.task_arrow_kazhuxian = false				-- 是否卡主线任务中

	self:CalcTaskIdListDic()
end

function TaskData:__delete()
	TaskData.Instance = nil
	self.daliy_task_reward_cfg = {}
	self.guild_task_reward_cfg = {}
	self.task_reward_roll_cfg = {}
	self.guild_task_info = {}
	self.daily_task_info = nil
	self.paohuan_task_info = nil
	self.can_accept_id_list = {}
	self.reward_roll_info = {}
end

function TaskData:CalcTaskIdListDic()
	for _, v in pairs(self.task_cfg_list) do
		if nil == self.task_cfg_list_dic[v.task_type] then
			self.task_cfg_list_dic[v.task_type] = {}
		end
		table.insert(self.task_cfg_list_dic[v.task_type], v)
	end
end

function TaskData:GetCurTaskId()
	if self.cur_task_id then
		return self.cur_task_id
	end
end

function TaskData:SetCurTaskId(task_id)
	if task_id and self.task_cfg_list[task_id]
		and (self.task_cfg_list[task_id].task_type == TASK_TYPE.ZHU
			or self.task_cfg_list[task_id].task_type == TASK_TYPE.RI
			or self.task_cfg_list[task_id].task_type == TASK_TYPE.GUILD
			or self.task_cfg_list[task_id].task_type == TASK_TYPE.HUAN
			or self.task_cfg_list[task_id].task_type == TASK_TYPE.WEEK_HUAN
			or task_id == 24001) then
		self.cur_task_id = task_id
	else
		self.cur_task_id = nil
	end
	GlobalEventSystem:Fire(MainUIEventType.CUR_TASK_CHANGE) 				--通知任务面板，当前进行中的任务更改了
end

function TaskData:GetTaskAcceptedInfoList()
	return self.accepted_info_list or {}
end

function TaskData:IsGuildTask(task_id)
	return self.task_cfg_list[task_id] and self.task_cfg_list[task_id].task_type == TASK_TYPE.GUILD
end

function TaskData:IsDailyTask(task_id)
	return self.task_cfg_list[task_id] and self.task_cfg_list[task_id].task_type == TASK_TYPE.RI
end

function TaskData:IsHuanTask(task_id)
	return self.task_cfg_list[task_id] and self.task_cfg_list[task_id].task_type == TASK_TYPE.HUAN
end

function TaskData:IsWeekHuanTask(task_id)
	return self.task_cfg_list[task_id] and self.task_cfg_list[task_id].task_type == TASK_TYPE.WEEK_HUAN
end

function TaskData.IsAutoTaskType(task_type)
	return task_type == TASK_TYPE.ZHU
		or task_type == TASK_TYPE.RI
		or task_type == TASK_TYPE.GUILD
		or task_type == TASK_TYPE.HUAN
		or task_type == TASK_TYPE.WEEK_HUAN
end

local accept_list = nil
function TaskData:SetTaskAcceptedInfoList(accepted_info_list)
	accept_list = {}
	for k,v in pairs(accepted_info_list) do
		if nil == self.accepted_info_list[k] and self.task_cfg_list[k] and TaskData.IsAutoTaskType(self.task_cfg_list[k].task_type) then
			table.insert(accept_list, k)
		end
	end
	self.accepted_info_list = accepted_info_list
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, "accepted_list", accept_list[1])
end

function TaskData:GetTaskInfo(task_id)
	return self.accepted_info_list[task_id]
end

function TaskData:GetCanAcceptTaskInfo(task_id)
	return self.can_accept_id_list[task_id]
end

function TaskData:SetTaskInfo(data)
	local task_info = nil
	local event_type = "accepted_update"
	if data.reason == 0 then			-- 信息改变
		task_info = self.accepted_info_list[data.task_id]
		if self.task_cfg_list[data.task_id]then
			if self.task_cfg_list[data.task_id].task_type == TASK_TYPE.RI then
				TaskData.DoDailyTaskTime = 0
			elseif self.task_cfg_list[data.task_id].task_type == TASK_TYPE.GUILD then
				TaskData.DoGuildTaskTime = 0
			end
		end
	elseif data.reason == 1 then		-- 接取
		task_info = {}
		event_type = "accepted_add"
		for k,v in pairs(self.can_accept_id_list) do
			if k == data.task_id then
				self.can_accept_id_list[k] = nil
				break
			end
		end
	elseif data.reason == 2 then		-- 移除
		self.accepted_info_list[data.task_id] = nil
		event_type = "accepted_remove"
		if self.cur_task_id == data.task_id then
			self:SetCurTaskId(0)
		end
	end

	if task_info ~= nil then
		task_info.task_id = data.task_id
		task_info.task_ver = 0
		task_info.task_condition = 0
		task_info.progress_num = data.param
		task_info.is_complete = data.is_complete
		task_info.accept_time = data.accept_time
		self.accepted_info_list[data.task_id] = task_info
	end
	self:SetCurTaskId(data.task_id)
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, event_type, data.task_id)
end

local complete_list = nil
function TaskData:SetTaskCompletedIdList(completed_id_list)
	complete_list = {}
	for k,v in pairs(completed_id_list) do
		if self.cur_task_id then
			if self.cur_task_id == k then
				self:SetCurTaskId(0)
			end
		end
		if self.completed_id_list[k] == nil and self.task_cfg_list[k] and TaskData.IsAutoTaskType(self.task_cfg_list[k].task_type) then
			table.insert(complete_list, k)
		end
	end
	self.completed_id_list = completed_id_list
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, "completed_list", complete_list[1])
end

function TaskData:GetTaskCompletedList()
	return self.completed_id_list
end

function TaskData:SetTaskCompleted(task_id)
	self.completed_id_list[task_id] = 1
	if task_id == self.cur_task_id then
		self:SetCurTaskId(0)
	end
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, "completed_add", task_id)
end

-- 设置可接受列表
local can_accept_list = nil
function TaskData:SetTaskCapAcceptedIdList(can_accept_id_list)
	can_accept_list = {}
	for k,v in pairs(can_accept_id_list) do
		if nil == self.can_accept_id_list[k] and self.task_cfg_list[k] and TaskData.IsAutoTaskType(self.task_cfg_list[k].task_type) then
			table.insert(can_accept_list, k)
		end
		if self.task_cfg_list[k] and self.task_cfg_list[k].task_type == TASK_TYPE.GUILD then
			TaskCtrl.SendTaskAccept(k)
		end
	end
	self.can_accept_id_list = can_accept_id_list
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, "can_accept_list", can_accept_list[1])
end

function TaskData:GetTaskCapAcceptedIdList()
	return self.can_accept_id_list
end

function TaskData:GetTaskConfig(task_id)
	if nil == task_id then
		return nil
	end

	return self.task_cfg_list[task_id]
end

function TaskData:GetVirtualTaskCfg(task_id)
	if task_id == 999996 then
		return self:GetVirtualGuajiTask()
	elseif task_id == 999997 then
		return self:GetVirtualXiuLianTask()
	elseif task_id == 999998 then
		return self:GetVirtualBeGodTask()
	elseif task_id == 999999 then
		return self:GetVirtualLingTask()
	elseif task_id == 1000000 then
		return self:GetVirtualGuaJiBossTask()
	elseif task_id == 999994 then
		return self:GetVirtualDaliyTask()
	elseif task_id == 999993 then
		return WaBaoData.Instance:GetVirtualWaBaoTask()
	end

	return nil
end

--获得某个任务是否已完成过
function TaskData:GetTaskIsCompleted(task_id)
	if self.completed_id_list[task_id] ~= nil then
		return true
	end
	return false
end

--任务是否已经接受
function TaskData:GetTaskIsAccepted(task_id)
	return self.accepted_info_list[task_id] ~= nil
end

--获得某个任务是否可提交
function TaskData:GetTaskIsCanCommint(task_id)
	return self:GetTaskStatus(task_id) == TASK_STATUS.COMMIT
end

--获得某个任务的当前状态
function TaskData:GetTaskStatus(task_id)
	if task_id ~= nil then
		if self.can_accept_id_list[task_id] ~= nil then
			return TASK_STATUS.CAN_ACCEPT
		end
		if self.accepted_info_list[task_id] ~= nil then
			if self.accepted_info_list[task_id].is_complete ~= 0 then
				return TASK_STATUS.COMMIT
			else
				return TASK_STATUS.ACCEPT_PROCESS
			end
		end
	end
	return TASK_STATUS.NONE
end

--获得npc身上当前的任务状态
function TaskData:GetNpcTaskStatus(npc_id)
	local task_cfg = self:GetNpcOneExitsTask(npc_id)
	if task_cfg ~= nil and task_cfg.task_id ~= nil then
		return self:GetTaskStatus(task_cfg.task_id)
	end
	return TASK_STATUS.NONE
end

--获得NPC身上的一个现有任务
function TaskData:GetNpcOneExitsTask(npc_id)
	local task_list = {}
	local task_cfg = {}
	for k,v in pairs(self.accepted_info_list) do
		task_cfg = self:GetTaskConfig(v.task_id)
		if task_cfg and type(task_cfg.commit_npc) == "table" and task_cfg.commit_npc.id == npc_id then
			if task_cfg.task_id == self.cur_task_id then
				return task_cfg
			end
			task_list[#task_list + 1] = task_cfg
		end
	end
	for k,v in pairs(self.can_accept_id_list) do
		task_cfg = self:GetTaskConfig(k)
		if task_cfg and type(task_cfg.accept_npc) == "table" and task_cfg.accept_npc.id == npc_id then
			if task_cfg.task_id == self.cur_task_id then
				return task_cfg
			end
			task_list[#task_list + 1] = task_cfg
		end
	end

	function SortFun(a, b)
		if a.task_id >= b.task_id then
			return false
		end
		return true
	end

	if #task_list ~= 0 then
		table.sort(task_list, SortFun)
	end

	--取最优
	for k,v in pairs(task_list) do
		local status = self:GetTaskStatus(v.task_id)
		if status == TASK_STATUS.CAN_ACCEPT or status == TASK_STATUS.COMMIT then
			return v
		end
	end
	return task_list[1]
end

--根据类型获得任务列表
function TaskData:GetTaskListIdByType(task_type)
	local task_id_list = {}
	local task_cfg = nil
	for k,v in pairs(self.accepted_info_list) do
		task_cfg = self:GetTaskConfig(v.task_id)
		if task_cfg and task_cfg.task_type == task_type then
			task_id_list[#task_id_list + 1] = v.task_id
		end
	end

	for k,v in pairs(self.can_accept_id_list) do
		task_cfg = self:GetTaskConfig(k)
		if task_cfg and task_cfg.task_type == task_type then
			task_id_list[#task_id_list + 1] = k
		end
	end
	return task_id_list
end

function TaskData:GetZhuTaskConfig()
	local zhu_task_list = self:GetTaskListIdByType(TASK_TYPE.ZHU)
	local zhu_task_cfg = self:GetTaskConfig(zhu_task_list[1])

	if zhu_task_cfg == nil then 	--若服务端没发来则自己取下一个主线任务
		zhu_task_cfg = self:GetNextZhuTaskConfig()
	end

	return zhu_task_cfg
end

--获得下一个主线任务
function TaskData:GetNextZhuTaskConfig()
	local list = self.task_cfg_list_dic[TASK_TYPE.ZHU]
	if nil == list then
		return nil
	end

	for _, v in ipairs(list) do
		if not self.completed_id_list[v.task_id] then
			if v.pretaskid == "" or self.completed_id_list[v.pretaskid] then
				return v
			end
		end
	end

	return nil
end

--获得下一个行会任务
function TaskData:GoOnHuSong()
	local list = self.task_cfg_list_dic[TASK_TYPE.HU]
	if nil == list or #list <= 0 then
		return nil
	end

	TaskCtrl.Instance:DoTask(list[1].task_id)
end

--获得下一个行会任务
function TaskData:GetNextGuildTaskConfig()
	local list = self.task_cfg_list_dic[TASK_TYPE.GUILD]
	if nil == list then
		return nil
	end

	for _, v in ipairs(list) do
		if not self.completed_id_list[v.task_id] then
			if v.pretaskid == "" or self.completed_id_list[v.pretaskid] then
				return v
			end
		end
	end

	return nil
end

-- 通过主线id获得下一个主线
function TaskData:GetNextZhuTaskConfigById(task_id)
	local list = self.task_cfg_list_dic[TASK_TYPE.ZHU]
	if nil == list or nil == task_id then
		return nil
	end

	local task_cfg = self:GetTaskConfig(task_id)
	if task_cfg and task_cfg.task_type == TASK_TYPE.ZHU then
		for _, v in ipairs(list) do
			if v.pretaskid == task_id then
				return v
			end
		end
	end

	return nil
end

function TaskData:GetVirtualGuajiTask()
	return {
		task_id = 999996,
		min_level = 1,
		task_type = TASK_TYPE.LINK,
		open_panel_name = ViewName.YewaiGuajiView,
		decs_index = 4,
	}
end

function TaskData:GetVirtualXiuLianTask()
	if nil == self.virtual_xiulian_task_cfg then
		self.virtual_xiulian_task_cfg = {
			task_id = 999997,
			task_type = TASK_TYPE.LINK,
			open_panel_name = ViewName.PersonalGoals,
			decs_index = 1,
		}
	end

	return self.virtual_xiulian_task_cfg
end

function TaskData:GetVirtualDaliyTask()
	local task_cfg = ZhiBaoData.Instance:GetFirstTask()
	if nil == self.virtual_daliy_task_cfg then
		self.virtual_daliy_task_cfg = {
			task_id = 999994,
			task_type = TASK_TYPE.DALIY,
			open_panel_name = task_cfg.goto_panel,
			total_num = task_cfg.max_times,
			finish_num = ZhiBaoData.Instance:GetActiveDegreeListBySeq(task_cfg.show_seq),
			des = task_cfg.act_name
		}
	end

	self.virtual_daliy_task_cfg.open_panel_name = task_cfg.goto_panel
	self.virtual_daliy_task_cfg.total_num = task_cfg.max_times
	self.virtual_daliy_task_cfg.des = task_cfg.act_name
	self.virtual_daliy_task_cfg.finish_num = ZhiBaoData.Instance:GetActiveDegreeListBySeq(task_cfg.show_seq)

	return self.virtual_daliy_task_cfg
end

function TaskData:GetVirtualBeGodTask()
	if nil == self.virtual_begold_task_cfg then
		self.virtual_begold_task_cfg = {
			task_id = 999998,
			task_type = TASK_TYPE.LINK,
			open_panel_name = ViewName.MolongMibaoView,
			decs_index = 2,
		}
	end

	return self.virtual_begold_task_cfg
end

function TaskData:GetVirtualLingTask()
	if nil == self.virtual_ling_task_cfg then
		local other_cfg = ConfigManager.Instance:GetAutoConfig("jinghuahusong_auto").other[1]

		self.virtual_ling_task_cfg = {
			task_id = 999999,
			task_type = TASK_TYPE.LING,
			commit_npc = other_cfg.commit_npcid
		}
	end

	return self.virtual_ling_task_cfg
end

function TaskData:GetVirtualGuaJiBossTask()
	if nil == self.virtual_guajiboss_task_cfg then
		self.virtual_guajiboss_task_cfg = {
			task_id = 1000000,
			task_type = TASK_TYPE.GUAJIBOSS,
			open_panel_name = ViewName.YewaiGuajiView,
		}
	end

	return self.virtual_guajiboss_task_cfg
end

-- 获取任务场景ID 如果target_obj.scene没有 就取commit_npc.scene
function TaskData:GetSceneId(task_id)
	local config = self:GetTaskConfig(task_id)
	local scene_id = 0
	if config then
		if config.target_obj and config.target_obj[1] then
			scene_id = config.target_obj[1].scene
		elseif config.commit_npc then
			scene_id = config.commit_npc.scene
		end
	end
	return scene_id
end

-- 获得任务进程的完成数量
function TaskData:GetProgressNum(task_id)
	return nil ~= self.accepted_info_list[task_id] and self.accepted_info_list[task_id].progress_num or 0
end

-- 获得快速完成任务的单价
function TaskData:GetQuickPrice(task_type)
	if task_type == TASK_TYPE.GUILD then
		return self.task_cfg_other.guild_task_gold
	elseif task_type == TASK_TYPE.RI then
		return self.task_cfg_other.daily_double_gold
	elseif task_type == TASK_TYPE.HUAN then
		return self.task_cfg_other.one_task_need_gold
	else
		return 0
	end
end

-- 获得任务剩余次数
function TaskData:GetTaskCount(task_type)
	local commit_count = 0
	local max_count = 0
	if task_type == TASK_TYPE.RI then
		max_count = MAX_DAILY_TASK_COUNT
		commit_count = DayCounterData.Instance:GetRealDayCount(DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT) or max_count
	elseif task_type == TASK_TYPE.GUILD then
		max_count = self:GetMaxGuildTaskCount()
		commit_count = DayCounterData.Instance:GetRealDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) or max_count
	elseif task_type == TASK_TYPE.HUAN then
		max_count = self:GetMaxPaohuanTaskCount()
		commit_count = self.paohuan_task_info.commit_times or max_count
	elseif task_type == TASK_TYPE.WEEK_HUAN then
		max_count = self:GetMaxWeekPaoHuanTaskCount()
		commit_count = self.week_paohuan_task_info and self.week_paohuan_task_info.complete_times or max_count
	end
	return max_count - commit_count
end

--获得任务当前次数
function TaskData:GetTaskCurrentCount(task_type)
	local commit_count = 0
	if task_type == TASK_TYPE.RI then
		commit_count = DayCounterData.Instance:GetRealDayCount(DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT) or 0
	elseif task_type == TASK_TYPE.GUILD then
		commit_count = DayCounterData.Instance:GetRealDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) or 0
	elseif task_type == TASK_TYPE.HUAN then
		commit_count = self.paohuan_task_info.commit_times or 0
	elseif task_type == TASK_TYPE.WEEK_HUAN then
		commit_count = self.week_paohuan_task_info and self.week_paohuan_task_info.complete_times or 0
	end
	return commit_count
end

--周常任务最大次数
function TaskData:GetMaxWeekPaoHuanTaskCount()
	return 300
end

-- 跑环任务最大次数
function TaskData:GetMaxPaohuanTaskCount()
	return 20
end

-- 公会任务最大次数
function TaskData:GetMaxGuildTaskCount()
	-- local guild_task_cfg = self:GetNextGuildTaskConfig()
	-- if guild_task_cfg then
	-- 	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("tasklist_auto").guild_task_list) do
	-- 		if guild_task_cfg.task_id >= v.first_task and guild_task_cfg.task_id <= v.end_task then
	-- 			return v.end_task - v.first_task + 1
	-- 		end
	-- 	end
	-- end

	if not self.guild_task_info.guild_task_max_count then
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		return role_level >= self:GetGuildTaskMaxCountLimit() and 10 or 5
	end

	if self.guild_task_info.guild_task_max_count <= 0 then
		return 10
	end

	return self.guild_task_info.guild_task_max_count
end

function TaskData:GetGuildTaskMaxCountLimit()
	return self.task_cfg_other.guild_task_special_count_limit_level
end

function TaskData:GetQuickCompletionMinLevel()
	return self.task_cfg_other.skip_paohuan_task_limit_level
end
-- 获得今日已完成的任务数量
function TaskData:GetCompletedTaskCountByType(task_type)
	if not task_type then return 0 end
	local count = 0
	if self.completed_list then
		for k,v in pairs(self.completed_list) do
			local config = self:GetTaskConfig(k)
			if config then
				if config.task_type == task_type then
					count = count + 1
				end
			end
		end
	end
	return count
end

-- 得到一个未完成的任务
function TaskData:GetRandomTaskIdByType(task_type)
	if not task_type then return 0 end
	local task_id = 0
	if self.accepted_info_list then
		for k,v in pairs(self.accepted_info_list) do
			local config = self:GetTaskConfig(k)
			if config then
				if config.task_type == task_type then
					task_id = k
					break
				end
			end
		end
	end
	return task_id
end

-- 得到任务结束时间
function TaskData:GetTaskEndTime(task_id)
	if self.accepted_info_list then
		local info = self.accepted_info_list[task_id]
		if info then
			local time = self:GetTaskTotalTime(task_id)
			if time > 0 then
				return info.accept_time + time
			end
		end
	end
end

-- 得到任务的时间(秒)
function TaskData:GetTaskTotalTime(task_id)
	if task_id == 24001 then -- 护送
		return 900
	else
		return 0
	end
end

-- 任务总数量
function TaskData:GetTaskTotalCount(task_type)
	task_type = 4
	local count = 0
	local task_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in pairs(self.task_cfg_list) do
		if v.task_type == task_type then
			if v.min_level <= role_level and role_level <= v.max_level then
				 count = count + 1
			end
		end
	end
	return count
end

-- 默认是工会
function TaskData:GetTaskReward(task_type)
	local  task_type = task_type or TASK_TYPE.GUILD
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if task_type == TASK_TYPE.RI then
		for k, v in pairs(self.daliy_task_reward_cfg) do
			if v.level_max >= role_level and role_level >= v.level then
				return v
			end
		end
	elseif task_type == TASK_TYPE.GUILD then
		for k, v in pairs(self.guild_task_reward_cfg) do
			if v.level == role_level then
				return v
			end
		end
	end
end

--获取任务奖池
function TaskData:GetTaskRewardRoll(task_type)
	return self.task_reward_roll_cfg[task_type]
end

function TaskData:GetGuildTaskReward()
	return self.task_cfg_other.guild_task_complete_all_reward_item
end

function TaskData:SetDailyTaskInfo(protocol)
	local event_type = "no_complete_daily"
	if protocol.commit_times == 10 then
		event_type = "complete_daily"
	end
	self.daily_task_info = protocol
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, event_type, protocol.commit_times)
	TaskData.DoDailyTaskTime = 0
end

function TaskData:GetDailyTaskInfo()
	return self.daily_task_info
end

function TaskData:SetGuildTaskInfo(protocol)
	local event_type = "no_complete_guild"
	if protocol.is_finish == 1 then
		event_type = "complete_guild"
	end
	self.guild_task_info = protocol
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, event_type, TASK_TYPE.GUILD)
	TaskData.DoGuildTaskTime = 0
end

function TaskData:GetGuildTaskInfo()
	return self.guild_task_info or {}
end

function TaskData:SetPaohuanTaskInfo(protocol)
	local event_type = protocol.notify_reason
	self.paohuan_task_info = protocol
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, event_type, TASK_TYPE.HUAN)
end

function TaskData:GetPaohuanTaskInfo()
	return self.paohuan_task_info
end

function TaskData:SetWeekPaohuanTaskInfo(protocol)
	self.week_paohuan_task_info = {}
	self.week_paohuan_task_info.notify_reason = protocol.notify_reason				-- 通知原因
	self.week_paohuan_task_info.complete_times = protocol.complete_times			-- 提交任务次数
	self.week_paohuan_task_info.is_accept = protocol.is_accept						-- 任务是否已经被接受
	self.week_paohuan_task_info.task_id = protocol.task_id							-- 任务id
end

function TaskData:GetWeekPaohuanTaskInfo()
	return self.week_paohuan_task_info
end

function TaskData:GetCurrentChapterCfg()
	local chapter_cfg = nil
	for i,v in ipairs(self.chapter_cfg_list) do
		if not self:GetTaskIsCompleted(v.end_taskid) then
			chapter_cfg = v
			break
		end
	end

	return chapter_cfg
end

function TaskData:GetTaskArrowKazhuxian()
	return self.task_arrow_kazhuxian
end

function TaskData:SetTaskArrowKazhuxian(is_kazhuxian)
	self.task_arrow_kazhuxian = is_kazhuxian
end

--收集红装支线
function TaskData.IsRedFashionTask(task_id)
	return task_id >= 18000 and task_id <= 19000
end

--箭头支线
function TaskData.IsArrowZhiTask(task_id)
	return task_id == 17005 or task_id == 17007 or task_id == 17009
end

--正常支线
function TaskData.IsZhiTask(info)
	return info.task_type == TASK_TYPE.ZHI and not TaskData.IsRedFashionTask(info.task_id)
end

--正常支线
function TaskData:ShowWeatherEff(task_id)
	local scene_id = Scene.Instance:GetSceneId()
	if self.open_effect_cfg[scene_id] then
		for k,v in pairs(self.open_effect_cfg[scene_id]) do
			if v.open_task_id <= task_id and (v.close_task_id == "" or v.close_task_id >= task_id) then
				return true, v.bundle, v.asset, v.voice
			end
		end
	end
	return false
end

--任务转盘奖品
function TaskData:SetRewardRollInfo(protocol)
	self.reward_roll_info = protocol
end

function TaskData:GetRewardRollInfo()
	return self.reward_roll_info.list
end

function TaskData:GetRewardRollList(task_type)
	if self.reward_roll_info.list then
		local list = {}
		for i=1, self.reward_roll_info.count do
		 	local reward = self:GetTaskRewardRoll(task_type)[self.reward_roll_info.list[i].index + 1]
		 	if reward then
		 		table.insert(list, reward.item)
		 	end
		end
	 	return list
	end
	return nil
end

--获取转盘几轮显示一次
function TaskData:GetRewardRollCountShow()
	return self.task_cfg_other.task_interva_jackpot
end


