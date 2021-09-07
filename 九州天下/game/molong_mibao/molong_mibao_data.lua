MolongMibaoData = MolongMibaoData or BaseClass()
MolongMibaoData.Chapter = 4
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
	RemindManager.Instance:Register(RemindName.MoLongMiBao, BindTool.Bind(self.GetMibaoRemind, self))
end

function MolongMibaoData:__delete()
	RemindManager.Instance:UnRegister(RemindName.MoLongMiBao)
	
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

function MolongMibaoData:GetMibaoChapterDataList(chapter_id)
	local mibao_list = self.mibao_list[chapter_id] or {}
	chapter_can_reward_t = {}
	table.sort(mibao_list, MolongMibaoData.SortMibaoDataList)
	return mibao_list
end

function MolongMibaoData:GetMibaoFinishChapterReward(chapter_id)
	for k,v in pairs(self.magicalprecious_cfg.finish_chapter_reward_cfg) do
		if chapter_id == v.chapter_id then
			return v.reward_item[0]
		end
	end
end

function MolongMibaoData:SetMibaoChapterFlag(mibao_chapter_flag_t)
	HAS_MOLONG_INFO = true
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
	for k,v in pairs(self.magicalprecious_cfg.chapter_cfg) do
		if not self:GetMibaoChapterHasReward(v.chapter_id, v.reward_index) then
			return true
		end
	end
	return false
end

function MolongMibaoData:GetMibaoChapterHasReward(chapter_id, reward_index)
	return bit:_and(1, bit:_rshift(self.mibao_chapter_flag_t[chapter_id + 1] or 0, reward_index)) > 0
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
	local cur_value, max_value = 0, 0
	if data then
		if data.condition_type == 1 then
			max_value = data.param_a
			cur_value = math.min(PlayerData.Instance.role_vo.base_fangyu, max_value)
		elseif data.condition_type == 2 then
			max_value = 1
			cur_value = math.min(self:GetColorEquip(data.param_a, data.param_b, data.param_c), max_value)
		elseif data.condition_type == 3 then
			max_value = 1
			cur_value = math.min(ForgeData.Instance:GetEquipGemCount(data.param_a, data.param_b), max_value)
		elseif data.condition_type == 4 then
			max_value = 1
			cur_value = math.min(ForgeData.Instance:GetSuitCount(data.param_a, data.param_b), max_value)
		elseif data.condition_type == 5 then
			max_value = data.param_a
			cur_value = math.min(PlayerData.Instance.role_vo.base_gongji, max_value)
		end
	end
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
	local cfg = self.mibao_list[chapter_id]
	if cfg then
		for k,v in pairs(cfg) do
			if not self:GetMibaoChapterHasReward(v.chapter_id, v.reward_index) then
				return false
			end
		end
	end
	return true
end

function MolongMibaoData:GetMibaoChapterRemind(chapter_id)
	if not HAS_MOLONG_INFO then
		return 0
	end
	if not self:GetMibaoChapterFinish(chapter_id - 1) then
		return 0
	end
	local num = 0
	chapter_can_reward_t = {}
	local cfg = self.mibao_list[chapter_id]
	if cfg then
		for k,v in pairs(cfg) do
			if not self:GetMibaoChapterHasReward(v.chapter_id, v.reward_index) and self:GetMibaoChapteCanReward(v) then
				num = num + 1
			end
		end
	end
	return num
end

function MolongMibaoData:GetMibaoRemind()
	local num = 0
	for k,v in pairs(self.mibao_list) do
		num = num + self:GetMibaoChapterRemind(k)
	end
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = UnityEngine.PlayerPrefs.GetInt("molongmibao_remind_day") or cur_day
	if self:IsShowMolongMibao() and cur_day ~= -1 and cur_day ~= remind_day then
		num = num + 1
	end
	return num
end

function MolongMibaoData.GetMibaoChapterDec(data)
	local dec = ""
	if data then
		dec = Language.MoLongMiBao.Dec[data.condition_type] or ""
		if data.condition_type == 1 then
			dec = string.format(dec, data.param_a)
		elseif data.condition_type == 2 then
			dec = string.format(dec, data.param_a, ITEM_COLOR[data.param_b] or "#ffffff",  Language.Common.ColorName[data.param_b] or "", Language.MoLongMiBao.EquipName[data.param_c] or "")
		elseif data.condition_type == 3 then
			dec = string.format(dec, data.param_a,  Language.MoLongMiBao.StoneName[data.param_b] or "")
		elseif data.condition_type == 4 then
			dec = string.format(dec, data.param_a, Language.MoLongMiBao.EquipName[data.param_b] or "")
		elseif data.condition_type == 5 then
			dec = string.format(dec, data.param_a)
		end
	end
	return dec
end

function MolongMibaoData:GetCurChapterState()
	chapter_can_reward_t = {}
	for i = 0, MolongMibaoData.Chapter do
		if not self:GetMibaoChapterFinish(i) then
			local cur_finish = 0
			for k,v in pairs(self.mibao_list[i]) do
				if self:GetMibaoChapteCanReward(v) then
					cur_finish = cur_finish + 1
				end
			end
			return i, cur_finish, #self.mibao_list[i]
		end
	end
	return -1, 0, 0
end