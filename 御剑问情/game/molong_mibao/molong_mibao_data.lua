MolongMibaoData = MolongMibaoData or BaseClass()
MolongMibaoData.Chapter = 7
MolongMibaoData.CanRewardCount = 6
MolongMibaoData.OPERATE_TYPE =
	{
		FETCH_REWARD = 0,
		FETCH_INFO = 1,
		FETCH_CHAPTER_REWARD = 2,
	}
local HAS_MOLONG_INFO = false
function MolongMibaoData:__init()
	if MolongMibaoData.Instance then
		ErrorLog("[MolongMibaoData] attempt to create singleton twice!")
		return
	end
	MolongMibaoData.Instance =self
	self.magicalprecious_cfg =  ConfigManager.Instance:GetAutoConfig("magicalprecious_auto")
	self.mibao_list = {}
	for k,v in pairs(self.magicalprecious_cfg.chapter_cfg) do
		self.mibao_list[v.chapter_id] = self.mibao_list[v.chapter_id] or {}
		self.mibao_list[v.chapter_id][v.reward_index + 1] = v
	end
	MolongMibaoData.Chapter = #self.mibao_list + 1
	self.mibao_chapter_flag_t = {}
	for i = 1, MolongMibaoData.Chapter do
		self.mibao_chapter_flag_t[i] = 0
	end
	self.mibao_info = {
		current_chaper = 0,							-- 当前章节
		chapter_invalid_time = 0,					-- 章节失效时间
		chapter_fetch_finish_reward_flag = 0,		-- 章节完成奖励标志
		chapter_fetch_reward_flag = {},				-- 章节奖励标志
		chapter_param = {},
	}
	RemindManager.Instance:Register(RemindName.MoLongMiBao, BindTool.Bind(self.GetMibaoRemind, self))
end

function MolongMibaoData:__delete()
	RemindManager.Instance:UnRegister(RemindName.MoLongMiBao)
	if self.redpt_timer then
		GlobalTimerQuest:CancelQuest(self.redpt_timer)
		self.redpt_timer = nil
	end

	MolongMibaoData.Instance = nil
end

function MolongMibaoData:GetMibaoDataList()
	return self.mibao_list
end

local a_has_reward, b_has_reward = 0, 0
local off_a, off_b = 1000, 1000
local chapter_can_reward_t = {}
function MolongMibaoData.SortMibaoDataList(a, b)
	off_a = 1000
	off_b = 1000
	a_has_reward = MolongMibaoData.Instance:GetMibaoChapterHasReward(a.chapter_id, a.reward_index)
	b_has_reward = MolongMibaoData.Instance:GetMibaoChapterHasReward(b.chapter_id, b.reward_index)
	if not a_has_reward and b_has_reward then
		off_a = off_a + 10
	elseif a_has_reward and not b_has_reward then
		off_b = off_b + 10
	else
		if MolongMibaoData.Instance:GetMibaoChapteCanReward(a) and not MolongMibaoData.Instance:GetMibaoChapteCanReward(b) then
			off_a = off_a + 100
		elseif not MolongMibaoData.Instance:GetMibaoChapteCanReward(a) and MolongMibaoData.Instance:GetMibaoChapteCanReward(b) then
			off_b = off_b + 100
		end
	end
	if a.reward_index < b.reward_index then
		off_a = off_a + 1
	elseif a.reward_index > b.reward_index then
		off_b = off_b + 1
	end

	return off_a > off_b
end

function MolongMibaoData:SetMibaoCurChapterInfo(info)
	HAS_MOLONG_INFO = true
	self.mibao_info.chapter_fetch_reward_flag[info.change_chaper] = info.chapter_fetch_reward_flag[info.change_chaper]
end

function MolongMibaoData:SetConditionParamChange(info)
	HAS_MOLONG_INFO = true
	for k,v in pairs(info.param_list) do
		self.mibao_info.chapter_param[v.charper] = self.mibao_info.chapter_param[v.charper] or {}
		self.mibao_info.chapter_param[v.charper][v.charper_index] = v.param
	end
end

function MolongMibaoData:GetCurChapter()
	return self.mibao_info.current_chaper
end

function MolongMibaoData:GetChapterInvalidTime()
	return self.mibao_info.chapter_invalid_time
end

function MolongMibaoData:GetMibaoChapterAllDataList(chapter_id)
	return self.mibao_list[chapter_id] or {}
end

