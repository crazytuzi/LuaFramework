--------------------------------------------------------
-- 探索宝藏Data 配置 dream
--------------------------------------------------------

ExploreData = ExploreData or BaseClass()

--最大背包格子
ExploreData.MaxBagCell = 620

ExploreData.EXPLORE_SCORE_CHANGE = "explore_score_change"
ExploreData.EXPLORE_RECORD_CHANGE = "explore_record_change"
ExploreData.WEAR_HOUSE_DATA_CHANGE = "wear_house_data_change"
ExploreData.CREATE_RESULTS_CHANGE = "create_results_change"
ExploreData.RARE_REASURE = "rare_reasure"

function ExploreData:__init()
	if ExploreData.Instance then
		ErrorLog("[ExploreData]:Attempt to create singleton twice!")
	end
	ExploreData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.exploredata = {
		bz_score = 0,
		dh_type = 0,
		dh_index = 0,
		own_all_num = 0,
	}

	self.pro_list = {
		own_rew_num = 0,
		own_xb_num = 0,
	}

	self.record_list = {
		world_record_list = {},
	}

	self.rew_list = {
		index = 0,
		xb_list = {},
		get_rew_info = {},
	}

	self.xb_time = 0

	self.rareplace_data = {
		lhmb_enter_num = 0, 	-- 每天龙皇秘宝已进入次数
		lhmb_buy_num = 0, 		-- 每天龙皇秘宝购买次数
	}

	self.rare_treasure_data = {} --龙皇宝藏数据
	self.storage_page_list = {}		--存储页面列表
	self.storage_list = {}			--仓库列表
	self.broadcast_t = {}
	self.my_world_record_list = {}
	self.create_results = nil
	self.is_vis = false

	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.CanDiamondsCreate, true)  		-- 是否可兑换
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.CanExploreXunbao, true) 		-- 是否可寻宝
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.ExploreOwn, true) 				-- 是否可领取个人奖励
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.ExploreRareTreasure, true) 		-- 寻宝-龙皇秘宝可抽奖
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.ExploreRareplace, true) 			-- 寻宝-龙皇秘境有boss可击杀

	-- 背包数据监听
	BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagDataChange))
end

function ExploreData:__delete()
	ExploreData.Instance = nil
end

--得到寻宝数据
function ExploreData:GetXunBaoData()
	return self.exploredata
end

--设置寻宝记录
function ExploreData:SetXunBaoRecord(protocol)
	local data = {}
	data.bool_add = protocol.bool_add
	if data.bool_add ~= 1 then
		self.record_list.world_record_list = {}
	end
	if data.bool_add ~= 0 then
		self.personal_record_list = protocol.record_list
		for k,v in pairs(protocol.record_list) do
			table.insert(self.record_list.world_record_list, 1, v)
			if data.bool_add == 1 and v.need_broadcast == 1 then
				self:AddXunbaoBroadcast(v)
			end
			if data.bool_add == 1 and v.role_name == Scene.Instance:GetMainRole():GetName() then 
				self:AddMyWordXunBaoRecord(v)
			end
		end
		if #self.record_list.world_record_list > 50 then
			table.remove(self.record_list.world_record_list)
		end
	end
	self:DispatchEvent(ExploreData.EXPLORE_RECORD_CHANGE)
end

