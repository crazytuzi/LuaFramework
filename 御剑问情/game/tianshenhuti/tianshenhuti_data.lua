TianshenhutiData = TianshenhutiData or BaseClass(BaseEvent)

TIANSHENHUTI_REQ_TYPE =
	{
		PUT_ON = 0,										-- 穿上装备-背包下标
		TAKE_OFF = 1,									-- 脱下装备-装备部位下标
		TRANSFORM = 2,									-- 转化装备-2个背包下标
		COMBINE = 3,									-- 合成装备-3个背包下标
		ROLL = 4,										-- 天神附体抽奖
		QUICK_COMBINE = 5,								-- 一键合成
	}
TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT = "compose_select_change_event"	--合成选择改吧
function TianshenhutiData:__init()
	if TianshenhutiData.Instance then
		print_error("[TianshenhutiData] Attempt to create singleton twice!")
		return
	end
	TianshenhutiData.Instance = self
	self.equip_list = {}
	self.backpack_list_t = {}
	self.has_slot_t = {}
	self.backpack_item_info = {}
	self.backpack_bag_info = {}
	self.backpack_list = {}
	self.weekend_boss_info = {}
	self.big_boss_info = {}
	self.boss_info = {}

	self.big_boss_refresh_time = 0
	self.boss_count = 0
	self.boss_refresh_time = 0
	self.boss_type = 0
	self.next_refresh_time = 0
	self.free_flag = 0
	self.next_free_roll_time = 0
	self.bag_list_cont = 0
	self.roll_score = 0
	self.accumulate_roll_times = 0
	 self.boss_personal_hurt_info = {
        my_hurt = 0,
        self_rank = 0,
        rank_count = 0,
        rank_list = {},
    }

	self.equip_cfg = ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").equip_info
	self.zhekou_cfg = ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").discount_cfg
	self.reward_cfg = ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").accumulate_reward_cfg
	self.skill_time_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto").normal_skill
	self.equip_skill_cfg = ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").taozhaung_skill_cfg
	self.other_cfg = ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").other[1]
	self.equip_id_cfg = ListToMap(self.equip_cfg, "equip_id")
	self.equip_level_cfg = ListToMapList(self.equip_cfg, "level")
	self.taozhuang_type_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").taozhuang_type, "taozhuang_type")
	for k,v in pairs(self.taozhuang_type_cfg) do
		self.backpack_list_t[v.taozhuang_type] = {}
	end
	self.taozhuang_info_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").taozhuang_info, "level_taozhuang_type")

	self.weekend_boss_cfg = ConfigManager.Instance:GetAutoConfig("weekend_boss_cfg_auto")
	self.weekend_boss_id_cfg = ListToMapList(self.weekend_boss_cfg.boss_cfg, "boss_type", "boss_id_1")
	self.monster_info = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.compose_select_list = {}
	self:AddEvent(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT)
	RemindManager.Instance:Register(RemindName.Tianshenhuti, BindTool.Bind(self.GetTianshenhutiRemind, self))
	RemindManager.Instance:Register(RemindName.TianshenhutiBox, BindTool.Bind(self.GetTianshenhutiBoxRemind, self))
end

function TianshenhutiData:__delete()
	TianshenhutiData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.Tianshenhuti)
	RemindManager.Instance:UnRegister(RemindName.TianshenhutiBox)
	self:CancelBoxTimer()
end

function TianshenhutiData:GetWeekendBossCfg()
	return self.weekend_boss_cfg
end

function TianshenhutiData:GetMonsterCfg()
	return self.monster_info
end

function TianshenhutiData:SetTianshenhutiALlInfo(protocol)
	self.equip_list = protocol.equip_list
	self.free_flag = protocol.free_flag
	self.next_free_roll_time = protocol.next_free_roll_time
	self.backpack_list = protocol.backpack_list
	self.roll_score = protocol.roll_score
	self.accumulate_roll_times = protocol.accumulate_roll_times
    local equio_cfg = nil
    for k,v in pairs(self.backpack_list_t) do
    	self.backpack_list_t[k] = {}
    end

    table.sort(self.backpack_list, TianshenhutiData.SortEquip())

    for k,v in ipairs(self.backpack_list) do
    	equio_cfg = self.equip_cfg[v.item_id]
    	if equio_cfg and self.backpack_list_t[equio_cfg.taozhuang_type] then
    		local vo = self.backpack_list_t[equio_cfg.taozhuang_type]
    		table.insert(vo, v)
    		self.has_slot_t[equio_cfg.slot_index] = true
    	end
    end
	MainUICtrl.Instance:FlushView("zhoumo_equip")
