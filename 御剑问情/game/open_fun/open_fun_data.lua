-- IOS审核屏蔽的模块
local IOS_SHIELD_LIST = {}

OpenFunData = OpenFunData or BaseClass()
function OpenFunData:__init()
	if OpenFunData.Instance then
		print_error("[OpenFunData] Attemp to create a singleton twice !")
	end
	OpenFunData.Instance = self
	self.notice_other_cfg = ConfigManager.Instance:GetAutoConfig("notice_auto").other[1]
	self.notice_list = ConfigManager.Instance:GetAutoConfig("notice_auto").notice_list
	self.notice_day_cfg = ConfigManager.Instance:GetAutoConfig("notice_auto").notice_day
	self.notice_day_name_cfg = ListToMap(self.notice_day_cfg, "fun_name")

	self.cache_name_single_map = {}
	self.trailer_last_reward_id = 0
	self.day_trailer_last_reward_id = 0

	local ios_shield = Split(GLOBAL_CONFIG.param_list.ios_shield, "#")
	for k,v in ipairs(ios_shield) do
		IOS_SHIELD_LIST[tonumber(v)] = true
	end

	self.is_open_fun_map = {}

	self.parent_fun_map = {}
	self:InitParentFunMap()
end

function OpenFunData:__delete()
	OpenFunData.Instance = nil
end

--初始化父级功能开启列表
function OpenFunData:InitParentFunMap()
	local fun_open_cfg_list = self:OpenFunCfg()
	for k, v in pairs(fun_open_cfg_list) do
		if v.parent_fun and v.parent_fun ~= "" then
			if self.parent_fun_map[v.parent_fun] == nil then
				self.parent_fun_map[v.parent_fun] = {}
			end

			self.parent_fun_map[v.parent_fun][v.name] = -1
		end
	end
end

function OpenFunData:OpenFunCfg()
	return ConfigManager.Instance:GetAutoConfig("funopen_auto").funopen_list
end

function OpenFunData:GetCurTrailerCfg()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in ipairs(self.notice_list) do
		if OpenFunData.Instance:GetTrailerLastRewardId() < v.id or (level >= v.start_level and level < v.end_level) then
			return v
		end
	end
	return nil
end

function OpenFunData:GetSingleCfg(name)
	local cfg = self.cache_name_single_map[name]
	if nil ~= cfg then
		return cfg
	end

	for k,v in pairs(self:OpenFunCfg()) do
		if v.name == name or TabIndex[v.name] == name then
			self.cache_name_single_map[name] = v

			return v
		end
	end

	return nil
end

function OpenFunData:ChangeFunOpenMap(name, is_unlock)
	if type(name) ~= "string" or name == "" then
		return
	end

	self.is_open_fun_map[name] = is_unlock or false
end

--获取功能是否开启
function OpenFunData:FunIsUnLock(name)
	if type(name) ~= "string" or name == "" then
		return false
	end

	if nil == self.is_open_fun_map[name] then
		self.is_open_fun_map[name] = self:CheckIsHide(name)
	end

	return self.is_open_fun_map[name]
end

--这里的is_hide的意思是反义(就是是否显示的意思)
function OpenFunData:CheckIsHide(name)
	--处理父级功能开启的情况
	if name and self.parent_fun_map[name] then
		return self:GetParentFunIsUnLock(name)
	end

	local single_cfg = self:GetSingleCfg(name)
	if single_cfg == nil then
		return true, ""
	end

	-- 是否IOS屏蔽
	if IS_AUDIT_VERSION and (single_cfg.ios_shield == 2 or (single_cfg.ios_shield == 1 and IOS_SHIELD_LIST[single_cfg.ios_shield_index])) then
		return false, ""
	end

	--龙行天下特殊处理
	if name == ViewName.LongXingView then
		return not LongXingData.Instance:IsFinishLongXing(), ""
	end

	-- 是否关闭功能（用于达到某些条件就关闭功能）
	local is_close = self:IsCloseFun(single_cfg)
	if is_close then
		return false, ""
	end

	local is_open, tips = self:IsOpenFun(single_cfg)
	-- 这里必须判断是否等于nil
	if nil ~= is_open then
		--设置父级节点功能开启
		self:UpDateParentFunOpen(single_cfg, is_open)

		return is_open, tips
	end

	return true, ""