--添加寻宝广播
function ExploreData:AddXunbaoBroadcast(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then 
		table.insert(self.broadcast_t, data)
		return 
	end
	local  color = string.format("%06x", item_cfg.color)
	local text = string.format(Language.XunBao.Broadcast, data.role_name, color, item_cfg.name, item_cfg.item_id)
	SysMsgCtrl.Instance:ExploreAllServerBroadcast(text)
end

--得到寻宝日志
function ExploreData:GetXunBaoRecord()
	return self.record_list
end

--打开项目显示
function ExploreData:IsOpenItemShow()
	for i,v in ipairs(self.record_list.world_record_list) do
		if v.role_name == Scene.Instance:GetMainRole():GetName() then 
			return true
		end
	end
	return false
end

--插入当前玩家世界寻宝日志
function ExploreData:AddMyWordXunBaoRecord(data)
	table.insert(self.my_world_record_list, data)
end

--取出当前玩家世界第一条寻宝日志
function ExploreData:GetMyWordXunBaoRecord()
	return table.remove(self.my_world_record_list, 1)
end

--得到所有的玩家世界寻宝日志
function ExploreData:GetAllMyWordXunBaoRecord()
	return self.my_world_record_list
end

--设置寻宝祝福数据
function ExploreData:SetXunBaoBlessing(protocol)
	self.exploredata.bz_score = protocol.bz_score
	self.exploredata.own_all_num = protocol.own_all_num
	if protocol.lhmb_enter_num then
		self.rareplace_data.lhmb_enter_num = protocol.lhmb_enter_num 	-- 每天龙皇秘宝已进入次数
		self.rareplace_data.lhmb_buy_num = protocol.lhmb_buy_num 		-- 每天龙皇秘宝购买次数
	end
	self:DispatchEvent(ExploreData.EXPLORE_SCORE_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ExploreOwn)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ExploreRareTreasure)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ExploreRareplace)
end

-- 获取龙皇秘宝信息
function ExploreData:GetRareplaceData()
	return self.rareplace_data
end
-- 设置个人奖励数据
function ExploreData:SetOwnRewardData(protocol)
	self.pro_list.own_rew_num = protocol.own_rew_num
	self.pro_list.own_xb_num = protocol.own_xb_num
	
	self:DispatchEvent(ExploreData.EXPLORE_SCORE_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ExploreRareTreasure)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ExploreOwn)
end

--设置仓库数据
function ExploreData:SetWearHouseData(protocol)
	-- self.storage_list = {}
	for i, item in ipairs(protocol.storage_list) do
		local series = item.series or 0
		self.storage_list[series] = item
	end

	self:DispatchEvent(ExploreData.WEAR_HOUSE_DATA_CHANGE)
end

-- 设置寻宝仓库
function ExploreData:SetXunBaoBag(protocol)
	for k, series in pairs(protocol.item_list) do
		self.storage_list[series] = nil
	end

	self:DispatchEvent(ExploreData.WEAR_HOUSE_DATA_CHANGE)
end

-- 寻宝仓库增加物品
function ExploreData:ExploreStorageAddItem(item)
	local series = item.series or 0
	self.storage_list[series] = item
end

--获取寻宝仓库列表 未调用
function ExploreData:GetXBStorageList()
	return self.storage_list
end

--得到寻宝仓库所有数据
function ExploreData:GetWearHouseAllData()
	return self.SortWearHouseList(self.storage_list)
end

-- 排序寻宝仓库物品表
function ExploreData.SortWearHouseList(wearhouse_list)
	local index = 1
	local list = {}
	for k, v in pairs(wearhouse_list) do
		list[index] = v
		index = index + 1
	end

	table.sort(list, ExploreData.SortItemListFunc)
	list[0] = table.remove(list, 1)

	return list
end

local a_type, b_type = 0, 0
local a_level, a_zhuan = 0, 0
local b_level, b_zhuan = 0, 0
function ExploreData.SortItemListFunc(a, b)
	-- 按类型排
	a_type = ExploreData.GetItemIntervalNum(a.type)
	b_type = ExploreData.GetItemIntervalNum(b.type)

	if a_type < b_type then
		return true
	elseif a_type == b_type then
		a_level, a_zhuan = ItemData.GetItemLevel(a.item_id)
		b_level, b_zhuan = ItemData.GetItemLevel(b.item_id)
		if a_zhuan > b_zhuan then
			return true
		elseif a_zhuan == b_zhuan then
			if a_level > b_level then
				return true
			elseif a_level == b_level then
				if a.item_id > b.item_id then
					return true
				end
			end
		end
	end
	return false
end

