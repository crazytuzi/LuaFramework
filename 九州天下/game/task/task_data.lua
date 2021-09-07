TaskData = TaskData or BaseClass()

-- 任务状态
TASK_STATUS = {
	NONE = 0, 										-- 没有任务
	CAN_ACCEPT = 1,									-- 有可接任务
	ACCEPT_PROCESS = 2,								-- 有未完成的任务
	COMMIT = 3,										-- 有可提交任务
}

SPECIAL_TASK_STATUS = {
	DALIY_TASK_CAN_ACCEPT = 5,						-- 日常任务可接受
	DALIY_TASK_COMMIT = 3,							-- 日常任务可提交
	CAMP_WAR_CAN_ACCEPT = 6,						-- 国家战事任务可接受
	CAMP_WAR_COMMIT = 7,							-- 国家战事任务可提交
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
	-- DALIY = 7,										-- 每日任务
	JUN = 7,										-- 军衔任务
	
	GUAJI = 10,										-- 挂机任务
	LING = 11,										-- 护送灵石
	LINK = 12,										-- 打开面板

	-- 客户端自定义任务类型
	YINGJIU = 100,									-- 国家战事 - 营救
	CITAN = 101,									-- 刺探任务
	BANZHUAN = 102,									-- 搬砖任务
	ZHIBAO = 103,									-- 每日必做

	KILLROLE = 200,									-- 杀人任务
}

