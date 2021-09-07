OPEN_FUN_TRIGGER_TYPE =
{
	ACHIEVE_TASK = 1,		--接受任务后
	SUBMIT_TASK = 2,		--提交任务后
	UPGRADE = 3,			--升级后
	PERSON_CHAPTER = 5,		-- 个人目标章节
	JUNXIAN_TASK = 6,		-- 军衔等级
	LEVEL_OPEN_DAY = 7,		-- 等级以及开服天数（参数：等级|天数）
}

OPEN_FLY_DICT_TYPE =
{
	UP = 1,					--上
	BOTTOM = 2,				--下
	OTHER = 3,				--其他
}
OpenFunData = OpenFunData or BaseClass()
function OpenFunData:__init()
	if OpenFunData.Instance then
		print_error("[OpenFunData] Attemp to create a singleton twice !")
	end
	OpenFunData.Instance = self
	self.notice_list = ConfigManager.Instance:GetAutoConfig("notice_auto").notice_list
	--self.notice_list_cfg = ListToMap(self:GetBeautyCfg().self.notice_list, "start_level", "end_level")
	-- self.fun_open_list_cfg = ListToMap(self:OpenFunCfg(), "name")
	--self.Trigger_list_cfg = ListToMapList(self:OpenFunCfg(), "trigger_type", "trigger_param")

	self.cache_name_single_map = {}
	self.trailer_last_reward_id = 0
	self.now_camp = nil
end

function OpenFunData:__delete()
	OpenFunData.Instance = nil
end

function OpenFunData:OpenFunCfg()
	return ConfigManager.Instance:GetAutoConfig("funopen_auto").funopen_list
end

function OpenFunData:GetCurTrailerCfg()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local last_id = OpenFunData.Instance:GetTrailerLastRewardId()

	return self.notice_list[last_id + 1] or nil

	-- for k,v in pairs(self.notice_list) do
	-- 	if OpenFunData.Instance:GetTrailerLastRewardId() < v.id or (level >= v.start_level and level < v.end_level) then
	-- 		return v
	-- 	end
	--  end
	-- return nil
end

function OpenFunData:GetSingleCfg(name)
	if self.now_camp == nil or self.now_camp == 0 then
		self.now_camp = GameVoManager.Instance:GetMainRoleVo().camp or 1
	else
		if self.now_camp ~= GameVoManager.Instance:GetMainRoleVo().camp then
			self.cache_name_single_map = {}
			self.now_camp = GameVoManager.Instance:GetMainRoleVo().camp
		end
	end

	local cfg = self.cache_name_single_map[name]
	if nil ~= cfg then
		return cfg
	end

	local cfg = self:OpenFunCfg()
	local open_cfg = cfg[name]

	if open_cfg ~= nil then
		if open_cfg.name == name or TabIndex[open_cfg.name] == name then
			local task_cfg = self:GetSingleCfgOnTask(open_cfg)
			self.cache_name_single_map[name] = task_cfg
			return task_cfg
		end
	else
		for k,v in pairs(cfg) do
			if v.name == name or TabIndex[v.name] == name then
				local task_cfg = self:GetSingleCfgOnTask(v)
				self.cache_name_single_map[name] = task_cfg
				return task_cfg
			end
		end
	end

	return nil
end

function OpenFunData:GetSingleCfgOnTask(open_cfg)
	local check_data = TableCopy(open_cfg)
	local test_cfg = check_data
	if test_cfg ~= nil then
		if test_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.ACHIEVE_TASK 
			or test_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.SUBMIT_TASK 
			or test_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.JUNXIAN_TASK then
			local trigger_param_t = Split(test_cfg.trigger_param, "|")

			local camp = GameVoManager.Instance:GetMainRoleVo().camp or 1
			if trigger_param_t ~= nil and tonumber(trigger_param_t[camp]) ~= nil then
				test_cfg.trigger_param = tonumber(trigger_param_t[camp])
			end
		end
	end
	return test_cfg
end

function OpenFunData:CheckIsHide(name)
	local single_cfg = self:GetSingleCfg(name)
	if single_cfg == nil then
		return true
	end

	-- 是否IOS屏蔽
	if single_cfg.ios_shield == 1 and IS_AUDIT_VERSION then
		return false
	end

	if single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.ACHIEVE_TASK then
		return self:InitByAcceptedTask(single_cfg.trigger_param)
		
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.SUBMIT_TASK then
		return self:InitBySubmitTask(single_cfg.trigger_param, single_cfg.task_level)
		
	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.UPGRADE then
		if tonumber(single_cfg.trigger_param) == nil then
			return false
		end
		return self:InitByUpgrade(single_cfg.trigger_param)

	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.PERSON_CHAPTER then
		return self:InitByPersonChapter(single_cfg.trigger_param, single_cfg.name)

	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.JUNXIAN_TASK then
		return self:InitByJunXian(single_cfg.trigger_param)

	elseif single_cfg.trigger_type == OPEN_FUN_TRIGGER_TYPE.LEVEL_OPEN_DAY then
		return self:InitByLevelAndOpenDay(single_cfg.trigger_param)

	end
	return false