-- 排序顺序 1.类型100以上 2.类型10-99 3.类型1-9
function ExploreData.GetItemIntervalNum(item_type)
	if item_type > 0 and item_type < 10 then
		return 3
	elseif item_type > 10 and item_type < 100 then
		return 2
	else
		return 1
	end
	return 0
end

--获取寻宝需要显示的物品
function ExploreData.GetDreamData()
	--获取显示配置
	local show_cfg = ConfigManager.Instance:GetConfig("scripts/config/client/dream")
	local list = {}
	local index = 1--math.max(RoleData.Instance:GetRoleBaseProf(), 1)	--获取角色基础职业,默认是战士
	local open_days = OtherData.Instance:GetOpenServerDays()
	for k, v in pairs(show_cfg) do
		if v.open_day[1] <= open_days and v.open_day[2] > open_days then
			index = k
		end
	end

	--获取角色转数,限制最大不能超过装备的最高转数
	local turn_num = math.min(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE), #show_cfg[1] - 1) 

	-- 获取对应职的转生装备,角色转数0至12,对应的索引是1至13
	for i = 1, 13 do
		list[i] = show_cfg[index][turn_num + 1][i]
	end
	-- 获取传世装备和热血装备
	-- for _, v in pairs(show_cfg[4]) do
	-- 	list[#list + 1] = v
	-- end
	return list
end

--得到开服第几天的显示
function ExploreData.GetDreamList(group_id)
	local group_id = group_id or -1
	local open_server_days = OtherData.Instance:GetOpenServerDays()
	local prof = RoleData.Instance:GetRoleBaseProf()

	local list = {}
	local cur_open_day = 0
	local max_group_id = 1
	for _, v in pairs(DreamConfig) do
		if open_server_days >= v.openServerDay and prof == v.prof then
			if cur_open_day < v.openServerDay then
				cur_open_day = v.openServerDay
				list = {}
				max_group_id = 1
			end
			if v.showGroup > max_group_id then
				max_group_id = v.showGroup
			end
			if group_id == v.showGroup then
				table.insert(list, v)
			end
		end
	end
	return list, max_group_id
end

--设置打造结果
function ExploreData:SetCreateResults(protocol)
	local item_id = protocol.item_id
	self.create_results = item_id ~= 0
	self:DispatchEvent(ExploreData.CREATE_RESULTS_CHANGE)
end

--获取打造结果
function ExploreData:GetCreateResults()
	return self.create_results
end

-- 获取兑换结果
function ExploreData:SetExchangeResult(protocol)
	self.exploredata.bz_score = protocol.xb_score
	-- self.exploredata.dh_type = protocol.dh_type
	-- self.exploredata.dh_index = protocol.dh_index

	self:DispatchEvent(ExploreData.EXPLORE_SCORE_CHANGE)
end

function ExploreData:SetXunBaoInfo(protocol)
	self.exploredata.bz_score = protocol.xunbao_jifen

	self:DispatchEvent(ExploreData.EXPLORE_SCORE_CHANGE)
end

-- 获取全服信息 
function ExploreData:SetWorldData(protocol)
	self.xb_time = protocol.xb_time

	self.rew_list.index = protocol.index
	self.rew_list.xb_list = protocol.xb_list
	self.rew_list.get_rew_info = protocol.rew_data

	self:DispatchEvent(ExploreData.EXPLORE_SCORE_CHANGE)
end

function ExploreData:GetWorldTime()
	local index = 0
	if self.rew_list.index > 1 then
		for i= 1, self.rew_list.index-1 do
			index = index + DmkjConfig.fullSvrAwards[i].dmTimes
		end
	end
	return self.xb_time + index
end

function ExploreData:GetWoeldList()
	return self.rew_list
end

----------红点提示----------

function ExploreData.OnBagDataChange()
	RemindManager.Instance:DoRemindDelayTime(RemindName.CanDiamondsCreate)
	RemindManager.Instance:DoRemindDelayTime(RemindName.CanExploreXunbao)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ExploreOwn)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ExploreRareTreasure)
end