-- 任务完成条件
TASK_COMPLETE_CONDITION = {
	NPC_TALK = 0, 									-- npc对话
	KILL_MONSTER = 1, 								-- 打怪
	GATHER = 2, 									-- 采集
	PASS_FB = 3, 									-- 完成副本
	ENTER_SCENE = 4, 								-- 进入场景
	COMPLETE_TASK = 5, 								-- 提交任务
	NOTHING = 6, 									-- 无需操作
	DO_OPERATOR = 7,								-- 执行某种操作
	SATISFY_STATUS = 8,								-- 满足某种状态
	ENTER_SCENE_TYPE = 9,							-- 进入某种场景类型
	PICKUP_ITEM = 10,								-- 拾取某种物品
	KILL_BOSS_TYPE = 11,							-- 击杀某种怪物类型
	PASS_FB_LAYER = 12,								-- 副本通关到X层
	PASS_SPECIAL_TASK = 13,							-- 特殊任务，客户端发协议告诉完成
	MULTI_TALK_NPC = 14,							-- 和多个NPC对话
}
-- TASK_ACCEPT_OP.HOLD_BEAUTY
-- 任务接受后做的事
TASK_ACCEPT_OP = {
	-- 1- 6服务器在用
	ENTER_FB = 7,									-- 进入副本
	OPEN_GUIDE_FB_ENTRANCE = 8,						-- 打开引导副本界面
	ENTER_DAILY_TASKFB = 9,							-- 进入日常任务副本
	HOLD_BEAUTY = 10,								-- 抱美人
	NEW_CHAPTER = 12,								-- 新章节开启
	TASTE_FAMOUS_GENERAL = 13,						-- 体验名将
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

TASK_ID = {
	YUNBIAO = 24001,
}

TASK_MINGJIANG = {470, 5470, 10470}

TASK_CG_MOUNT_DOWN = {
	[370] = true,
	[1370] = true,
	[2370] = true,
}

-- 转生任务指定npcId
TASK_ZHUAN_SHENG_NPC = 564564546
-- 等待可接任务返回

TASK_GUILD_AUTO = false
TASK_RI_AUTO = false

MAX_DAILY_TASK_COUNT = 10

TaskData.DoDailyTaskTime = 60
TaskData.DoGuildTaskTime = 60

IS_HUN_BEAUTY = false 	-- 日常任务抱美人状态

function TaskData:__init()
	if TaskData.Instance then
		print_error("[TaskData] Attemp to create a singleton twice !")
	end
	TaskData.Instance = self

	self.task_cfg_list = ConfigManager.Instance:GetAutoConfig("tasklist_auto").task_list
	self.task_cfg_other = ConfigManager.Instance:GetAutoConfig("tasklist_auto").other[1]
	self.daliy_task_reward_cfg = ConfigManager.Instance:GetAutoConfig("tasklist_auto").daily_task_reward
	self.guild_task_reward_cfg = ConfigManager.Instance:GetAutoConfig("tasklist_auto").guild_task_reward
	self.chapter_cfg_list = ConfigManager.Instance:GetAutoConfig("tasklist_auto").new_task
	self.npc_talk_list = ConfigManager.Instance:GetAutoConfig("npc_talk_list_auto").npc_talk_list

	self.kill_role_cfg = ConfigManager.Instance:GetAutoConfig("kill_role_integration_config_auto")
	self.kill_level_limit = ListToMap(self.kill_role_cfg.kill_role_level_limit, "role_level")
	self.integration_reward = ListToMap(self.kill_role_cfg.integration_reward, "role_level")
	self.task_road_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("tasklist_auto").beauty_road, "task_id") or {}
	self.open_effect_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("tasklist_auto").open_effect or {}, "scene_id")

	self.task_cfg_list_dic = {}						-- 任务配置列表，以任务类型为key, cfg列表为值

	self.virtual_xiulian_task_cfg = nil
	self.virtual_begold_task_cfg = nil
	self.virtual_ling_task_cfg = nil

	self.accepted_info_list = {}					-- 已接任务列表(任务信息参考ProtocolStruct.ReadTaskInfo)
	self.completed_id_list = {}						-- 已完成任务id列表
	self.can_accept_id_list = {}					-- 可接任务id列表
	self.cur_task_id = 0
	self.guild_task_info = {}

	self.task_arrow_kazhuxian = false				-- 是否卡主线任务中
	self.muliti_talk_id = 0							-- 多对话id

	self.send_yingjiu = false

	self:CalcTaskIdListDic()

	--拯救美人任务ID
	self.save_beauty_task_id = {
		[GameEnum.ROLE_CAMP_1] = 220,				--救出弄玉任务ID  齐国任务
		[GameEnum.ROLE_CAMP_2] = 5220,				--救出弄玉任务ID  楚国任务
		[GameEnum.ROLE_CAMP_3] = 10220				--救出弄玉任务ID  魏国任务
	}

	--拯救美人支线任务ID
	self.save_other_beauty_task_id = {
		[GameEnum.ROLE_CAMP_1] = 21016,				--救出美人任务ID  齐国任务
		[GameEnum.ROLE_CAMP_2] = 21017,				--救出美人任务ID  楚国任务
		[GameEnum.ROLE_CAMP_3] = 21018				--救出美人任务ID  魏国任务
	}

	self.hold_beauty_task_id = {
		[GameEnum.ROLE_CAMP_1] = 230,				--抱美人中任务ID  齐国任务
		[GameEnum.ROLE_CAMP_2] = 5230,				--抱美人中任务ID  楚国任务
		[GameEnum.ROLE_CAMP_3] = 10230				--抱美人中任务ID  魏国任务
	}

	--抱美人要隐藏的npc
	self.hold_beauty_npc_id = {
		[GameEnum.ROLE_CAMP_1] = 5011,				
		[GameEnum.ROLE_CAMP_2] = 5211,				
		[GameEnum.ROLE_CAMP_3] = 5411				
	}

	self.is_first_enter = true
end

function TaskData:__delete()
	TaskData.Instance = nil
	self.daliy_task_reward_cfg = {}
	self.guild_task_reward_cfg = {}
	self.guild_task_info = nil
	self.daily_task_info = nil
	self.can_accept_id_list = {}

	self.is_first_enter = false
end