end

local eq_cfg = nil
function TianshenhutiData.SortEquip()
	return function(a, b)
		eq_cfg = eq_cfg or ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").equip_info
		if eq_cfg[a.item_id] == nil or eq_cfg[b.item_id] == nil then
			return false
		end
		if eq_cfg[a.item_id].level > eq_cfg[b.item_id].level then
			return true
		elseif eq_cfg[a.item_id].level == eq_cfg[b.item_id].level then
			return eq_cfg[a.item_id].slot_index < eq_cfg[b.item_id].slot_index
		else
			return false
		end
	end
end

function TianshenhutiData:GetFreeTimes()
	return self.free_flag
end

function TianshenhutiData:GetNextFlushTime()
	return self.next_free_roll_time
end

function TianshenhutiData:GetEquipList()
	return self.equip_list
end
function TianshenhutiData:GetTaoZhuangType()
	local type_index = 0
	local index_num = 0
	local need_skill_level = self.other_cfg.taozhuang_skill_need_level
	-- local level_type = 0
	if nil == self.equip_list or nil == next(self.equip_list) then
		return 0
	end
	for k, v in pairs(self.equip_list) do
		index_num = index_num + 1
		if self.equip_id_cfg[v.item_id] and self.equip_id_cfg[v.item_id].level >= need_skill_level then
			type_index = type_index + self.equip_id_cfg[v.item_id].taozhuang_type
			-- level_type = self.equip_id_cfg[v.item_id].level_taozhuang_type
		else
			return 0
		end
	end
	if index_num < 8 then 				--小于8件代表没有集齐8件
		return 0
	end
	if type_index == 8 then 			--type_index = 8,说明集齐8件类型1的套装
		return 1
	elseif type_index == 16 then  		--type_index = 16,说明集齐8件类型2的套装
		return	2
	elseif type_index == 24 then 		--type_index = 24,说明集齐8件类型3的套装
		return 3
	end
	return 0
end
function TianshenhutiData:GetTaoZhuangSkillID()
	local index_num = 0
	index_num = self:GetTaoZhuangType()
	if index_num == 0 then
		return 0
	else
		if self.equip_skill_cfg[index_num - 1] then
			return self.equip_skill_cfg[index_num - 1].active_skill_id
		else
			return 0
		end
	end
end
function TianshenhutiData:GetTaoZhuangSkillCfg()
	return self.equip_skill_cfg
end
function TianshenhutiData:GetSkillTimeInfo(id)
	if self.skill_time_cfg[id] then
		return self.skill_time_cfg[id].cd_s or 0
	else
		return 0
	end
end
function TianshenhutiData:GetRewardItemCfg()
	local vip_level = PlayerData.Instance:GetRoleVo().vip_level
	local show_list = {}
	local other_cfg = self.reward_cfg
	local num = self:GetRewardTimes()
	if other_cfg == nil then
		return show_list
	end
	local other_day = self:GetShowOtherDay()
	for i, v in ipairs(other_cfg) do
		if v.opengame_day == other_day then
			table.insert(show_list, TableCopy(v))
			show_list[#show_list].sort_value = num >= v.accumulate_times and 1 or 0
		end
	end
	table.sort(show_list, SortTools.KeyLowerSorter("sort_value", "index"))
	return show_list
end
function TianshenhutiData:GetShowOtherDay()
	local week_number = tonumber(os.date("%w", TimeCtrl.Instance:GetServerTime()))
	local open_time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local other_cfg = self.reward_cfg
	local other_day = other_cfg[1].opengame_day
	for i, v in ipairs(other_cfg) do
		if week_number == 6 then
			if open_time_day <= v.opengame_day then
				other_day = v.opengame_day
				return other_day
			end
		elseif week_number == 0 then
			if open_time_day - 1 <= v.opengame_day then
				other_day = v.opengame_day
				return other_day
			end
		end
	end
	return other_day
end

function TianshenhutiData:GetBagList()
	return self.backpack_list
end

function TianshenhutiData:GetBagListByType(tz_zype)
	return self.backpack_list_t[tz_zype] or self.backpack_list
end

function TianshenhutiData:GetMaxLevel()
	return #self.equip_level_cfg
end

-- 获取当前装备总属性
function TianshenhutiData:GetProtectEquipTotalAttr()
	local total_attribute = CommonStruct.Attribute()			--记录总属性
	for k,v in pairs(self.equip_list) do
		local cfg = self:GetEquipCfg(v.item_id) or {}
		local attribute = CommonDataManager.GetAttributteByClass(cfg)
		total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)
	end
	return total_attribute