-- 获取提醒显示索引 0不显示红点, 1显示红点
function ExploreData.GetRemindIndex(remind_name)
	if remind_name == RemindName.CanDiamondsCreate then
		return ExploreData.Instance.GetIsDuihuan()
	elseif remind_name == RemindName.CanExploreXunbao then
		return ExploreData.Instance.GetXunbaoRemindIndex()
	elseif remind_name == RemindName.ExploreOwn then
		return ExploreData.Instance:GetOwnRewardState()
	elseif remind_name == RemindName.ExploreRareTreasure then
		return ExploreData.Instance:GetRareTreasureRemind() + ExploreData.Instance:GetOwnRewardState()
	elseif remind_name == RemindName.ExploreRareplace then
		return ExploreData.Instance.GetRareplaceRemind()
	end
end

-- 获取是否可兑换
function ExploreData.GetIsDuihuan()
	local vis = false
	for i = 1, #TreasureIntegral do
		vis = ExploreData.Instance:GetTabbarremind(i)
		if vis then break end
	end
	local index = vis and 1 or 0
	
	return index
end

function ExploreData.GetXunbaoRemindIndex()
	local item_num = BagData.Instance:GetItemNumInBagById(DmkjConfig.Treasure[1].item.id, nil)
	local needYb = item_num * 200
	local ys_yb = DmkjConfig.moneys.count
	local index = needYb >= DmkjConfig.Treasure[1].count * ys_yb and 1 or 0
	index = needYb >= DmkjConfig.Treasure[2].count * ys_yb and 2 or index
	index = needYb >= DmkjConfig.Treasure[3].count * ys_yb and 3 or index

	return index
end