function TaskData:CalcTaskIdListDic()
	for _, v in pairs(self.task_cfg_list) do
		if nil == self.task_cfg_list_dic[v.task_type] then
			self.task_cfg_list_dic[v.task_type] = {}
		end
		if v.task_type == TASK_TYPE.ZHU then
			if nil == self.task_cfg_list_dic[v.task_type][v.camp] then
				self.task_cfg_list_dic[v.task_type][v.camp] = {}
			end
			table.insert(self.task_cfg_list_dic[v.task_type][v.camp], v)			
		else
			table.insert(self.task_cfg_list_dic[v.task_type], v)
		end
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
			or self.task_cfg_list[task_id].task_type == TASK_TYPE.JUN
			or task_id == TASK_ID.YUNBIAO) then
		self.cur_task_id = task_id
	else
		self.cur_task_id = nil
	end
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

function TaskData.IsAutoTaskType(task_type)
	return task_type == TASK_TYPE.ZHU or task_type == TASK_TYPE.RI or task_type == TASK_TYPE.GUILD
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

		self:YunBiaoTaskComplete(data)
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
		
		FlowersCtrl.Instance:PlayerTaskEffect2("effects2/prefab/ui/ui_rwwc_prefab","UI_rwwc")
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
	
	if not ViewManager.Instance:IsOpen(ViewName.TaskChapter) then
		GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, event_type, data.task_id)
	end
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

-- 专属怪物
function TaskData:GetTaskTargetConfig(task_id)
	if nil == task_id then
		return nil
	end

	local data_cfg = ConfigManager.Instance:GetAutoConfig("tasklist_auto").exclusive_monster_task

	local target_obj = nil
	if data_cfg then
		local data = data_cfg[task_id]
		if data then
			target_obj = {}
			local pos_list = Split(data.monster_pos_list, "|")
			for k,v in pairs(pos_list) do
				local pos = Split(v, ",")
				local obj_cfg = {}
				obj_cfg.id = data.monster_id
				obj_cfg.scene = data.scene_id
				obj_cfg.x = pos[1] or 0
				obj_cfg.y = pos[2] or 0
				table.insert(target_obj, obj_cfg)
			end
		end
	end

	return target_obj
end