end

-- 获取当前装备总战力  （加套装加成）
function TianshenhutiData:GetProtectEquipTotalCapability()
	local total_attribute = self:GetProtectEquipTotalAttr()
	if nil == total_attribute then return end

	-- 套装加成
	local cur_taozhuang_list = self:GetCurAllTaozhuang()
	for k,v in pairs(cur_taozhuang_list) do
		local attribute = self:GetTzAllAttr(v.level_taozhuang_type, v.num)
		total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)
	end

	local capability = CommonDataManager.GetCapability(total_attribute)
	return capability
end

-- 获取当前有哪些套装加成
function TianshenhutiData:GetCurAllTaozhuang()
	local list = {}
	for k,v in pairs(self.equip_list) do
		local cfg = self:GetEquipCfg(v.item_id)
		if cfg then
			list[cfg.taozhuang_type] = list[cfg.taozhuang_type] or {}
			local tz_info = list[cfg.taozhuang_type]
			if tz_info[cfg.level_taozhuang_type] then
				tz_info[cfg.level_taozhuang_type] = tz_info[cfg.level_taozhuang_type] + 1
			else
				tz_info[cfg.level_taozhuang_type] = 1
			end
		end
	end

	local cur_taozhuang_list = {}
	for k,v in pairs(list) do 		--k:tz_type v:tz_info
		for x,y in pairs(v) do 		--x:level_taozhuang_type 	y:num 次数
			if self.taozhuang_info_cfg[x] and self.taozhuang_info_cfg[x][1]and y >=self.taozhuang_info_cfg[x][1].level_taozhuang_num then
				local tz_info = {}
				tz_info.tz_type = k
				tz_info.level_taozhuang_type = x
				tz_info.num = y
				table.insert(cur_taozhuang_list, tz_info)
			end
		end
	end

	return cur_taozhuang_list
end

function TianshenhutiData:GetBossID(boss_type)
	local data = self:GetWeekendBossCfg().boss_cfg
	local world_level = RankData.Instance:GetWordLevel()

	for k, v in pairs(data) do
		if boss_type == v.boss_type and world_level >= v.world_level_min and world_level <= v.world_level_max then
			return v.boss_id_1 or 0
		end
	end
end

-- 根据套装类型和阶数和数量获取最高那套套装属性配置
function TianshenhutiData:GetTzCfg(level_taozhuang_type, num)
	local tz_cfg = {}
	if level_taozhuang_type == nil or num == nil or self.taozhuang_info_cfg[level_taozhuang_type] == nil then
		return tz_cfg
	end

	for i,v in ipairs(self.taozhuang_info_cfg[level_taozhuang_type]) do
		if num >= v.level_taozhuang_num and (tz_cfg.level_taozhuang_num == nil or tz_cfg.level_taozhuang_num < v.level_taozhuang_num) then
			tz_cfg = v
		end
	end
	return tz_cfg
end

-- 根据套装类型和阶数和数量获取套装属性
function TianshenhutiData:GetTzAllAttr(level_taozhuang_type, num)
	local total_attribute = CommonStruct.Attribute()
	local rate_injure = 0
	if level_taozhuang_type == nil or num == nil or self.taozhuang_info_cfg[level_taozhuang_type] == nil then
		return total_attribute, rate_injure
	end

	for i,v in ipairs(self.taozhuang_info_cfg[level_taozhuang_type]) do
		if num >= v.level_taozhuang_num then
			local attribute = CommonDataManager.GetAttributteByClass(v)
			total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)
			rate_injure = rate_injure + v.rate_injure
		end
	end
	return total_attribute, rate_injure
end

function TianshenhutiData:GetRollScore()
	return self.roll_score
end

function TianshenhutiData:SetTianshenhutiScore(score)
	self.roll_score = score
end

