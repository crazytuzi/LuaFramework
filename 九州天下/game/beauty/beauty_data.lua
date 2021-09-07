BEAUTY_ALL_ROW = 60 --背包总列数
BEAUTY_COLUMN = 3 --行数
BEAUTY_ROW = 6 --格子列数
BEAUTY_SHOW_COLUMN = 3 --行数

BEAUTY_TASK_TYPE =
{
	DAY_TASK = 1,
	KILL = 4,
	CAMP_JUNGONG = 5,
}
BeautyData = BeautyData or BaseClass()
function BeautyData:__init()
	if BeautyData.Instance then
		print_error("[BeautyData] Attemp to create a singleton twice !")
	end
	BeautyData.Instance = self
	self.task_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_task
	self.skill_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_skill, "skill_type")
	self.beauty_active_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_active, "seq")
	self.beauty_shenwu_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_shenwu
	self.all_huanhua_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_huanhua
	self.huanhua_list = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_huanhua, "seq")
	self.huanhua_level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_huanhua_level, "seq", "level")
	self.xinji_slot_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_xinji_slot, "slot")
	self.xinji_skill_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_xinji_skill, "seq")
	self.xinji_skill_set_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_xinji_skill_set
	self.draw_show_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_draw_show
	self.award_preview_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").award_preview
	self.other_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").other[1]
	self.upgrade_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_upgrade, "seq", "grade")
	self.heti_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_heti, "seq")
	self.skill_book_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_skillbook, "level")
	self.xinji_skill_set_type = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_xinji_skill_set, "type")
	self.chanmian_level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").chanmian_upgrade, "seq", "grade")
	self.beauty_xinji_slot_lock = ListToMap(ConfigManager.Instance:GetAutoConfig("beautyconfig_auto").beauty_xinji_slot_lock, "num")

	self.get_way_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way

	self.pray_item_list = {}
	self.cur_used_seq = -1						-- 当前出战的美人
	self.cur_huanhua_seq = 0					-- 当前使用的幻化seq
	self.has_chanmian = 0						-- 是否缠绵过
	self.task_complete_flag = 0					-- 任务完成标记（美人心愿）
	self.task_type_flag = 0						-- 今日需要完成的任务类型标记
	self.xinji_skill_set_active_flag = 0		-- 心计组合技能激活标记
	self.next_can_free_draw_time = 0			-- 下一次可以免费抽的时间
	self.free_draw_times = 0					-- 今日免费抽的次数
	self.today_beauty_seq = 1					-- 今日出战美人
	self.today_kill_num = 0						-- 今日击杀的玩家数
	self.today_camp_jungong = 0					-- 今日获取的军功数
	self.draw_times = 0							-- 抽奖次数
	self.heti_attrs = {}						-- 合体属性

	self.beauty_heti_flag = {}					--美人合体
	self.huanhua_heti_flag_high = {}			--幻化合体

	self.beauty_item_list = {}					--所有美人数据
	self.huanhua_item_list = {}					--美人幻化列表

	self.skill_xinji_list = {}					--心计技能列表

	self.last_grade = 0
	self.last_bless = 0
	self.beauty_index = 0
	self.need_check_xl_red = true

	RemindManager.Instance:Register(RemindName.Beauty, BindTool.Bind(self.GetBeautyChangeRemind, self))
	RemindManager.Instance:Register(RemindName.BeautyInfo, BindTool.Bind(self.IsShowInfoRed, self))
	RemindManager.Instance:Register(RemindName.BeautyUpgrade, BindTool.Bind(self.IsShowUpgradeRed, self))
	RemindManager.Instance:Register(RemindName.BeautyWish, BindTool.Bind(self.IsShowWishRed, self))
	RemindManager.Instance:Register(RemindName.BeautyScheming, BindTool.Bind(self.IsShowSchemingRed, self))
	RemindManager.Instance:Register(RemindName.BeautyPray, BindTool.Bind(self.IsShowPrayRed, self))
	RemindManager.Instance:Register(RemindName.BeautyXiLian, BindTool.Bind(self.IsShowXiLianRed, self))
end

function BeautyData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Beauty)
	RemindManager.Instance:UnRegister(RemindName.BeautyInfo)
	RemindManager.Instance:UnRegister(RemindName.BeautyUpgrade)
	RemindManager.Instance:UnRegister(RemindName.BeautyWish)
	RemindManager.Instance:UnRegister(RemindName.BeautyScheming)
	RemindManager.Instance:UnRegister(RemindName.BeautyPray)
	RemindManager.Instance:UnRegister(RemindName.BeautyXiLian)
	BeautyData.Instance = nil
end

function BeautyData:GetBeautyCfg()
	if nil == self.beauty_cfg then
		self.beauty_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto")
	end
	return self.beauty_cfg
end
--设置美人数据
function BeautyData:SetBeautyInfo(protocol)
	self.cur_used_seq = protocol.cur_used_seq
	self.cur_huanhua_seq = protocol.cur_huanhua_seq
	self.has_chanmian = protocol.has_chanmian
	self.task_complete_flag = protocol.task_complete_flag
	self.task_type_flag = protocol.task_type_flag
	self.xinji_skill_set_active_flag = protocol.xinji_skill_set_active_flag
	self.next_can_free_draw_time = protocol.next_can_free_draw_time
	self.free_draw_times = protocol.free_draw_times
	self.today_beauty_seq = protocol.today_beauty_seq
	self.today_kill_num = protocol.today_kill_num
	self.today_camp_jungong = protocol.today_camp_jungong
	self.draw_times = protocol.draw_times
	self.task_reward_fetch_flag = protocol.task_reward_fetch_flag

	self.beauty_heti_flag = bit:ll2b(protocol.beauty_heti_flag_high, protocol.beauty_heti_flag_low)
	self.huanhua_heti_flag_high = bit:ll2b(protocol.huanhua_heti_flag_high, protocol.huanhua_heti_flag_low)
end

--是否缠绵过
function BeautyData:GetIsChanmian()
	return self.has_chanmian
end