function TaskData:GetVirtualTaskCfg(task_id)
	if task_id == 999990 then
		return NationalWarfareData.Instance:GetYingJiuInfo()
	elseif task_id == 999991 then
		return NationalWarfareData.Instance:GetBanZhuanTaskCfg()
	elseif task_id == 999992 then
		return NationalWarfareData.Instance:GetCitanTaskCfg()
	elseif task_id == 999993 then
		return WaBaoData.Instance:GetVirtualWaBaoTask()
	elseif task_id == 999995 then
		return self:GetKillTaskInfo()
	elseif task_id == 999996 then
		return self:GetVirtualGuajiTask()
	elseif task_id == 999997 then
		return self:GetVirtualXiuLianTask()
	elseif task_id == 999998 then
		return self:GetVirtualBeGodTask()
	elseif task_id == 999999 then
		return self:GetVirtualLingTask()
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

	local banzhuan_task_cfg = NationalWarfareData.Instance:GetBanZhuanTaskCfg()
	local citan_task_cfg = NationalWarfareData.Instance:GetCitanTaskCfg()

	if banzhuan_task_cfg and next(banzhuan_task_cfg) then
		if NationalWarfareData.Instance:GetIsBanZhuanNpcByCamp(npc_id) then
			task_list[#task_list + 1] = banzhuan_task_cfg
		end
	end

	if citan_task_cfg and next(citan_task_cfg) then
		if NationalWarfareData.Instance:GetIsCiTanNpcByCamp(npc_id) then
			task_list[#task_list + 1] = citan_task_cfg
		end
	end

	for k,v in pairs(self.accepted_info_list) do
		local task_cfg = self:GetTaskConfig(v.task_id)
		if task_cfg and type(task_cfg.commit_npc) == "table" and task_cfg.commit_npc.id == npc_id then
			if task_cfg.task_id == self.cur_task_id then
				return task_cfg
			end
			task_list[#task_list + 1] = task_cfg
		elseif task_cfg and npc_id == task_cfg.a_param1 and task_cfg.accept_op == TASK_ACCEPT_OP.HOLD_BEAUTY then 				--抱美人
			task_list[#task_list + 1] = task_cfg
		elseif task_cfg and task_cfg.task_type == TASK_TYPE.RI then							--日常任务
			local split_param_list = Split(task_cfg.c_param_list or "", "|")
			if type(task_cfg.accept_npc) == "table" and task_cfg.accept_npc.id == npc_id then
				task_list[#task_list + 1] = task_cfg
			elseif task_cfg.condition == TASK_COMPLETE_CONDITION.MULTI_TALK_NPC and split_param_list and npc_id == tonumber(split_param_list[v.progress_num + 1] or 0) then
				task_list[#task_list + 1] = task_cfg
			end
		end
	end

	for k,v in pairs(self.can_accept_id_list) do
		local task_cfg = self:GetTaskConfig(k)
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
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local list = self.task_cfg_list_dic[TASK_TYPE.ZHU][main_role_vo.camp]
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
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local list = self.task_cfg_list_dic[TASK_TYPE.ZHU][main_role_vo.camp]
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

-- 当前任务是否是报美人
function TaskData:GetTaskAcceptedIsBeauty(get_task_id)
	if self.accepted_info_list == nil or next(self.accepted_info_list) == nil then 
		return true
	end

	local beauty_task = {
		[230] = true, [5230] = true, [10230] = true,
		[21013] = true, [21014] = true, [21015] = true
	}

	for k,v in pairs(self.accepted_info_list) do
		if get_task_id then
			if beauty_task[v.task_id] then
				return v.task_id
			end
		elseif v.task_id == 230 or v.task_id == 5230 or v.task_id == 10230 then
			return false
		end
	end
	if get_task_id then
		return false
	else
		return true
	end
end

function TaskData.GetTaskIsBeautyTask(task_id)
	local beauty_task = {
		[230] = true, [5230] = true, [10230] = true,
		[21013] = true, [21014] = true, [21015] = true
	}

	return beauty_task[task_id] or false
end

function TaskData:GetVirtualGuajiTask()
	local mainrole_level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg_list = ConfigManager.Instance:GetAutoConfig("guaji_pos_auto").pos_list
	local cur_cfg = nil

	for i, v in ipairs(cfg_list) do
		if mainrole_level <= v.max_level then
			cur_cfg = v
			break
		end
	end
	if nil == cur_cfg then
		return
	end

	local pos_i = math.random(1, 5)

	return {
		task_id = 999996,
		task_type = TASK_TYPE.GUAJI,
		scene_id = cur_cfg["scene_id_" .. pos_i],
		x = cur_cfg["x_" .. pos_i],
		y = cur_cfg["y_" .. pos_i],
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

-- function TaskData:GetVirtualDaliyTask()
-- 	local task_cfg = ZhiBaoData.Instance:GetFirstTask()
-- 	if nil == self.virtual_daliy_task_cfg then
-- 		self.virtual_daliy_task_cfg = {
-- 			task_id = 999994,
-- 			task_type = TASK_TYPE.DALIY,
-- 			open_panel_name = task_cfg.goto_panel,
-- 			total_num = task_cfg.max_times,
-- 			finish_num = ZhiBaoData.Instance:GetActiveDegreeListBySeq(task_cfg.show_seq),
-- 			des = task_cfg.act_name
-- 		}
-- 	end

-- 	self.virtual_daliy_task_cfg.open_panel_name = task_cfg.goto_panel
-- 	self.virtual_daliy_task_cfg.total_num = task_cfg.max_times
-- 	self.virtual_daliy_task_cfg.des = task_cfg.act_name
-- 	self.virtual_daliy_task_cfg.finish_num = ZhiBaoData.Instance:GetActiveDegreeListBySeq(task_cfg.show_seq)

-- 	return self.virtual_daliy_task_cfg
-- end

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
	end
	return max_count - commit_count
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

function TaskData:GetDiaoQiaoTask(camp)
	local task_cfg = TableCopy(self.task_cfg_other)
	if task_cfg and task_cfg.pingbi_taskid and task_cfg.pingbi_scene then
		local task_list = {}
		local t = Split(task_cfg.pingbi_taskid, "|") or {}
		local t1 = Split(task_cfg.pingbi_scene, "|") or {}
		for i,v in ipairs(t) do
			local vo = {}
			vo.task_id = tonumber(v)
			vo.sence_id = tonumber(t1[i])
			task_list[i] = vo
		end
		return task_list[camp]
	end
end

-- 出现名将的任务
function TaskData:GetMingJiangTask(task_id)
	local task_cfg = self.task_cfg_other
	if task_cfg and task_cfg.mingjiang_taskid then
		local t = Split(task_cfg.mingjiang_taskid, "|") or {}
		for k,v in pairs(t) do
			if task_id == tonumber(v) then
				return true
			end
		end
	end
	return false
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

function TaskData:GetCurrentChapterCfg()
	local chapter_cfg = nil
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	for i,v in ipairs(self.chapter_cfg_list) do
		local id_list = Split(v.end_taskid or "", "|")
		local task_id = tonumber(id_list[main_role_vo.camp]) or 0
		if not self:GetTaskIsCompleted(task_id) and task_id > 0 then
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

--修炼支线
function TaskData.IsXiuLianTask(task_id)
	return task_id == 18001 or task_id == 18002
end

--正常支线
function TaskData.IsZhiTask(info)
	return info.task_type == TASK_TYPE.ZHI and not TaskData.IsXiuLianTask(info.task_id)
end

function TaskData:GetDailyFbCfg()
	return ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").task
end

-- 获取日常任务副本Cfg
function TaskData:GetRiChangFbTaskCfg()
	local list = {}

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	local fuben_info = self:GetDailyTaskInfo()
	local richang_taskfb_cfg = self:GetDailyFbCfg()
	if fuben_info then
		for i,v in ipairs(richang_taskfb_cfg) do
			if fuben_info.task_fb_seq == v.seq and main_role_vo.camp == v.camp_type then
				table.insert(list, v)
			end
		end
	end

	return list
end

-- 获取日常任务场景NPC位置信息
function TaskData:GetRiChangFbNpcCfg()
	local npc_list = {}
	local richang_fbtask_cfg = self:GetRiChangFbTaskCfg()
	if not richang_fbtask_cfg[1] then return end
	local scene_info = ConfigManager.Instance:GetSceneConfig(richang_fbtask_cfg[1].accept_scene_id)
	for i,v in ipairs(scene_info.npcs) do
		if richang_fbtask_cfg[1] and richang_fbtask_cfg[1].accept_npc == v.id then
			table.insert(npc_list, v)
		end
	end
	return npc_list
end

--获取经验副本剩余次数
function TaskData:GetFuBenTasksTimes()
	local day_num = FuBenData.Instance:GetExpDayCount()
	local exp_daily_fb = FuBenData.Instance:GetExpDailyFb()
	if exp_daily_fb[0].enter_item_id then
		local item_count = ItemData.Instance:GetItemNumInBagById(exp_daily_fb[0].enter_item_id)
		local item_info = ItemData.Instance:GetItemConfig(exp_daily_fb[0].enter_item_id)
		local str = string.format(Language.FB.ItemNum,item_count)
		if day_num >= exp_daily_fb[0].enter_day_times then
			day_num = exp_daily_fb[0].enter_day_times
		end
		return exp_daily_fb[0].enter_day_times - day_num
	end
	return 0
end

--获取多个对话NPC任务
function TaskData:GetMultiTalkNpcTask(task_cfg, index)
	if task_cfg == nil then
		return
	end
	index = index or 0

	local scene_x, scene_y, npc_id = 0, 0, 0
	local desc_t = Split(task_cfg.c_param_list or "", "|")
	if #desc_t > 0 then
		desc_t[0] = table.remove(desc_t, 1)
		npc_id = desc_t[index] or 0
		npc_id = tonumber(npc_id)
	end
	local scene_id = task_cfg.c_param1

	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id) or {}
	for k,v in pairs(scene_cfg.npcs) do
		if v.id == npc_id then
			scene_x = v.x
			scene_y = v.y
		end
	end

	local first_target = {scene = scene_id, x = scene_x, y = scene_y,  id = npc_id}
	return first_target
end

function TaskData:CheckIsMultiTalkNpc(npc_id)
	local task = self:GetTaskListIdByType(TASK_TYPE.RI)
	local cfg_npc_id = 0
	for k,v in pairs(task) do
		local task_cfg = self:GetTaskConfig(v)
		local task_info = self:GetTaskInfo(v)
		if task_cfg and task_info then
			local desc_t = Split(task_cfg.c_param_list or "", "|")
			local tali_id_t = Split(task_cfg.accept_dialog or "", "|")
			cfg_npc_id = tonumber(desc_t[task_info.progress_num + 1] or 0)
			if npc_id == cfg_npc_id then
				self.muliti_talk_id = tonumber(tali_id_t[task_info.progress_num + 1] or 0)
				return true
			end
		end
	end
	return false
end

function TaskData:GetMultiTalkId()
	local talk_id = self.muliti_talk_id
	self.muliti_talk_id = 0
	return talk_id
end

--获取国家战事任务剩余次数
function TaskData:GetCampTaskResTimes(task_type)
-- CAMP_TASK_TYPE = {
-- 	CAMP_TASK_TYPE_INVALID = 0,
-- 	CAMP_TASK_TYPE_YUNBIAO = 1,							-- 运镖（逻辑使用原来的护送，即HusongTask）
-- 	CAMP_TASK_TYPE_CITAN = 2,							-- 刺探
-- 	CAMP_TASK_TYPE_YINGJIU = 3,							-- 营救
-- 	CAMP_TASK_TYPE_BANZHUAN = 4,						-- 搬砖

-- 	CAMP_TASK_TYPE_MAX,
-- }
	if task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_YUNBIAO then
		return YunbiaoData.Instance:GetHusongRemainTimes()
	elseif task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_YINGJIU then
		local accept_times, buy_times, max_accept_times = NationalWarfareData.GetYingJiuTimes()
		local vip_times = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_BUY_CAMP_TASK_YINGJIU_TIMES)
		local buy_str = ""
		if (vip_times > buy_times) or (buy_times + max_accept_times - accept_times) > 0 then
			buy_str = buy_times + max_accept_times - accept_times
		end
		return buy_str 
	elseif task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN then
		return	NationalWarfareData.Instance:GetCampCitanDayCount()
	elseif task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN then
		return	NationalWarfareData.Instance:GetCampBanzhuanDayCount()
	end
end

function TaskData:GetTaskIsShowBtn(task_id,task_npc)
	local task_cfg = ConfigManager.Instance:GetAutoConfig("tasklist_auto").task_list
	for k,v in pairs(task_cfg) do
		if v.accept_npc then
			if task_id == v.task_id and task_npc == v.accept_npc.id and v.task_type == TASK_TYPE.RI then
				return true
			end
		end
	end
	return false
end

function TaskData:GetTaskInfoByType(task_type)
	if not task_type then
		return
	end
	local cfg = {}
	for k, v in pairs(self.task_cfg_list) do
		if v.task_type == task_type then
			cfg = v
			break
		end
	end
	return cfg
end

function TaskData:YingJiuTalkChange(enabled)
	self.send_yingjiu = enabled
end

function TaskData:GetYingJiuSendFlag()
	return self.send_yingjiu
end

--根据玩家阵型获取主线营救美人任务的对应ID
function TaskData:GetYingJiuMeirenTaskId()
	return self.save_beauty_task_id[PlayerData.Instance.role_vo.camp] or 0
end

function TaskData:GetHoldMeirenTaskId()
	return self.hold_beauty_task_id[PlayerData.Instance.role_vo.camp] or 0
end

function TaskData:GetHoldMeirenNpcId()
	return self.hold_beauty_npc_id[PlayerData.Instance.role_vo.camp] or 0
end

--根据玩家阵型获取支线营救美人任务的对应ID
function TaskData:GetOtherYingJiuMeirenTaskId()
	return self.save_other_beauty_task_id[PlayerData.Instance.role_vo.camp] or 0
end

--是否是营救美人任务的NPC
function TaskData:IsYingjiuMeirenTaskAcceptNpc(npc_id)
	local task_id = self:GetYingJiuMeirenTaskId()
	local task_cfg = self:GetTaskConfig(task_id)
	if not task_cfg then
		return false 
	end
	if nil == task_cfg.accept_npc or nil == task_cfg.accept_npc.id or task_cfg.accept_npc.id <= 0 then
		return false 
	end
	local is_can_save = npc_id == task_cfg.accept_npc.id and (self:GetCanAcceptTaskInfo(task_id) or self:GetTaskInfo(task_id))	--可接或已接
	return is_can_save
end

function TaskData:IsOtherYingjiuMeirenTaskAcceptNpc(npc_id)
	local task_id = self:GetOtherYingJiuMeirenTaskId()
	local task_cfg = self:GetTaskConfig(task_id)
	local is_can_save = false
	if not task_cfg then
		return false 
	end
	if nil == task_cfg.accept_npc or nil == task_cfg.accept_npc.id or task_cfg.accept_npc.id <= 0 then
		return false 
	end
	local is_can_save = npc_id == task_cfg.accept_npc.id and (self:GetCanAcceptTaskInfo(task_id) or self:GetTaskInfo(task_id))	--可接或已接
	return is_can_save
end

-- 根据当前等级获取日常任务的经验
function TaskData:GetCurLevelDialyExp()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if self.daliy_task_reward_cfg then
		for k,v in pairs(self.daliy_task_reward_cfg) do
			if vo.level >= v.level and vo.level <= v.level_max then
				return v.exp
			end
		end
	end
	return 1
end

-- 根据任务ID获取日常任务配置
function TaskData:GetCurLevelDialyCfg()
	local dialy_task_id = self:GetDailyTaskInfo()
	if dialy_task_id then
		return self.task_cfg_list[dialy_task_id.task_id]
	else
		return {}
	end
end

-- 是否抱美人任务
function TaskData:GetIsHoldBeautyTask(task_id)
	local task_info_list = self:GetTaskAcceptedInfoList()
	for k,v in pairs(task_info_list) do
		if task_id == v.task_id then
			local task_cfg = self:GetTaskConfig(task_id)
			if task_cfg then
				if TASK_ACCEPT_OP.HOLD_BEAUTY == task_cfg.accept_op and "" ~= task_cfg.a_param1 then
					local hold_beauty_npcid = PlayerData.Instance.role_vo.hold_beauty_npcid or 0
					if hold_beauty_npcid <= 0 then --没抱美人状态
						return 1
					else
						return 2
					end
				end
			end
		end
	end
	return false
end

function TaskData:SetKillRoleScoreInfo(protocol)
	self.kill_role_score = protocol.kill_role_score or 0
	self.kill_role_jungong = protocol.kill_role_jungong or 0
	self.kill_role_reward_exp = protocol.kill_role_reward_exp or 0
end

function TaskData:GetKillRoleScore()
	return self.kill_role_score or 0
end

function TaskData:GetKillRoleJunGong()
	return self.kill_role_jungong or 0
end

function TaskData:GetKillTaskInfo()
	local task_info = {}
	local limit_num = 0
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local kill_level_cfg = self:GetKillRoleLevelLimit(PlayerData.Instance.role_vo.level) -- 杀人任务等级上线配置

	if self.kill_role_jungong and kill_level_cfg then
		local limit_num = kill_level_cfg.reward_jungong_limit
		if vip_level >= 8 then
			limit_num = kill_level_cfg.vip8_reward_jungong_limit
		elseif vip_level >= 4 then
			limit_num = kill_level_cfg.vip4_reward_jungong_limit
		else
			limit_num = kill_level_cfg.reward_jungong_limit
		end
	
		task_info.task_type = TASK_TYPE.KILLROLE
		task_info.task_id = 999995
		task_info.task_name = Language.Task.KillTaskName
		task_info.task_desc = string.format(Language.Task.KillTaskDesc, self.kill_role_score, limit_num)
		task_info.kill_role_jungong = self.kill_role_jungong
		task_info.kill_role_reward_exp = self.kill_role_reward_exp
	end
	return task_info
end

-- 杀人任务等级上线配置
function TaskData:GetKillRoleLevelLimit(level)
	if self.kill_level_limit then
		if self.kill_level_limit[level] then
			return self.kill_level_limit[level]
		end
		return self.kill_level_limit[1]
	end
end

-- 杀人任务加积分配置
function TaskData:GetkillRoleFetchIntegration()
	if self.kill_role_cfg then
		return self.kill_role_cfg.kill_role_fetch_integration
	end
end

-- 杀人任务积分奖励配置
function TaskData:GetIntegrationReward(level)
	if self.integration_reward then
		if self.integration_reward[level] then
			return self.integration_reward[level]
		end
		return self.integration_reward[1]
	end
end

-- 设置正在做的日常任务id
function TaskData:SetRichangTaskId(task_id)
	self.richang_task_id = task_id
end

-- 获取正在做的日常任务id
function TaskData:GetRichangTaskId()
	return self.richang_task_id
end

function TaskData:GetTaskId(task_list)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local t = Split(task_list or "", "|")
	return tonumber(t[main_role_vo.camp]) or 0
end

-- 割绳子面板的假任务断掉后的寻路
function TaskData:GetBeautyRoadCfg(task_id)
	local task_cfg = self.task_road_cfg[task_id]
	if task_cfg then
		local target = {}
		target.scene = task_cfg.scene_id or 0
		target.id = task_cfg.npc_id or 0
		target.x = tonumber(task_cfg.x_npc_pos_list) or 0
		target.y = tonumber(task_cfg.y_npc_pos_list) or 0
		return target
	end
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

-- 得到Npc配置表信息
function TaskData:GetNpcListCfg()
	if self.npc_list_cfg == nil then
		self.npc_list_cfg = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list
	end
	return self.npc_list_cfg
end

function TaskData:GetNpcInfoCfgById(npc_id)
	local npc_cfg = self:GetNpcListCfg()
	if npc_cfg and npc_cfg[npc_id] then
		return npc_cfg[npc_id]
	end
	return nil
end

function TaskData.JunXianTaskLimit()
	if PlayerData.Instance.role_vo.hold_beauty_npcid > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Task.JunXianTaskLimit[1])
		return true
	elseif GameVoManager.Instance:GetMainRoleVo().husong_taskid > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Task.JunXianTaskLimit[2])
		return true
	else
		return false
	end
end

-- 运镖假副本结算
function TaskData:YunBiaoTaskComplete(data)
	if data.is_complete == 1 and (data.task_id == 770 or data.task_id == 5770 or data.task_id == 10770) 
		and (not self.is_first_enter or not IS_AUDIT_VERSION) then
		local data = {
			[1] = {item_id = COMMON_CONSTS.VIRTUAL_ITEM_EXP, num = self.task_cfg_list[data.task_id].exp},
			[2] = self.task_cfg_list[data.task_id].item_list[0],
			[3] = {item_id = COMMON_CONSTS.VIRTUAL_ITEM_COIN, num = self.task_cfg_list[data.task_id].coin},
		}
		NationalWarfareCtrl.Instance:ShowEndTip("title_yunbiao", "desc_yunbiao_1", "desc_yunbiao_2", data, "word_color_5", true)
	end
end


function TaskData:GetDailyDoubleGold()
	return self.task_cfg_other.daily_double_gold
end