function TianshenhutiData:GetRewardTimes()
	return self.accumulate_roll_times or 0
end
function TianshenhutiData:GetBoxZheKou()
	return self.zhekou_cfg[0].discount_percent
end
function TianshenhutiData:GetTaozhuangLevelTypeHas(tz_lv_type)
	local count = 0
	local cfg = nil
	for k,v in pairs(self.equip_list) do
		cfg = self.equip_cfg[v.item_id]
		if cfg and cfg.level_taozhuang_type == tz_lv_type then
			count = count + 1
		end
	end
	return count
end

function TianshenhutiData:GetTaozhuangLevelTypeCfg(tz_lv_type)
	return self.taozhuang_info_cfg[tz_lv_type]
end

function TianshenhutiData:GetTaozhuangTypeName(tz_type)
	if self.taozhuang_type_cfg[tz_type] then
		return self.taozhuang_type_cfg[tz_type].taozhuang_name
	end
	return ""
end

function TianshenhutiData:IsBetterEquip(item_id)
	if item_id == nil or self.equip_cfg[item_id] == nil then
		return false
	end --不存在

	local item_cfg = self.equip_cfg[item_id]
	local equip_info = self.equip_list[item_cfg.slot_index]
	if equip_info == nil or equip_info.item_id <= 0 then return true end --该部位未装备

	local equip_cfg = self.equip_cfg[equip_info.item_id]
	if equip_cfg == nil then return true end

	return CommonDataManager.GetCapability(item_cfg, true, equip_cfg) > CommonDataManager.GetCapability(equip_cfg)
end

function TianshenhutiData:GetEquipCfg(equip_id)
	return self.equip_cfg[equip_id]
end

function TianshenhutiData:GetEquipName(equip_id)
	if self.equip_cfg[equip_id] then
		return self.equip_cfg[equip_id].name, self.equip_cfg[equip_id].color
	end
	return "", 1
end

function TianshenhutiData:GetBagListCount()
	return self.bag_list_cont or 0
end

function TianshenhutiData:GetTianshenhutiRemind()
	for i = 0, GameEnum.TIANSHENHUTI_EQUIP_MAX_COUNT - 1 do
		if not self.equip_list[i] and self.has_slot_t[i] then
			return 1
		end
	end
	return 0
end

function TianshenhutiData:GetTianshenhutiBoxRemind()
	local week_number = tonumber(os.date("%w", TimeCtrl.Instance:GetServerTime()))
	if 0 ~= week_number and 6 ~= week_number then
		self:CancelBoxTimer()
		return 0
	end
	local other_cfg = ConfigManager.Instance:GetAutoConfig("tianshenhuti_auto").other[1]
	if self.roll_score >= other_cfg.common_roll_cost or
		(other_cfg.free_times > self.free_flag and self.next_free_roll_time <= TimeCtrl.Instance:GetServerTime()) then
		self:CancelBoxTimer()
		return 1
	end
	--如果有计时免费则延迟到时间结束再提醒
	if other_cfg.free_times > self.free_flag and self.next_free_roll_time > TimeCtrl.Instance:GetServerTime() then
		if self.box_remind_timer == nil then
			self.box_remind_timer = GlobalTimerQuest:AddDelayTimer(function()
				self.box_remind_timer = nil
  	  			RemindManager.Instance:Fire(RemindName.TianshenhutiBox)
   			end, self.next_free_roll_time - TimeCtrl.Instance:GetServerTime())
		end
	else
		self:CancelBoxTimer()
	end
	return 0
end

function TianshenhutiData:CancelBoxTimer()
	if self.box_remind_timer then
			GlobalTimerQuest:CancelQuest(self.box_remind_timer)
			self.box_remind_timer = nil
		end
end

function TianshenhutiData:GetCanComposeDataList(is_compose)
	local data = nil
	local select_index_t = {}
	for k,v in pairs(self.compose_select_list) do
		select_index_t[v.index] = true
		if nil == data then
			data = v
		end
	end
	local list = {}
	local select_level = 0
	if data then
		local cfg = self.equip_cfg[data.item_id]
		select_level = cfg.level
	end
	local bag_cfg = nil
	for k,v in pairs(self.backpack_list) do
		if not select_index_t[v.index] then
			bag_cfg = self.equip_cfg[v.item_id]
			if bag_cfg and (select_level ==0 or bag_cfg.level ==select_level)
				and (not is_compose or bag_cfg.level < self:GetMaxLevel()) then
				if list[0] then
					table.insert(list, v)
				else
					 list[0] = v
				end
			end
		end
	end

	 self.bag_list_cont = #list
    if list[0] then
    	 self.bag_list_cont = self.bag_list_cont + 1
    end
    return list