--获取下次免费时间
function BeautyData:GetNextFreeTime()
	return self.next_can_free_draw_time
end

--获取今日可免费数量
function BeautyData:GetNextFreeCount()
	return self.free_draw_times
end

--获取抽奖次数
function BeautyData:GetDrawCount()
	return self.draw_times
end

function BeautyData:GetDayBeautySeq()
	return self.today_beauty_seq
end

--获取美人幻化
function BeautyData:GetHuanHuaSeq()
	return self.cur_huanhua_seq
end
-- 设置幻化列表
function BeautyData:SetHuanhuaItemList(protocol)
	self.huanhua_item_list = protocol.huanhua_item_list
end

-- 获取幻化列表
function BeautyData:GetHuanhuaItemList(seq)
	for i,v in ipairs(self.huanhua_item_list) do
		v.is_active = v.level == 0 and 0 or 1
	end
	return self.huanhua_item_list
end

-- 获取幻化列表
function BeautyData:GetHuanhuaInfo(seq)
	for i,v in ipairs(self.huanhua_item_list) do
		v.is_active = v.level == 0 and 0 or 1
		if seq == v.seq then
			return v
		end
	end
end

--美人信息
function BeautyData:SetBeautyListInfo(protocol)
	self.beauty_item_list = protocol.beauty_item_list
end

function BeautyData:GetBeautyListInfo()
	if next(self.beauty_item_list) == nil then return end 
	for k,v in pairs(self.beauty_item_list) do
		if k == self.beauty_index then
			self.last_grade = v.grade
			self.last_bless = v.upgrade_val
			return v
		end
	end

	return nil
end

function BeautyData:SetBeautyIndex(index)
	self.beauty_index = index
	self:GetBeautyListInfo()
end

function BeautyData:GetBeautyLastGrade()
	return self.last_grade
end

function BeautyData:GetBeautyLastBless()
	return self.last_bless
end

--获取当前任务完成flag
function BeautyData:GetBeautyTaskFlag(index)
	local task_complete_list = bit:d2b(self.task_complete_flag)
	return task_complete_list[32 - index]
end

-- 美人合体
function BeautyData:GetBeautyHetiFlag(index)
	if self.beauty_heti_flag[64 - index] then
		return self.beauty_heti_flag[64 - index]
	end
end

-- 幻化合体
function BeautyData:GetHuanhuaHetiFlag(index)
	if self.huanhua_heti_flag_high[64 - index] then
		return self.huanhua_heti_flag_high[64 - index]
	end
end

-- 获取今日的任务列表
function BeautyData:GetDayTaskList()
	--local task_cfg = self:GetBeautyCfg().beauty_task
	local task_list = {}
	for i,v in ipairs(self.task_cfg) do
		if bit:d2b(self.task_type_flag)[32 - v.task_type] == 1 then
			table.insert(task_list, v)
		end
	end
	return task_list
end

-- 获取今天完成所有任务的元宝
function BeautyData:GetTaskAllGold()
	local gold = 0
	for k,v in pairs(self:GetDayTaskList()) do
		if v.quick_complete_gold and self:GetBeautyTaskFlag(v.task_type) ~= 1 then
			gold = gold + v.quick_complete_gold
		end
	end
	return gold
end

-- 当前任务完成数量
function BeautyData:GetDayTaskCompleteCount()
	local task_list = self:GetDayTaskList()
	local count = 0
	for i,v in ipairs(task_list) do
		if self:GetBeautyTaskFlag(v.task_type) == 1 then
			count = count + 1
		end
	end
	return count
end

--获取美人的信息列表
function BeautyData:GetBeautyInfo()
	return self.beauty_item_list
end

--获取当前出战美人
function BeautyData:GetCurBattleBeauty()
	return self.cur_used_seq
end

function BeautyData:SetBeautyXinjiTypeInfo(protocol)
	self.skill_xinji_list[protocol.type] = {}
	self.skill_xinji_list[protocol.type].bless_val = protocol.bless_val
	self.skill_xinji_list[protocol.type].active_max_slot = protocol.active_max_slot
	self.skill_xinji_list[protocol.type].skill_list = protocol.skill_item_list
end

--根据类型获取天地人技能列表
function BeautyData:GetXinjiTypeInfo(types)
	return self.skill_xinji_list[types]
end

function BeautyData:GetBeautyOther()
	-- local other_cfg = self:GetBeautyCfg().other
	-- if other_cfg then
	-- 	return other_cfg[1]
	-- end
	return self.other_cfg
end

-- 美人技能
function BeautyData:GetBeautySkill(index)
	--local skill_cfg = self:GetBeautyCfg().beauty_skill
	-- if skill_cfg then
	-- 	for i,v in ipairs(skill_cfg) do
	-- 		if v.skill_type == index then
	-- 			return v
	-- 		end
	-- 	end
	-- end

	if index ~= nil then
		return self.skill_cfg[index]
	end

	return nil
end

-- 美人激活
function BeautyData:GetBeautyActive()
	local active_cfg = self:GetBeautyCfg().beauty_active
	if active_cfg then
		return active_cfg
	end
end

function BeautyData:GetBeautyActiveInfo(seq)
	-- local active_cfg = self:GetBeautyCfg().beauty_active
	-- for k,v in pairs(active_cfg) do
	-- 	if seq == v.seq then
	-- 		return v
	-- 	end
	-- end
	if seq ~= nil then
		return self.beauty_active_cfg[seq]
	end

	return nil
end

function BeautyData:GetBeautyactiveCfg(item_id)
	for k,v in pairs(self.beauty_active_cfg) do
		if v.active_item_id == item_id then
			return v.seq
		end
	end
	return 1
end
-- 美人进阶配置
function BeautyData:GetBeautyUpgrade(seq, grade)
	-- if self.upgrade_cfg[seq] == nil then
	-- 	return nil
	-- end
	-- return self.upgrade_cfg[seq][grade]	
	if seq ~= nil and grade ~= nil then
		if self.upgrade_cfg[seq] ~= nil then
			return self.upgrade_cfg[seq][grade]	
		end
	end

	return nil