function ExploreData:GetOwnRewardList()
	local reward_list = self:GetXunBaoRecord()
	local own_list = {}
	if reward_list.world_record_list then
		for k,v in pairs(reward_list.world_record_list) do
			if v.role_name == Scene.Instance:GetMainRole():GetName() then
				table.insert(own_list, v)
			end
		end
	end
	if #own_list > 50 then
		table.remove(own_list, #own_list)
	end		
	return own_list
end

-- 获取兑换列表
function ExploreData:GetExchangeList(index)
	local data = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local open_days = OtherData.Instance:GetOpenServerDays()
	for k, v in pairs(TreasureIntegral) do
		if k == index then
			for _, v2 in pairs(v.ExChangeData) do
				local vo = {}
				if (nil == v2.sex or v2.sex == role_sex) and (nil == v2.needOpendays or v2.needOpendays <= open_days) then 
					vo.item_id = v2.award[1].id
					vo.num = v2.award[1].count
					vo.is_bind = v2.award[1].bind
					vo.score = v2.needScore
					vo.index = v.type
					vo.consume = v2.consume
					vo.id = v2.id
				end
				table.insert(data, vo)
			end
		end
	end
	return data
end

-- 获取男女衣服兑换配置
function ExploreData:GetEquipExchangeList()
	local data = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local open_days = OtherData.Instance:GetOpenServerDays()
	local cfg = TreasureIntegral and TreasureIntegral[3] or {}
	for _, v2 in pairs(cfg.ExChangeData) do
		local vo = {}
		if (nil == v2.sex or v2.sex == role_sex) and (nil == v2.needOpendays or v2.needOpendays <= open_days) then 
			local index = v2.consume and v2.consume[1] and v2.consume[1].id or 0

			vo.award = ItemData.InitItemDataByCfg(v2.award[1])
			vo.score = v2.needScore
			vo.consume = v2.consume
			vo.id = v2.id

			data[index] = vo
		end
	end
	return data
end

function ExploreData:GetTabbarremind(index)
	local xunbao_jifen = self.exploredata.bz_score
	local is_remind = false
	for k, v in pairs(TreasureIntegral[index].ExChangeData) do
		if index == 5 then
			is_remind = xunbao_jifen >= v.needScore
			if is_remind then break end
		elseif index == 3 then
			is_remind = false
		elseif index == 6 then
			local n = BagData.Instance:GetItemNumInBagById(v.consume[1].id, nil)
			is_remind = n >= v.consume[1].count and xunbao_jifen >= v.needScore
			if is_remind then break end
		else
			local item_cfg = ItemData.Instance:GetItemConfig(v.consume[1].id)
			local is_better, eq_cfg, eq_data, equip_slot = false, nil, nil, nil
			if ItemData.IsBaseEquipType(item_cfg.type) or ItemData.IsPeerlessEquip(item_cfg.type) or ItemData.IsRexue(item_cfg.type) then
				is_better, hand_pos, equip_slot = EquipData.Instance:GetIsBetterEquip(item_cfg)
			end
			if is_better then
				local n = BagData.Instance:GetItemNumInBagById(v.consume[1].id, nil)
				is_remind = n >= v.consume[1].count and xunbao_jifen >= v.needScore
				if is_remind then break end
			end
		end
	end
			
	return is_remind
end

function ExploreData:GetTimeList(index)
	local data = {}
	if self.rew_list.index == index then
		if #self.rew_list.get_rew_info == 5 then
			data = self:GetPrizeInfo(index)
		else
			data = self.rew_list.xb_list
		end
	else
		data = self:GetPrizeInfo(index)
	end
	return data
end

function ExploreData:GetPrizeInfo(index)
	local data = {}
	for k, v in pairs(self.rew_list.get_rew_info) do
		if v.rew_type == index then
			table.insert(data, v)
		end
	end
	return data
end

-- 获取当前档位参与状态
function ExploreData:GetNowIndexState()		
	if #self.rew_list.get_rew_info == 5 then return end
	for k, v in pairs(self.rew_list.xb_list) do
		if v.role_name == Scene.Instance:GetMainRole():GetName() then
			return v.xb_num
		end
	end

	return 0
end

-- 获取每个档位的次数
function ExploreData:GetExploreTime()
	local data = {}
	local time = 0
	
	for i = 1, #DmkjConfig.fullSvrAwards do
		time = time + DmkjConfig.fullSvrAwards[i].dmTimes
		table.insert(data, time)
	end

	return data
end

----------------- 寻宝tip（暂时无用）  -------------
-- 获取是否勾选
function ExploreData:GetIsCheckBox(is_vis)
	self.is_vis = is_vis
end

function ExploreData:GetIsVisTip()
	return self.is_vis
end
---------------------end-------------------------------

-- 获取个人奖励领取状态
function ExploreData:GetOwnRewardState()
	
	local remind = 0
	local own_xb_num = self.pro_list.own_xb_num
	for k, v in pairs(DmkjConfig.individualCfg) do
		local state = bit:_and(1, bit:_rshift(self.pro_list.own_rew_num, k - 1))
		if own_xb_num >= v.dmTimes and state == 0 then
			remind = 1
			break
		end
	end
	return remind
end

-- 获取当前阶段次数
function ExploreData:GetNowTime()
	local index = 0
	for i= 1, self.rew_list.index do
		index = index + DmkjConfig.fullSvrAwards[i].dmTimes
	end
	return index
end

-- 获取当前档次与前一次档次之差
function ExploreData:GetIndexSubtract()
	local now_time = self:GetNowTime()
	local up_time = 0
	if self.rew_list.index > 1 then
		for i = 1, self.rew_list.index-1 do
			up_time = up_time + DmkjConfig.fullSvrAwards[i].dmTimes
		end
	end
	return now_time - up_time
end

-- 获取全服次数奖励
function ExploreData:GetWorldRewItem()
	local function sort_rewitem()
		return function(a, b)
			if a.own_state ~= b.own_state then
				return a.own_state < b.own_state
			else
				return a.index < b.index
			end
		end
	end
	
	local data = {}
	for k, v in pairs(DmkjConfig.individualCfg) do
		local vo = {}
		vo.index = k
		vo.num = v.dmTimes
		vo.own_xb_num = self.pro_list.own_xb_num
		vo.own_state = bit:_and(1, bit:_rshift(self.pro_list.own_rew_num, k - 1))
		vo.item = {item_id = v.awards[1].id, num = v.awards[1].count, is_bind = v.awards[1].bind}
		table.insert(data, vo)
	end

	table.sort(data, sort_rewitem())

	return data
end

-- 设置龙皇宝藏数据
function ExploreData:SetRareTreasureData(protocol)
	-- self.rare_treasure_data.strat_time = protocol.strat_time
	self.rare_treasure_data.end_time = protocol.end_time
	self.rare_treasure_data.award_pools_index = protocol.award_pools_index
	self.rare_treasure_data.record_list = protocol.record_list
	self.rare_treasure_data.explore_times = protocol.explore_times
	self.rare_treasure_data.award_times = protocol.award_times
	self.rare_treasure_data.award_tag = bit:d2b(protocol.award_tag)
	self.rare_treasure_data.award_index = protocol.award_index

	self:DispatchEvent(ExploreData.RARE_REASURE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ExploreRareTreasure)
	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:Fire(MainUIEventType.UPDATE_BRILLIANT_ICON) -- 刷新主界面图标
		GlobalEventSystem:Fire(MainUIEventType.UPDATE_RARETREASURE_ICON)
	end, 1)

	-- if protocol.award_index > 0 then
	-- 	ExploreCtrl.Instance:SendReturnWarehouseDataReq()
	-- end