function MolongMibaoData:GetMibaoChapterDataList(chapter_id)
	local mibao_list = {}
	local flag_t = {}
	for k,v in ipairs(self.mibao_list[chapter_id] or {}) do
		-- if nil == flag_t[v.condition_type] or flag_t[v.condition_type].has_reward then
		-- 	if flag_t[v.condition_type] then
		-- 		mibao_list[flag_t[v.condition_type].index] = v
		-- 	else
		-- 		table.insert(mibao_list, v)
		-- 	end
		-- 	flag_t[v.condition_type] = {index = #mibao_list, has_reward = self:GetMibaoChapterHasReward(v.chapter_id, v.reward_index)}
		-- end
		table.insert(mibao_list, v)
	end
	chapter_can_reward_t = {}
	table.sort(mibao_list, MolongMibaoData.SortMibaoDataList)
	return mibao_list
end

function MolongMibaoData:GetMibaoFinishChapterReward(chapter_id)
	for k,v in pairs(self.magicalprecious_cfg.finish_chapter_reward_cfg) do
		if chapter_id == v.chapter_id then
			return v.reward_item
		end
	end
end

function MolongMibaoData:SetMibaoInfo(info)
	HAS_MOLONG_INFO = true
	self.mibao_info.current_chaper = info.current_chaper
	self.mibao_info.chapter_invalid_time = info.chapter_invalid_time
	self.mibao_info.chapter_fetch_finish_reward_flag = info.chapter_fetch_finish_reward_flag
	self.mibao_info.chapter_fetch_reward_flag = info.chapter_fetch_reward_flag
	self.mibao_info.chapter_param = info.chapter_param
end

function MolongMibaoData:SetMibaoChapterFlag(mibao_chapter_flag_t)
	self.mibao_chapter_flag_t = mibao_chapter_flag_t
	if self:IsShowMolongMibao() then
		if self.redpt_timer == nil then
			self.redpt_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(RemindManager.Fire, RemindManager.Instance, RemindName.MoLongMiBao), 5)
		end
	else
		if self.redpt_timer then
			GlobalTimerQuest:CancelQuest(self.redpt_timer)
			self.redpt_timer = nil
		end
	end
end

function MolongMibaoData:IsShowMolongMibao()
	if not HAS_MOLONG_INFO then
		return false
	end
	for k,v in pairs(self.magicalprecious_cfg.chapter_cfg) do
		if not self:GetMibaoChapterHasReward(v.chapter_id, v.reward_index) then
			return true
		end
	end
	for i= 0, MolongMibaoData.Chapter - 1 do
		if not self:GetMibaoBigChapterHasReward(i) then
			return true
		end
	end

	return false
end

function MolongMibaoData:GetMibaoBigChapterHasReward(chapter_id)
	return bit:_and(1, bit:_rshift(self.mibao_info.chapter_fetch_finish_reward_flag, chapter_id)) > 0
end

function MolongMibaoData:GetMibaoChapterHasReward(chapter_id, reward_index)
	local chapter_index = reward_index % 32
	local big_index = math.ceil((reward_index + 1) / 32)
	local chapter_flag = self.mibao_info.chapter_fetch_reward_flag[chapter_id] or {}
	return bit:_and(1, bit:_rshift(chapter_flag[big_index] or 0, chapter_index)) > 0
end

function MolongMibaoData:GetMibaoChapteCanReward(data)
	if chapter_can_reward_t[data.chapter_id] and chapter_can_reward_t[data.chapter_id][data.reward_index] then
		return chapter_can_reward_t[data.chapter_id][data.reward_index]
	end
	local cur_value, max_value = self:GetMibaoChapterValue(data)
	chapter_can_reward_t[data.chapter_id] = chapter_can_reward_t[data.chapter_id] or {}
	chapter_can_reward_t[data.chapter_id][data.reward_index] = cur_value >= max_value
	return chapter_can_reward_t[data.chapter_id][data.reward_index]
end

function MolongMibaoData:GetMibaoChapterValue(data)
	local chapter_param = self.mibao_info.chapter_param[data.chapter_id] or {}
	local cur_value = (chapter_param[data.reward_index] or 0) + data.offer
	local max_value = data.is_show_result == 1 and 1 or (data.param_a + data.offer)
	return cur_value, max_value
end

function MolongMibaoData:GetColorEquip(grade, color, index)
	local equip = EquipData.Instance:GetGridData(index)
	if equip then
		local cfg = ItemData.Instance:GetItemConfig(equip.item_id)
		if cfg and cfg.color >= color and cfg.order >= grade then
			return 1
		end
	end
	return 0
end

function MolongMibaoData:GetMibaoChapterName(chapter_id)
	for k,v in pairs(self.magicalprecious_cfg.big_chapter_cfg) do
		if chapter_id == v.chapter_id then
			return v.chapter_name
		end
	end
	return ""