end

function BeautyData:GetBeautyMaxLevelCfg(seq)
	if seq ~= nil then
		if self.upgrade_cfg[seq] ~= nil then
			return self.upgrade_cfg[seq][#self.upgrade_cfg[seq]]	
		end
	end
end

-- 美人任务
function BeautyData:GetBeautyTask(task_type)
	--local task_cfg = self:GetBeautyCfg().beauty_task
	--if task_cfg then
		for i,v in ipairs(self.task_cfg) do
			if task_type == v.task_type then
				return v
			end
		end
	--end
end

--美人神武
function BeautyData:GetBeautyShenwu(seq)
	--local shenwu_cfg = self:GetBeautyCfg().beauty_shenwu
	--if shenwu_cfg then
		for i,v in ipairs(self.beauty_shenwu_cfg) do
			if seq == v.seq then
				return v
			end
		end
	--end
end

--美人幻化列表
function BeautyData:GetBeautyHuanhuaListCfg()
	--local huanhua_cfg = self:GetBeautyCfg().beauty_huanhua
	local huanhua_cfg = TableCopy(self.all_huanhua_cfg)
	SortTools.SortAsc(huanhua_cfg, "show_order")
	return huanhua_cfg
end

function BeautyData:GetShowSpecialInfo()
	local num = 0
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local huanhua_cfg = TableCopy(self.all_huanhua_cfg)
	SortTools.SortAsc(huanhua_cfg, "show_order")
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	for k,v in pairs(huanhua_cfg) do
		if v ~= nil then
			if (v.show_level ~= nil and role_level >= v.show_level) and (v.open_day ~= nil and open_day >= v.open_day) then
				num = num + 1
				table.insert(show_list, v)				
			else
				local info_data = self:GetHuanhuaInfo(v.seq)
				local has_num = ItemData.Instance:GetItemNumInBagById(v.need_item)
				if (info_data ~= nil and info_data.is_active ~= nil and info_data.is_active == 1) or has_num > 0 then
					num = num + 1
					table.insert(show_list, v)				
				end
			end
		end
	end

	local function sort_function(a, b)
		return a.seq < b.seq
	end
	table.sort(show_list, sort_function)

	return num, show_list
end

function BeautyData:CheckIsHuanHuaItem(item_id)
	local is_item = false
	if item_id == nil or self.huanhua_list == nil then
		return
	end

	for k,v in pairs(self.huanhua_list) do
		if v ~= nil and v.need_item == item_id then
			is_item = true
			break
		end
	end

	return is_item
end

function BeautyData:GetBeautyHuanhuaCfg(seq)
	-- local huanhua_cfg = self:GetBeautyCfg().beauty_huanhua
	-- if huanhua_cfg then
	-- 	for i,v in ipairs(huanhua_cfg) do
	-- 		if seq == v.seq then
	-- 			return v
	-- 		end
	-- 	end
	-- end
	if seq ~= nil then
		return self.huanhua_list[seq]
	end

	return nil
end

--幻化兑换开启数量
function BeautyData:GetHuanhuaExchangeMaxNum()
	local num = 0
	for k,v in pairs(self.huanhua_list) do
		if v.exchange == 1 then
			num = num + 1
		end
	end
	return num
	-- return #self.huanhua_list
end

function BeautyData:GetCurHuanhuaAttrCfg(seq, level)
	-- if not self.huanhua_level_cfg then
	-- 	self.huanhua_level_cfg = ListToMap(self:GetBeautyCfg().beauty_huanhua_level, "seq", "level")
	-- end
	-- local huanhua_level_cfg = self.huanhua_level_cfg[seq] 
	-- return huanhua_level_cfg and huanhua_level_cfg[level] or nil

	if seq ~= nil and level ~= nil then
		if self.huanhua_level_cfg[seq] ~= nil then
			return self.huanhua_level_cfg[seq][level]
		end
	end

	return nil
end


--获取当前幻化最高等级
function BeautyData:GetHuanhuaMaxLevel(seq)
	-- if not self.huanhua_level_cfg_max then
	-- 	self.huanhua_level_cfg_max = ListToMap(self:GetBeautyCfg().beauty_huanhua_level, "seq") or {}
	-- end
	--return self.huanhua_level_cfg_max[seq]

	-- local count = 0
	if seq ~= nil then
		local cfg = self.huanhua_level_cfg[seq]
		if cfg ~= nil then
			return table.remove(TableCopy(self.huanhua_level_cfg[seq]))
		end
	end

	return nil
	-- return count
end

--通过索引获得仓库的格子对应的编号
function BeautyData:GetCellIndexList(cell_index)
	local cell_index_list = {}
	local x = math.floor(cell_index/BEAUTY_ROW)
	if x > 0 and x * BEAUTY_ROW ~= cell_index then
		cell_index = cell_index + BEAUTY_ROW * (BEAUTY_SHOW_COLUMN - 1) * x
	elseif x > 1 and x * BEAUTY_ROW == cell_index then
		cell_index = cell_index + BEAUTY_ROW * (BEAUTY_SHOW_COLUMN - 1) * (x - 1)
	end
	for i=1,BEAUTY_SHOW_COLUMN do
		if i == 1 then
			cell_index_list[i] = cell_index + i - 1
		else
			cell_index_list[i] = cell_index + BEAUTY_ROW * (i - 1)
		end
	end
	return cell_index_list
end

--奖励物品
-- function BeautyData:GetBeautyDrawCfg()
-- 	return self:GetBeautyCfg().beauty_draw
-- end

function BeautyData:GetXianjieSlotCfg(slot)
	-- local cfg = self:GetBeautyCfg().beauty_xinji_slot
	-- for i,v in pairs(cfg) do
	-- 	if v.slot == slot then
	-- 		return v
	-- 	end
	-- end
	if slot ~= nil then
		return self.xinji_slot_cfg[slot]
	end

	return nil
end

function BeautyData:GetBeautyXinjiSkillCfg(seq)
	--local xiji_skill_cfg = self:GetBeautyCfg().beauty_xinji_skill
	--if xiji_skill_cfg then
		-- for i,v in ipairs(self.xinji_skill_cfg) do
		-- 	if seq == v.seq then
		-- 		return v
		-- 	end
		-- end
	--end
	if seq ~= nil then
		return self.xinji_skill_cfg[seq]
	end
	
	return nil
end

function BeautyData:GetCurLevelXinjiSkillCfg(seq, level)
	local cfg = TableCopy(self:GetBeautyXinjiSkillCfg(seq))
	local xiji_skill_cfg = cfg
	if cfg then
		local attrs_rate_list = Split(cfg.level_add_attrs_rate, "|")
		local need_item_list = Split(cfg.level_up_need_item, "|")
		local succ_rate_list = Split(cfg.level_up_succ_rate, "|")
		xiji_skill_cfg.attrs_rate = tonumber(attrs_rate_list[level + 1])
		xiji_skill_cfg.item = tonumber(need_item_list[level + 1])
		xiji_skill_cfg.succ_rate = tonumber(succ_rate_list[level + 1])
	end
	return xiji_skill_cfg
end

function BeautyData:GetLevelXinjiSkillSetCfg()
	local set_skill_cfg = TableCopy(self.xinji_skill_set_cfg)
	if set_skill_cfg then
		for k,v in pairs(set_skill_cfg) do
			local seq_list = {}
			local i = 1
			local t = Split(v.need_skill_seq, "|") or {}
			for k1,v1 in pairs(t) do
				seq_list[i] = tonumber(v1)
				i = i + 1
			end
			v.seq_list = seq_list
		end
		
	end
	return set_skill_cfg
end

-- 获取是否激活当前技能
function BeautyData:GetcurIconIsGray(seq)
	for i=0,2 do
		for i,v in ipairs(self.skill_xinji_list[i].skill_list) do
			if seq == v.seq and v.level > 0 then
				return true
			end
		end
	end
	return false
end

-- 该种技能数量是否足够
function BeautyData:GetTypesIconIsGray(types, num)
	if self.skill_xinji_list[types] then
		local count = 0
		for i,v in ipairs(self.skill_xinji_list[types].skill_list) do
			if v.level > 0 then
				count = count + 1
			end
		end
		return count >= num
	end
	return false
end

function BeautyData:GetBeautyItemList()
	local get_skill_list = {}
	local no_skill_list = {}
	for i,v in ipairs(self.beauty_item_list) do
			v.seq = i
		if v.is_active == 1 then
			table.insert(get_skill_list, v)
		else
			table.insert(no_skill_list, v)
		end
	end
	return get_skill_list, no_skill_list
end

function BeautyData:SetPrayItemList(data)
	self.pray_item_list = data
end

function BeautyData:GetPrayItemList()
	return self.pray_item_list
end

function BeautyData:GetXinjiSkillActiveFlag()
 return self.xinji_skill_set_active_flag
end

-- 美人抽奖模型展示
function BeautyData:GetBeautyDrawShow()
	--return self:GetBeautyCfg().beauty_draw_show
	return self.draw_show_cfg
end

function BeautyData:SetHetiAttrsData(protocol)
	self.heti_attrs = protocol.attr_list
end

function BeautyData:GetIsShowFloatingAttr(attr)
	for k,v in pairs(self.heti_attrs) do
		if attr.attr_type == v.attr_type and attr.attr_value == v.attr_value then
			return false
		end
	end
	return true
end

-- 获取合体属性
function BeautyData:GetHetisData()
	return self.heti_attrs
end

-- 合体战力属性
function BeautyData:GetHetiCapability()
	local attr_list = {}
	local name_list = Language.Beaut.HetiAttrType 
	for k,v in pairs(self.heti_attrs) do
		attr_list[name_list[v.attr_type]] = v.attr_value
	end
	return attr_list
end

-- 当前是否有合体属性
function BeautyData:GetHeTiBool(seq)
	return self:GetCurbeautyActive(seq)
end

-- 是否激活美人
function BeautyData:GetCurbeautyActive(seq)
	if self.beauty_item_list[seq] then
		return self.beauty_item_list[seq].is_active
	end
	return 0
end

function BeautyData:GetBeautyInfoBySeq(seq)
	if seq == nil then
		return nil
	end

	return self.beauty_item_list[seq]
end

function BeautyData:GetActiveCfgBySeq(seq)
	local cfg = {}
	if seq == nil then
		return cfg
	end

	local check_cfg = {}
	if seq <= 100 then
		check_cfg = self.beauty_active_cfg
	else
		check_cfg = self.huanhua_item_list
	end
	if seq ~= nil then
		return check_cfg[seq]
	end

	return cfg
end

function BeautyData:GetRawardReview()
	--return self:GetBeautyCfg().award_preview
	return self.award_preview_cfg
end

function BeautyData:GetTaskNum(types)
	if types == BEAUTY_TASK_TYPE.KILL then
		return self.today_kill_num
	elseif types == BEAUTY_TASK_TYPE.CAMP_JUNGONG then
		return self.today_camp_jungong
	end
	return 0
end

-- 合体属性
function BeautyData:GetHeTiAttr(seq)
	local cfg = self.heti_cfg[seq]
	local attr_list = CommonDataManager.GetAttributteByClass(cfg)
	local str = ""
	if cfg then
		for k,v in pairs(attr_list) do
			if v > 0 then
				local value = v
				-- if k == "hurt_increase" or k == "hurt_reduce" then
				-- 	value = MojieData.Instance:GetAttrRate(value)
				-- end,
				str = Language.Common.BeautyAttrName[k] .. "+" .. value
			end
		end
	end
	return str
end

function BeautyData:GetStuffNumStr(num, next_num)
	local stuff_color = num < next_num and "ff0000" or "00931f"
	return string.format(Language.Beaut.BeautStuffShow, stuff_color, num, next_num)
end

function BeautyData:GetNameStuffNumStr(name, num, next_num)
	local stuff_color = num < next_num and "ff0000" or "00931f"
	return string.format(Language.Beaut.BeautNameStuffShow, name, stuff_color, num, next_num)
end

function BeautyData:GetHuanhuaCurSeq(item_id)
	local _, cfg = self:GetShowSpecialInfo()
	--local cfg = self:GetBeautyHuanhuaListCfg()
	for k,v in pairs(cfg) do
		if item_id == v.need_item then
			return v
		end
	end
end

function BeautyData:IsShowInfoRed()
	local is_show = 0
	if not OpenFunData.Instance:CheckIsHide("beauty_info") then
		return is_show
	end

	local active_list = self:GetBeautyInfo()
	if active_list ~= nil then
		for k,v in pairs(active_list) do
			if v ~= nil then
				-- if v.is_active == 1 then
				-- 	if self:GetIsHeTi() then
				-- 		return 1
				-- 	end			
				-- end

				if self:GetIsCanActiveOrChan(k, nil, true) then
					return 1
				end
			end
		end
	end

	if self:GetIsShowHuanHuaRed() then
		return 1
	end

	return is_show
end

function BeautyData:GetIsActive(index)
	local is_active = false
	local active_list = self:GetBeautyInfo()
	if active_list ~= nil then
		local active_cfg = active_list[index]
		if active_cfg ~= nil then
			is_active = active_cfg.is_active == 1
		end
	end	 

	return is_active
end

function BeautyData:GetIsCanActiveOrChan(index, is_active, is_ignore)
	local is_can = false
	local check_flag = is_active and 1 or 0
	if index == nil then
		return is_can
	end

	local active_value = self:GetIsActive(index)
	if not is_ignore then
		if active_value == check_flag then
			return is_can
		end
	end

	local data = self:GetBeautyActiveInfo(index - 1)
	if data ~= nil and data.active_item_id ~= nil then
		local need_item = data.active_item_id
		local has_item = ItemData.Instance:GetItemNumInBagById(need_item)
		if has_item >= 1 then
			if not is_ignore then
				is_can = true
			else
				if not active_value then
					is_can = true
				else
					local is_max = self:GetBeautyMaxLevelCfg(index - 1)
					if not is_max then
						is_can = true
					end
				end
			end
		end
	end

	return is_can
end

-- function BeautyData:GetIsHeTi(index)
-- 	local is_heti = false
-- 	if index == nil then
-- 		return is_heti
-- 	end

-- 	if not self:GetIsActive(index) then
-- 		return is_heti
-- 	end

-- 	local value = self:GetBeautyHetiFlag(index - 1)
-- 	is_heti = not (value == 1)

-- 	return is_heti
-- end

function BeautyData:GetHuanHuaIsCanActiveOrChan(index)
	local is_can = false
	if index == nil then
		return is_can
	end

	local info_data = self:GetHuanhuaInfo(index - 1)
	if info_data == nil or next(info_data) == nil then
		return is_can
	end

	local active_value = info_data.is_active == 1
	local data = self:GetBeautyHuanhuaCfg(info_data.seq)
	if data ~= nil and data.need_item ~= nil then
		local need_item = data.need_item
		local has_item = ItemData.Instance:GetItemNumInBagById(need_item)
		if has_item >= 1 then
			if not active_value then
				is_can = true
			else
				local max_cfg = self:GetHuanhuaMaxLevel(info_data.seq)
				local is_max = false
				if max_cfg ~= nil and max_cfg.level ~= nil and info_data.level >= max_cfg.level then
					is_max = true
				end

				if not is_max then
					is_can = true
				end
			end
		end
	end

	return is_can
end

function BeautyData:CanHuanHuaHeTi(index)
	local is_heti = false
	if index == nil then
		return is_heti
	end

	local info_data = self:GetHuanhuaInfo(index - 1)
	if info_data == nil or next(info_data) == nil then
		return is_heti
	end

	if info_data.is_active == 0 then
		return is_heti
	end

	local value = self:GetHuanhuaHetiFlag(index - 1)
	is_heti = not (value == 1)

	return is_heti
end

function BeautyData:GetIsCanActiveShenWu(index, is_huanhua)
	local is_can = false
	if index == nil then
		return is_can
	end

	local info_data = nil

	if is_huanhua then
		info_data = self:GetHuanhuaInfo(index - 1)
		if info_data ~= nil and info_data.is_active ~= 1 then
			return false
		end
	else
		if not self:GetIsActive(index) then
			return false
		end
		info_data = self:GetBeautyInfoBySeq(index)
	end

	if info_data == nil or next(info_data) == nil then
		return is_can
	end

	if info_data.is_active_shenwu == 1 then
		return is_can
	end

	local real_index = index - 1
	if is_huanhua then
		real_index = real_index + 100
	end
	local shenwu_cfg = self:GetBeautyShenwu(real_index)

	if shenwu_cfg == nil or next(shenwu_cfg) == nil then
		return is_can
	end

	local has_item = ItemData.Instance:GetItemNumInBagById(shenwu_cfg.active_item_id)
	if has_item >= shenwu_cfg.active_item_count then
		is_can = true
	end

	return is_can
end

function BeautyData:GetIsShowHuanHuaRed()
	local is_can = false
	if self.huanhua_item_list ~= nil then
		for k,v in pairs(self.huanhua_item_list) do
			if v ~= nil then
				if self:GetHuanHuaIsCanActiveOrChan(v.seq + 1) then
					return true
				end

				if v.level > 0 then
					-- if self:CanHuanHuaHeTi(v.seq + 1) then
					-- 	return true
					-- end

					if self:GetIsCanActiveShenWu(v.seq + 1, true) then
						return true
					end
				end
			end
		end
	end

	return is_can
end

function BeautyData:IsShowUpgradeRed()
	local is_show = 0
	if not OpenFunData.Instance:CheckIsHide("beauty_upgrade") then
		return is_show
	end

	if self:GetUpgradeRedRender() ~= -1 then
		return 1
	end

	if self:GetLevelRedRender() then
		return 1
	end

	local active_list = self:GetBeautyInfo()
	if active_list ~= nil then
		for k,v in pairs(active_list) do
			if self:GetIsCanActiveShenWu(k, false) then
				return 1
			end
		end
	end

	return is_show
end

function BeautyData:GetIsCanUpgrade(index)
	local is_can = false
	if index == nil then
		return is_can
	end

	if not self:GetIsActive(index) then
		return is_can
	end

	local data = self:GetBeautyInfoBySeq(index)
	if data == nil then
		return is_can
	end

	local grade_cfg = self:GetBeautyUpgrade(index - 1, data.grade + 1)
	if grade_cfg == nil or next(grade_cfg) == nil then
		return is_can
	end

	local need_item = grade_cfg.item_id
	local need_num = grade_cfg.item_num
	local has_num = ItemData.Instance:GetItemNumInBagById(need_item)
	if has_num >= need_num then
		is_can = true
	end

	return is_can
end

function BeautyData:GetUpgradeRedRender()
	local seq = -1
	local data = nil

	local active_list = self:GetBeautyInfo()
	if active_list ~= nil then
		for k,v in pairs(active_list) do
			if v ~= nil then
				if self:GetIsCanUpgrade(k) then
					if data == nil then
						data = v
						data.seq = k - 1
					else
						if data.grade > v.grade then
							data = v
							data.seq = k - 1
						elseif data.grade == v.grade and data.upgrade_val > v.upgrade_val then
							data = v
							data.seq = k - 1
						end
					end
				end
			end
		end
	end

	if data ~= nil then
		seq = data.seq
	end

	return seq
end

function BeautyData:GetLevelRedRender()
	local is_can = false
	local active_list = self:GetBeautyInfo()
	if active_list ~= nil then
		for k,v in pairs(active_list) do
			if v ~= nil then
				if self:GetIsCanAddLevel(k) then
					return true
				end
			end
		end
	end

	return is_can	
end

function BeautyData:GetIsCanAddLevel(index)
	local is_can = false
	if index == nil then
		return is_can
	end

	if not self:GetIsActive(index) then
		str = Language.Beaut.NeedActiveBeauty
		return is_can
	end

	local data = self:GetBeautyInfoBySeq(index)
	if data == nil then
		return is_can
	end

	local level_cfg, max_level = self:GetChanMianLevelCfg(index - 1, data.level)
	if level_cfg == nil or next(level_cfg) == nil then
		return is_can
	end

	local all_info = self:GetBeautyInfo()
	if all_info == nil or next(all_info) == nil then
		return is_can
	end

	local info = all_info[index]
	if info == nil or next(info) == nil then
		return is_can
	end 

	local is_max = info.level >= max_level
	if is_max then
		return is_can
	end

	local need_item = level_cfg.item_id
	local need_num = level_cfg.item_num
	local has_num = ItemData.Instance:GetItemNumInBagById(need_item)
	if has_num >= need_num then
		is_can = true
	end

	return is_can
end

function BeautyData:IsShowWishRed()
	local is_show = 0
	if not OpenFunData.Instance:CheckIsHide("beauty_wish") then
		return is_show
	end

	local is_can = self:GetIsChanmian()
	-- if is_can == nil or is_can == 1 then
	-- 	return is_show
	-- end

	if self.task_complete_flag ~= nil then
		local num = 0
		local task_complete_list = bit:d2b(self.task_complete_flag)
		for k,v in pairs(task_complete_list) do
			if v == 1 then
				num = num + 1
			end

			if num >= 5 and (is_can ~= nil and is_can ~= 1) then
				return 1
			end
		end
	end

	local task_list = self:GetDayTaskList()
	if task_list ~= nil then
		for k,v in pairs(task_list) do
			if v ~= nil then
				local check_is_finsh = BeautyData.Instance:GetWishIsFinsh(v.task_type)
				local is_get = BeautyData.Instance:GetWishIsCanRecharge(v.task_type)
				if check_is_finsh and not is_get then
					return 1
				end
			end
		end
	end

	return is_show
end

function BeautyData:GetShowRedSkillList()
	local num = 0
	local no_num = 0
	local book_num = 0
	local tab_red_list = {}

	if self.skill_xinji_list == nil then

		return num, no_num, book_num, tab_red_list
	end

	local has_item_list = {}
	for k,v in pairs(self.skill_book_cfg) do
		has_item_list[k] = ItemData.Instance:GetItemNumInBagById(v.item_id)
		book_num = book_num + has_item_list[k]
	end

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in pairs(self.skill_xinji_list) do
		if v ~= nil then
			local active_max_slot = v.active_max_slot
			for k1,v1 in pairs(v.skill_list) do
				local slot_info =  BeautyData.Instance:GetXianjieSlotCfg(k1 - 1)				
				if v1.seq ~= 0 and slot_info ~= nil and role_level >= slot_info.active_need_level and v1.level < #has_item_list and has_item_list[v1.level + 1] > 0 then
					num = num + 1
					if tab_red_list[k] == nil then
						tab_red_list[k] = true
					end
				end
				if v1.seq == 0 and slot_info ~= nil and role_level >= slot_info.active_need_level and has_item_list[1] > 0 then
					no_num = no_num + 1
					if tab_red_list[k] == nil then
						tab_red_list[k] = true				
					end
				end
			end
		end
	end

	return num, no_num, book_num, tab_red_list
end

function BeautyData:GetIsCanLearnSkill(is_all)
	local is_can = false
	local num, no_num, book_num = self:GetShowRedSkillList()
	if is_all and num > 0 then
		return true
	end

	if no_num > 0 and book_num > 0 then
		return true
	end

	return is_can
end

function BeautyData:IsShowSchemingRed()
	if not OpenFunData.Instance:CheckIsHide("beauty_scheming") then
		return 0
	end

	return self:GetIsCanLearnSkill(true) and 1 or 0
end

function BeautyData:GetIsCanRoll(is_ten)
	local is_can = false
	local other_cfg = self:GetBeautyOther()
	local item = nil
	local need_num = nil
	if other_cfg ~= nil then
		item = other_cfg.draw_1_item_id
		if is_ten then
			need_num = other_cfg.draw_10_item_num
		else
			need_num = other_cfg.draw_1_item_num
		end

		if item ~= nil and need_num ~= nil then
			local has_num = ItemData.Instance:GetItemNumInBagById(item)
			if has_num >= need_num then
				is_can = true
			end
		end
	end

	return is_can
end

function BeautyData:GetIsCanGetRollReward()
	local is_can = false
	local roll_count = self:GetDrawCount()
	local other_cfg = self:GetBeautyOther()
	if roll_count ~= nil and other_cfg ~= nil then
		local need_num = other_cfg.phase_reward_need_draw_times
		if need_num ~= nil and roll_count >= need_num then
			is_can = true
		end
	end 

	return is_can
end

function BeautyData:GetIsCanYouHui()
	local is_can = false
	if self.huanhua_list == nil then
		return is_can
	end

	local other_cfg = BeautyData.Instance:GetBeautyOther()
	if other_cfg == nil then
		return is_can
	end

	for k,v in pairs(self.huanhua_list) do
		if v ~= nil and v.exchange == 1 then
			local data = self:GetHuanhuaInfo(v.seq)
			if data ~= nil then
				local huanhua_count = v.exchange_times - data.dating_times
				if huanhua_count > 0 then
					local need_num = v.exchange_item_count
					local item = other_cfg.dating_item
					local has_num = ItemData.Instance:GetItemNumInBagById(item)
					if has_num >= need_num then
						is_can = true
						break
					end
				end
			end
		end
	end

	return is_can
end

function BeautyData:IsShowPrayRed()
	local is_can = 0
	if not OpenFunData.Instance:CheckIsHide("beauty_pray") then
		return is_can
	end
	
	if self:GetIsCanRoll(false) then
		return 1
	end

	if self:GetIsCanGetRollReward() then
		return 1
	end

	if self:GetIsCanYouHui() then
		return 1
	end

	local count = TreasureData.Instance:GetChestCount() or 0
	if count > 0 then
		return 1
	end

	return is_can
end

function BeautyData:GetBeautyChangeRemind()
	local num = 0
	if self:IsShowInfoRed() == 1 then
		return 1
	end

	if self:IsShowUpgradeRed() == 1 then
		return 1
	end

	if self:IsShowWishRed() == 1 then
		return 1
	end

	if self:IsShowSchemingRed() == 1 then
		return 1
	end

	if self:IsShowPrayRed() == 1 then
		return 1
	end

	if self:IsShowXiLianRed() == 1 then
		return 1
	end

	return 0
end

function BeautyData:GetWayById(id)
	if id == nil then
		return {}
	end
	return self.get_way_cfg[id]
end

function BeautyData:GetBeautyAllCapAttr()
	local cap = 0
	local all_attr = CommonStruct.Attribute()

	local beauty_list = self:GetBeautyInfo()

	local nor_attr = CommonStruct.Attribute()
	for k,v in pairs(beauty_list) do
		if v ~= nil then
			if v.is_active == 1 then
				local attr = CommonStruct.Attribute()
				local active_cfg = self:GetBeautyActiveInfo(k - 1)
				if active_cfg ~= nil and next(active_cfg) ~= nil then
					attr = CommonDataManager.AddAttributeAttr(attr, CommonDataManager.GetAttributteByClass(active_cfg))
				end

				local grade_cfg = self:GetBeautyUpgrade(k - 1, v.grade)
				if grade_cfg ~= nil and next(grade_cfg) ~= nil then
					attr = CommonDataManager.AddAttributeAttr(attr, CommonDataManager.GetAttributteByClass(grade_cfg))
				end

				if v.is_active_shenwu == 1 then
					local shenwu_cfg = self:GetBeautyShenwu(k - 1)
					if shenwu_cfg ~= nil and next(shenwu_cfg) ~= nil then
						attr = CommonDataManager.AddAttributeAttr(attr, CommonDataManager.GetAttributteByClass(shenwu_cfg))
					end
				end

				nor_attr = CommonDataManager.AddAttributeAttr(nor_attr, attr)
			end
		end
	end

	local huanhua_attr = CommonStruct.Attribute()
	if self.huanhua_item_list ~= nil then
		for k,v in pairs(self.huanhua_item_list) do
			if v ~= nil then
				if v.level > 0 then
					local attr = CommonStruct.Attribute()
					local level_cfg = self:GetCurHuanhuaAttrCfg(v.seq, v.level)
					if level_cfg ~= nil and next(level_cfg) ~= nil then
						attr = CommonDataManager.AddAttributeAttr(attr, CommonDataManager.GetAttributteByClass(level_cfg))
					end

					if v.is_active_shenwu == 1 then
						local shenwu_cfg = self:GetBeautyShenwu(k - 1 + 100)
						if shenwu_cfg ~= nil and next(shenwu_cfg) ~= nil then
							attr = CommonDataManager.AddAttributeAttr(attr, CommonDataManager.GetAttributteByClass(shenwu_cfg))
						end
					end

					huanhua_attr = CommonDataManager.AddAttributeAttr(huanhua_attr, attr)
				end
			end
		end
	end

	local skill_attr = CommonStruct.Attribute()
	if self.skill_xinji_list ~= nil then
		for k,v in pairs(self.skill_xinji_list) do
			local attr = CommonStruct.Attribute()
			if v ~= nil and v.skill_list ~= nil then
				for k1, v1 in pairs(v.skill_list) do
					if v1 ~= nil and v1.level > 0 then
						local level_cfg = self:GetCurLevelXinjiSkillCfg(v1.seq, v1.level + 1)
						if level_cfg ~= nil and next(level_cfg) ~= nil then
							local old_attr = CommonDataManager.GetAttributteByClass(level_cfg)
							local new_attr = TableCopy(old_attr)
							for k,v in pairs(old_attr) do
								if v ~= nil and v > 0 and level_cfg.attrs_rate ~= nil then
									new_attr[k] = new_attr[k] * level_cfg.attrs_rate
								end
							end

							attr = CommonDataManager.AddAttributeAttr(attr, new_attr)
						end
					end
				end
			end

			skill_attr = CommonDataManager.AddAttributeAttr(skill_attr, attr)
		end
	end

	all_attr = CommonDataManager.AddAttributeAttr(nor_attr, huanhua_attr)
	all_attr = CommonDataManager.AddAttributeAttr(all_attr, skill_attr)

	local zu_skill_active_list = self:GetXinjiSkillActiveFlag()
	if self.xinji_skill_set_type ~= nil and zu_skill_active_list ~= nil then
		local active_tab = bit:d2b(zu_skill_active_list)
		local skill_cap = 0
		for k,v in pairs(active_tab) do
			if v > 0 then
				local data = self.xinji_skill_set_type[33 - k]
				if data ~= nil then
					skill_cap = skill_cap + data.add_cap
					if data.master_val > 0 then
						all_attr["ice_master"] = all_attr["ice_master"] + data.master_val
						all_attr["fire_master"] = all_attr["fire_master"] + data.master_val
						all_attr["thunder_master"] = all_attr["thunder_master"] + data.master_val
						all_attr["poison_master"] = all_attr["poison_master"] + data.master_val
					end
				end
			end
		end

		cap = cap + skill_cap
	end

	cap = cap + CommonDataManager.GetCapability(all_attr)

	return all_attr, cap
end
-- 美人升级配置
function BeautyData:GetShengJiLevelCfg(seq, level)
	local level_cfg = {}
	if self.chanmian_level_cfg[seq][level] then
		return self.chanmian_level_cfg[seq][level]
	end
	return level_cfg
end

function BeautyData:GetChanMianLevelCfg(seq, level)
	local data = {}
	local max_level = 0
	if seq == nil or level == nil then
		return data, max_level
	end

	if self.chanmian_level_cfg == nil then
		return data, max_level
	end

	max_level = #self.chanmian_level_cfg[seq]

	if self.chanmian_level_cfg[seq] ~= nil then
		return self.chanmian_level_cfg[seq][level] or data, max_level
	end

	return data, max_level
end

function BeautyData:GetSkillLockInfo(skill_type, skill_index)
	local data = {}
	if skill_type == nil or skill_index == nil then
		return data
	end

	if self.skill_xinji_list == nil or self.skill_xinji_list[skill_type] == nil then
		return data
	end

	local skill_data = self.skill_xinji_list[skill_type].skill_list
	local active_num = 0
	local lock_num = 0
	local is_lock = false

	for k, v in pairs(skill_data) do
		if v ~= nil then
			if v.level > 0 then
				active_num = active_num + 1
			end

			if v.is_lock == 1 then
				lock_num = lock_num + 1
			end

			if k == skill_index then
				is_lock = v.is_lock == 1
			end
		end
	end

	data.active_num = active_num
	data.lock_num = lock_num
	data.add_value = self.other_cfg.xinji_slot_lock_add_attr_per or 0
	data.cur_is_lock = is_lock

	return data
end

function BeautyData:GetSkillLockCfg(num)
	local cfg = {}
	if num == nil then
		return cfg
	end

	if self.beauty_xinji_slot_lock == nil or self.beauty_xinji_slot_lock[num] == nil then
		return cfg
	end

	return self.beauty_xinji_slot_lock[num]
end

function BeautyData:GetWishIsFinsh(index)
	local is_finsh = false
	if index == nil then
		return is_finsh
	end

	if self.task_complete_flag == nil then
		return is_finsh
	end

	local tab = bit:d2b(self.task_complete_flag)
	if tab ~= nil then
		is_finsh = tab[32 - index] == 1
	end

	return is_finsh
end

function BeautyData:GetWishIsCanRecharge(index)
	local is_get = false
	if index == nil then
		return is_get
	end

	if self.task_reward_fetch_flag == nil then
		return is_get
	end

	local tab = bit:d2b(self.task_reward_fetch_flag)
	if tab ~= nil then
		is_get = tab[32 - index] == 1
	end

	return is_get
end

function BeautyData:SetCheckXLRed(value)
	self.need_check_xl_red = value
end

function BeautyData:GetCheckXLRed()
	return self.need_check_xl_red
end

function BeautyData:IsShowXiLianRed()
	local is_can = 0
	if not OpenFunData.Instance:CheckIsHide("beauty_xilian") then
		return is_can
	end

	local active_list = self:GetBeautyInfo()
	if active_list ~= nil then
		for k,v in pairs(active_list) do
			if v ~= nil then
				if v.is_active == 1 then
					if self:GetIsCanOpen( k - 1) then
						return 1
					end					
				end
			end
		end
	end

	if HunQiData.Instance:GetXiLianRedPoint() then
		return HunQiData.Instance:CalcHunQiXiLianShuRedPoint()
	end

	return is_can
end

function BeautyData:GetIsCanOpen(seq)
	local is_can = false
	if seq == nil then
		return is_can
	end

	if not self:GetIsActive(seq + 1) then
		return is_can
	end

	local data = HunQiData.Instance:GetHunQiCfgBySeq(seq)
	local xilian_data = HunQiData.Instance:GetHunQiXiLianInfoById(seq + 1)
	
	if data ~= nil and next(data) ~= nil and xilian_data ~= nil and next(xilian_data) ~= nil then
		for k,v in pairs(data) do
			if v[1] ~= nil and v[1].gold_cost <= 0 then
				return xilian_data.xilian_slot_open_falg[32 - k] == 0
			end
		end
	end

	return is_can
end

function BeautyData:ItemJump()
	for k,v in pairs(self:GetBeautyInfo()) do
		if v.is_active == 1 and v.is_active_shenwu == 0 then
			return k - 1 ,0
		end
	end
	for k,v in pairs(self.huanhua_item_list) do
		if v.level > 0 and v.is_active_shenwu == 0 then
			return k - 1 ,1
		end
	end
	return 0, 0
end