end

function OpenFunData:UpDateParentFunOpen(single_cfg, is_open)
	local parent_fun_name = single_cfg.parent_fun
	if not parent_fun_name or parent_fun_name == "" then
		return
	end

	self.parent_fun_map[parent_fun_name][single_cfg.name] = is_open and 1 or 0
end

function OpenFunData:GetParentFunIsUnLock(name)
	if not name or nil == self.parent_fun_map[name] then
		return false
	end

	for k, v in pairs(self.parent_fun_map[name]) do
		if v == -1 then
			--代表没判断过功能开启
			local is_open = self:FunIsUnLock(k)
			self.parent_fun_map[name][k] = is_open and 1 or 0
			if is_open then
				return true
			end
		elseif v == 1 then
			return true
		end
	end

	return false
end

function OpenFunData:IsOpenFun(single_cfg)
	if single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.ACHIEVE_TASK then
		return self:InitByAcceptedTask(single_cfg.trigger_param)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.SUBMIT_TASK then
		return self:InitBySubmitTask(single_cfg.trigger_param, single_cfg.task_level)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.UPGRADE then
		return self:InitByUpgrade(single_cfg.trigger_param)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.PERSON_CHAPTER then
		return self:InitByPersonChapter(single_cfg.trigger_param, single_cfg.name)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.SERVER_DAY then
		return self:InitByServerDay(single_cfg.name)
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.DEPEND_ON_SERVER_DAY then
		return self:InitByOpenServerDay(single_cfg.trigger_param, single_cfg.task_level)
	end
end

function OpenFunData:IsCloseFun(single_cfg)
	if nil == single_cfg or single_cfg.close_trigger_type == "" or single_cfg.close_trigger_param == "" then
		return false
	end
	if single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.ACHIEVE_TASK then
		return self:InitByAcceptedTask(single_cfg.close_trigger_param)
	elseif single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.SUBMIT_TASK then
		return self:InitBySubmitTask(single_cfg.close_trigger_param, single_cfg.task_level)
	elseif single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.UPGRADE then
		return self:InitByUpgrade(single_cfg.close_trigger_param)
	elseif single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.PERSON_CHAPTER then
		return self:InitByPersonChapter(single_cfg.close_trigger_param, single_cfg.name)
	elseif single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.SERVER_DAY then
		return self:InitByServerDay(single_cfg.name)
	elseif single_cfg.close_trigger_type == OPEN_FUN_TRIGGER_TYPE.DEPEND_ON_SERVER_DAY then
		return self:InitByOpenServerDay(single_cfg.close_trigger_param, single_cfg.task_level)
	end

	return false
end

--初始化判断是否达到接受任务条件
function OpenFunData:InitByAcceptedTask(trigger_param)
	local task_data = TaskData.Instance
	if task_data:GetTaskCompletedList()[trigger_param] == 1 then
		return true, ""
	end

	if nil == task_data:GetTaskAcceptedInfoList()[trigger_param] then
		local task_info = task_data:GetTaskConfig(trigger_param)
		local tips = ""
		if task_info then
			tips = string.format(Language.Common.FunOpenTaskLevelLimit, task_info.task_name)
		end

		return false, tips
	end

	return true, ""
end

--初始化判断是否达到提交任务条件
function OpenFunData:InitBySubmitTask(trigger_param, task_level)
	local list = TaskData.Instance:GetTaskCompletedList()
	if list[trigger_param] ~= 1 then
		local task_info = TaskData.Instance:GetTaskConfig(trigger_param)
		local tips = ""
		if task_info then
			tips = string.format(Language.Common.FunOpenTaskLevelLimit, PlayerData.GetLevelString(task_level or 0))
		end
		return false, tips
	end
	return true, ""
end

--初始化判断是否达到等级条件
function OpenFunData:InitByUpgrade(trigger_param)
	if GameVoManager.Instance:GetMainRoleVo().level < trigger_param then
		local level_des = PlayerData.GetLevelString(trigger_param)
		local tips = string.format(Language.Common.FunOpenRoleLevelLimit, level_des)
		return false, tips
	end
	return true, ""