end

function ExploreData:GetRareTreasureData()
	return self.rare_treasure_data or {}
end

-- 获取龙魂秘境配置
function ExploreData.GetRareplaceCfg()
	local cfg = DmkjConfig.LoongDmCfg.LoongKingTreasureTroveCfg or {}
	local scene_cfg = cfg.LoongSceneCfg or {}
	return cfg, scene_cfg
end

function ExploreData:GetRareTreasureCfg()
	if nil == self.raretreasure_cfg  then
		self.raretreasure_cfg = require("scripts/config/server/config/dmkj/LoongDmPool/loongdmpool")
	end

	return self.raretreasure_cfg
end


-- 获取龙皇秘宝提醒
function ExploreData:GetRareTreasureRemind()
	local index = 0
	local times = self.rare_treasure_data.award_times or 0
	if type(self.rare_treasure_data.award_tag) == "table" and times > 0 then
		local cfg = ExploreData.Instance:GetRareTreasureCfg()
		local cur_cfg = cfg[self.rare_treasure_data.award_pools_index or 1] or {}
		for i = 1, #(cur_cfg.awardpool or {}) do
			local boor = self.rare_treasure_data.award_tag[33-i] == 0
			if boor then
				index = 1
				break
			end
		end
	end

	return index
end

-- 获取龙皇秘境提醒
function ExploreData.GetRareplaceRemind()
	local index = 0
	local cfg, data_list = ExploreData.GetRareplaceCfg()

	----------进入秘境剩于次数----------
	local rareplace_data = ExploreData.Instance:GetRareplaceData()
	local buy_num = rareplace_data.lhmb_buy_num or 0 		-- 购买次数
	local enter_num = rareplace_data.lhmb_enter_num or 0 	-- 已进入次数
	local max_free_times = cfg.maxFreeTms or 0 				-- 免费次数
	local left_times = max_free_times + buy_num - enter_num -- 进入秘境剩于次数
	------------------------------------

	if left_times >= 1 then
		local own_all_num = ExploreData.Instance:GetXunBaoData().own_all_num or 0 -- 总寻宝次数
		for i,v in ipairs(data_list) do
			local open_explore_times = v.openDmTms or 0 -- 开放所需寻宝次数
			if own_all_num >= open_explore_times then -- 当前秘境已开放
				local boss_id = v.boss_id or 0
				local boss_list = BossData.Instance:GetSceneBossListByType(BossData.BossTypeEnum.SECRET_BOSS)
				local cur_boss = boss_list[boss_id] or {}
				local left_time = (cur_boss.now_time or 0) + (cur_boss.refresh_time or 0) - Status.NowTime
				if left_time <= 0 then
					index = 1
					break
				end
			end
		end
	end

	return index
end