end

--初始化判断是否达到接受任务条件
function OpenFunData:InitByAcceptedTask(trigger_param)
	local task_data = TaskData.Instance
	local read_param = trigger_param
	if tonumber(trigger_param) == nil then
	    local trigger_param_t = Split(trigger_param, "|")
	    local camp = GameVoManager.Instance:GetMainRoleVo().camp or 1
	    if trigger_param_t ~= nil and tonumber(trigger_param_t[camp]) ~= nil then
	      	read_param = tonumber(trigger_param_t[camp])
	    end
	end

	if task_data:GetTaskCompletedList()[read_param] == 1 then
		return true
	end

	if nil == task_data:GetTaskAcceptedInfoList()[read_param] then
		local task_info = task_data:GetTaskConfig(read_param)
		local tips = ""
		if task_info then
			tips = string.format(Language.Common.FunOpenTaskLevelLimit1, task_info.min_level, task_info.task_name)
		end
		return false, tips
	end
	return true
end

--初始化判断是否达到提交任务条件
function OpenFunData:InitBySubmitTask(trigger_param, task_level)
	local list = TaskData.Instance:GetTaskCompletedList()
	if list[tonumber(trigger_param)] ~= 1 then 
		local task_info = TaskData.Instance:GetTaskConfig(trigger_param)
		local tips = ""
		if task_info then
			tips = string.format(Language.Common.FunOpenTaskLevelLimit2, PlayerData.GetLevelString(task_level or 0))
		end
		return false, tips
	end
	return true
end

--初始化判断是否达到等级条件
function OpenFunData:InitByUpgrade(trigger_param)
	if GameVoManager.Instance:GetMainRoleVo().level < trigger_param then
		local lv, zhuan = PlayerData.GetLevelAndRebirth(trigger_param)
		local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
		local tips = string.format(Language.Common.FunOpenRoleLevelLimit, level_des)
		return false, tips
	end
	return true
end

-- 初始化判断是否完成章节
function OpenFunData:InitByPersonChapter(trigger_param, name)
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cur_chapter = PersonalGoalsData.Instance:GetOldChapter()
	if cur_chapter < trigger_param and (name ~= "CollectGoals" or server_open_day <= 4) then
		local tips = string.format(Language.Common.FunopenPersonChapterLimit, trigger_param)
		return false , tips
	end
	return true
end

-- 判断是否达到军衔等级
function OpenFunData:InitByJunXian(trigger_param)
	local cur_level = MilitaryRankData.Instance:GetCurLevel()
	local cur_name = MilitaryRankData.Instance:GetLevelSingleCfg(trigger_param).name
	if cur_level < trigger_param then
		local tips = string.format(Language.Common.FunopenJunXianLimit, cur_name)
		return false, tips
	end
	return true
end

-- 判断等级以及开服天数
function OpenFunData:InitByLevelAndOpenDay(trigger_param)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if IS_ON_CROSSSERVER then
		open_day = PlayerData.Instance:GetOriginOpenDay()
	end
	if tonumber(trigger_param) == nil then
		local param_t = Split(trigger_param, "|")
		local cfg_level = tonumber(param_t[1]) or 0
		if cfg_level > role_level then
			local tips = string.format(Language.Common.FunOpenRoleLevelLimit, cfg_level)
			return false, tips
		end
		local cfg_day = tonumber(param_t[2]) or 0
		if cfg_day > open_day then
			local tips = string.format(Language.Common.OpenDayNotEnough, cfg_day)
			return false, tips
		end
	end
	return true
end

function OpenFunData:OnTheTrigger(trigger_type, trigger_param)
	local cfg = self:OpenFunCfg()
	local list = {}
	for k,v in pairs(cfg) do
		if v.trigger_type == trigger_type and v.trigger_param == trigger_param then
			list[#list + 1] = v
		end
	end

	-- if self.Trigger_list_cfg[trigger_type] then
	-- 	list[#list + 1] = self.Trigger_list_cfg[trigger_type][trigger_param]
	-- end

	return list
end

function OpenFunData:GetFlyDic(parent_name, name)
	if parent_name == "ButtonGroup1" or parent_name == "ButtonGroup2" or parent_name == "ButtonGroup3" then
		if name ~= "ButtonDeposit" and name ~= "ButtonInvest" and name ~= "ButtonRebate" and name ~= "ButtonFirstCharge" then
			return OPEN_FLY_DICT_TYPE.UP
		else
			return OPEN_FLY_DICT_TYPE.OTHER
		end
	elseif parent_name == "ButtonGroup" or parent_name == "ButtonGroupLeft" then
		return OPEN_FLY_DICT_TYPE.BOTTOM
	else
		return OPEN_FLY_DICT_TYPE.OTHER
	end
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