end

-- 初始化判断是否完成章节
function OpenFunData:InitByPersonChapter(trigger_param, name)
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cur_chapter = PersonalGoalsData.Instance:GetOldChapter()
	if cur_chapter < trigger_param and (name ~= "CollectGoals" or server_open_day <= 4) then
		local tips = string.format(Language.Common.FunopenPersonChapterLimit, trigger_param)
		return false, tips
	end
	return true, ""
end

-- 初始化判断是否达到开服天数条件
function OpenFunData:InitByServerDay(name)
	local notice_cfg_info = self.notice_day_name_cfg[name]
	if notice_cfg_info and notice_cfg_info.id <= self.day_trailer_last_reward_id then
		return true, ""
	end

	return false, ""
end

function OpenFunData:OnTheTrigger(trigger_type, trigger_param)
	local cfg = self:OpenFunCfg()
	local list = {}
	for k,v in pairs(cfg) do
		if v.trigger_type == trigger_type and v.trigger_param == trigger_param then
			list[#list + 1] = v
		end
	end
	return list
end

function OpenFunData:GetName(open_param)
	local list = Split(open_param, "#")
	if #list == 2 then
		return list[1]
	else
		return open_param
	end
end

function OpenFunData:GetTrailerLastRewardId()
	return self.trailer_last_reward_id
end

function OpenFunData:SetTrailerLastRewardId(id)
	self.trailer_last_reward_id = id
end

function OpenFunData:SetDayTrailerLastRewardId(id)
	self.day_trailer_last_reward_id = id
end

--是否等待功能预告奖励领取消息
function OpenFunData:SetIsWaitDayRewardChange(state)
	self.iswait_day_reward_change = state
end

function OpenFunData:GetIsWaitDayRewardChange()
	return self.iswait_day_reward_change
end

function OpenFunData:GetDayTrailerLastRewardId()
	return self.day_trailer_last_reward_id
end

--获取当前的天数功能预告数据
function OpenFunData:GetNowDayOpenTrailerInfo()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	local trailer_info = nil
	for k, v in ipairs(self.notice_day_cfg) do
		if k > self.day_trailer_last_reward_id then
			--除了当天可领取的功能预告外，其他情况都显示明天的功能预告
			if v.open_day == open_server_day and main_role_vo.level >= v.level_limit then
				trailer_info = v
				break
			elseif v.open_day == open_server_day + 1 then
				trailer_info = v
				break
			end
		end
	end

	return trailer_info
end

--根据功能开启名字获取天数功能预告
function OpenFunData:GetDayOpenTrailerInfoByFunName(fun_name)
	return self.notice_day_name_cfg[fun_name]
end

function OpenFunData:GetNoticeOtherCfg()
	return self.notice_other_cfg
end

--获得跨服六界功能开启等级
function OpenFunData:GetKuaFuBattleOpenLevel()
	if self:OpenFunCfg() and self:OpenFunCfg().kf_battle then
		return self:OpenFunCfg().kf_battle.trigger_param or 1
	end
	return 1
end

--检查排行榜是否开启
function OpenFunData:CheckRankingIsOpen()
	if self:OpenFunCfg() and self:OpenFunCfg().ranking then
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		if role_level >= self:OpenFunCfg().ranking.trigger_param then
			return true
		end
	end
	return false
end

-- 返回1代表没有设置功能开启等级
function OpenFunData:GetOpenLevel(name)
	local single_cfg = self:GetSingleCfg(name)

	if single_cfg == nil then
		return 1
	end

	if single_cfg.trigger_type ~= OPEN_FUN_TRIGGER_TYPE.UPGRADE then
		return 1
	end

	if single_cfg.trigger_param then
		return single_cfg.trigger_param
	end

	return 1
end

function OpenFunData:InitByOpenServerDay(day, task_level)
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	if open_day >= day then
		local flag, tips = self:InitByUpgrade(task_level)
		return flag, tips
	end

	return false
end