end

function TianshenhutiData:SetWeekendBigBossInfo(protocol)
	self.big_boss_info = protocol.boss_info
end

function TianshenhutiData:SetWeekendBossInfo(protocol)
	self.boss_info = protocol.boss_info
	self.boss_refresh_time = protocol.next_refresh_time
end

function TianshenhutiData:GetComposeSelectList()
	return self.compose_select_list
end

function TianshenhutiData:GetBossRefreshTime()
	return self.boss_refresh_time
end

function TianshenhutiData:GetWeekendBigBossInfo()
	return self.big_boss_info
end

function TianshenhutiData:GetWeekendBossInfo()
	return self.boss_info
end

--获取某个boss信息
function TianshenhutiData:GetOneWeekendBossInfo(boss_id)
	for k, v in pairs(self.boss_info) do
		if v.boss_id == boss_id then
		 	return v
		 end
	end
	return nil
end

--随机返回一个可击杀boss
function TianshenhutiData:GetOneWeekendAliveBossInfo()
	local boss_list = {}
	for k, v in pairs(self.boss_info) do
		if v.boss_status == 1 then
		 	table.insert(boss_list, v)
		end
	end
	return boss_list[math.random(#boss_list)]
end

--获取可击杀boss数量
function TianshenhutiData:GetWeekendBossCount(scene_id)
	local boss_num = {}
	for k, v in pairs(self.boss_info) do
		if v.boss_status == 1 and (scene_id == nil or v.scene_id == scene_id) then
		 	table.insert(boss_num, v)
		end
	end

	return GetListNum(boss_num)
end

--大boss是否存在
function TianshenhutiData:HasWeekendBigBoss()
	if self.big_boss_info[1] and self.big_boss_info[1].boss_status == 1 then
		return true
	end
	return false
end
-----------------------合成或转换的装备选择-----------
function TianshenhutiData:GetComposeSelect(index)
	return self.compose_select_list[index]
end

function TianshenhutiData:ClearComposeSelectList()
	self.compose_select_list = {}
	self:NotifyEventChange(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT)
end

function TianshenhutiData:AddComposeSelect(index, data)
	self.compose_select_list[index] = data
	self:NotifyEventChange(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT, index)
end

function TianshenhutiData:DelComposeSelect(index)
	self.compose_select_list[index] = nil
	self:NotifyEventChange(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT, index)
end
------------------------------------------------

function TianshenhutiData:GetSkillByIndex(index)
	if self.skill_list == nil then
		self.skill_list = {}
		local prof = PlayerData.Instance:GetAttr("prof")
		local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
		local skillinfo = roleskill_auto.skillinfo
		for skill_id, v in pairs(skillinfo) do
			if prof == math.modf(skill_id / 100) then
				self.skill_list[v.skill_index] = v
			end
		end
	end
	return self.skill_list[index]
end

function TianshenhutiData:SetBossPersonalHurtInfo(protocol)
    self.boss_personal_hurt_info.my_hurt = protocol.my_hurt
    self.boss_personal_hurt_info.self_rank = protocol.self_rank
    self.boss_personal_hurt_info.rank_count = protocol.rank_count
    self.boss_personal_hurt_info.rank_list = protocol.rank_list
end

function TianshenhutiData:GetBossPersonalHurtInfo()
    return self.boss_personal_hurt_info
end

function TianshenhutiData:IsTshtBoss(boss_type, boss_id)
	if self.weekend_boss_id_cfg[boss_type] and self.weekend_boss_id_cfg[boss_type][boss_id] then
		return true
	end
	return false
end

function TianshenhutiData:GetAllBigBoss()
	return self.weekend_boss_id_cfg[0] or {}
end

function TianshenhutiData:GetBossStatu()
	local boss_info = self:GetWeekendBossInfo()
	local boss_list = {}

	for k, v in pairs(boss_info) do
		if v.boss_status == 1 then
			table.insert(boss_list, k)
		end
	end

	return boss_list
end