end

function MolongMibaoData:GetMibaoChapterClientCfg(chapter_id)
	for k,v in pairs(self.magicalprecious_cfg.big_chapter_cfg) do
		if chapter_id == v.chapter_id then
			return v
		end
	end
	return nil
end

function MolongMibaoData:GetMibaoChapterFinish(chapter_id)
	local now_time = TimeCtrl.Instance:GetServerTime()
	if now_time > self.mibao_info.chapter_invalid_time then
		return false
	end
	return self:GetMibaoBigChapterHasReward(chapter_id)
end

function MolongMibaoData:GetMibaoChapterRemind(chapter_id)
	if chapter_id > self.mibao_info.current_chaper then
		return 0
	end
	if not HAS_MOLONG_INFO then
		return 0
	end
	if self:GetMibaoChapterFinish(chapter_id) then
		return 0
	end
	local num = 0
	chapter_can_reward_t = {}
	local cfg = self.mibao_list[chapter_id]
	local reward_count = 0
	if cfg then
		for k,v in pairs(cfg) do
			if self:GetMibaoChapteCanReward(v) then
				reward_count = reward_count + 1
			end
		end
	end
	if cfg and reward_count >= MolongMibaoData.CanRewardCount and not MolongMibaoData.Instance:GetMibaoBigChapterHasReward(chapter_id) then
		num = num + 1
	end
	return num
end

function MolongMibaoData:GetMibaoRemind()
	local num = 0
	for i= 0, MolongMibaoData.Chapter - 1 do
		num = num + self:GetMibaoChapterRemind(i)
	end

	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = UnityEngine.PlayerPrefs.GetInt("molongmibao_remind_day") or cur_day
	if self:IsShowMolongMibao() and cur_day ~= -1 and cur_day ~= remind_day then
		num = num + 1
	end
	return num
end

function MolongMibaoData:GetCurChapterState()
	local i = self.mibao_info.current_chaper
	if not self:GetMibaoChapterFinish(i) then
		local cur_finish = 0
		for k,v in pairs(self.mibao_list[i]) do
			if self:GetMibaoChapteCanReward(v) then
				cur_finish = cur_finish + 1
			end
		end
		return i, cur_finish, #self.mibao_list[i]
	end
	return -1, 0, 0
end

function MolongMibaoData:GetMoLongOneCfg(index)
	return self.magicalprecious_cfg.chapter_cfg[index]
end

function MolongMibaoData:GetNewMibaoChapterValue(index)
	local cfg = self:GetMoLongOneCfg(index)
	local chapter_param = self.mibao_info.chapter_param[data.chapter_id] or {}
	local cur_value = (chapter_param[cfg.reward_index] or 0) + cfg.offer
	local max_value = cfg.is_show_result == 1 and 1 or (cfg.param_a + cfg.offer)
	return cur_value, max_value
end

function MolongMibaoData:GetRewardIsGetByIndex(chapter_id, reward_index)
	local chapter_index = reward_index % 32
	local big_index = math.ceil((reward_index + 1) / 32)
	local chapter_flag = self.mibao_info.chapter_fetch_reward_flag[chapter_id] or {}
	return bit:_and(1, bit:_rshift(chapter_flag[big_index] or 0, chapter_index - 1)) > 0
end

function MolongMibaoData:IsShowMolongMibaoRemind()
	local now_time = TimeCtrl.Instance:GetServerTime()
	if now_time > self.mibao_info.chapter_invalid_time then
		return 0
	end
	local cur_value1, max_value1 = self:GetNewMibaoChapterValue(1)
	local cur_value2, max_value2 = self:GetNewMibaoChapterValue(2)
	local is_get_1 = self:GetRewardIsGetByIndex(self.mibao_info.current_chaper, 1)
	local is_get_2 = self:GetRewardIsGetByIndex(self.mibao_info.current_chaper, 2)
	return ((cur_value1 >= max_value1 and  not is_get_1) or (cur_value2 >= max_value2 and  not is_get_2)) and 1 or 0
end

function MolongMibaoData:GiftIsGet()
	local now_time = TimeCtrl.Instance:GetServerTime()
	if now_time > self.mibao_info.chapter_invalid_time then
		return false
	end
	local is_get_1 = self:GetRewardIsGetByIndex(self.mibao_info.current_chaper, 1)
	local is_get_2 = self:GetRewardIsGetByIndex(self.mibao_info.current_chaper, 2)
	return not (is_get_1 and is_get_2)
end