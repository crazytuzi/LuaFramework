--------------------------------------------------------
-- 锻造-融合Data
--------------------------------------------------------

EquipmentFusionData = EquipmentFusionData or BaseClass()

function EquipmentFusionData:__init()
	if EquipmentFusionData.Instance then
		ErrorLog("[EquipmentFusionData]:Attempt to create singleton twice!")
	end
	EquipmentFusionData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex, self), RemindName.EquipmentFusion)
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))

	self.cricle_change_event = nil
	self.open_day_change_event = nil
	self.change_one_equip_event = nil
	self.bag_item_change_event = nil

	self.put_on_slot = nil -- 刷新红点一次后,才进行优化
	self.open_1 = false
	self.open_2 = false

	local item_type_list = EquipMeltCfg and EquipMeltCfg.item_type_list or {}
	self.item_type_list = {}
	self.all_item_type_list = {}
	for i, list in ipairs(item_type_list) do
		self.item_type_list[i] = {}
		for i2, _type in ipairs(list) do
			self.item_type_list[i][_type] = true
		end
	end
end

function EquipmentFusionData:__delete()
	EquipmentFusionData.Instance = nil
end

----------设置----------

-- 获取装备融合等级
function EquipmentFusionData.GetFusionLv(item_data)
	local fusion_lv = 0
	if type(item_data) == "table" and type(item_data.fusion_lv) == "number" then
		fusion_lv = item_data.fusion_lv
	end
	return fusion_lv
end

-- 设置装备融合等级 用于面板"锻造-融合"的装备预览
function EquipmentFusionData.SetFusionLv(item_data, fusion_lv)
	if type(item_data) == "table" and type(fusion_lv) == "number" then
		item_data.fusion_lv = fusion_lv
	end
end

-- 获取装备融合属性文本 用于装备Tips显示
function EquipmentFusionData.GetFusionText(equip)
	local text = ""
	local fusion_type = ItemData.GetIsBasisEquip(item_id) and 1 or 2 -- 融合类型
	local cfg = EquipMeltCfg or {}
	local meltcfg = cfg.meltcfg and cfg.meltcfg[fusion_type] or {}
	local cur_fusion_lv = EquipmentFusionData.GetFusionLv(equip)
	for fusion_lv, v in ipairs(meltcfg) do
		if type(v.attrrate) == "number" then
			local color = cur_fusion_lv >= fusion_lv and COLORSTR.PURPLE2 or COLORSTR.GRAY
			local attrrate = v.attrrate / 100
			text = text .. string.format(Language.Equipment.FusionText, color, fusion_lv, attrrate)
			if fusion_lv < #meltcfg then
				text = text .. "\n"
			end
		end
	end

	return text
end

function EquipmentFusionData:GetItemTypeList()
	return self.item_type_list
end

function EquipmentFusionData:GetAllBagEquip()
	local meltcfg = EquipMeltCfg and EquipMeltCfg.meltcfg or {}
	local circle_cfg = meltcfg[1] and meltcfg[1][1] and meltcfg[1][1].circleLimit or 999

	local list_1, list_2 = {}, {}
	local bag_list = BagData.Instance:GetDataListSeries()
	for series, item in pairs(bag_list) do
		local item_type = item.type or -1
		if self.item_type_list[1] and self.item_type_list[1][item_type] then
			local item_id = item.item_id or 0
			local limit_level, circle = ItemData.GetItemLevel(item_id) -- 装备的等级和转数
			if circle >= circle_cfg then
				table.insert(list_1, item)
			end
		elseif self.item_type_list[2] and self.item_type_list[2][item_type] then
			table.insert(list_2, item)
		end
	end

	return list_1, list_2
end

-- 用于面板排序
function EquipmentFusionData.GetEquipType(item_id)
	local index = 0
	if ItemData.GetIsBasisEquip(item_id) then
		index = 0
	elseif ItemData.IsReXueEquip(item_id) then
		index = 1
	elseif ItemData.IsZhanShenEquip(item_id) then
		index = 2
	elseif ItemData.IsShaShenEquip(item_id) then
		index = 3
	end
	
	return index
end

-- type = 1基础融合 2热血融合
function EquipmentFusionData:StarSuitIndex(_type)
	local all_fusion_level = self:GetCurFusionLevel(_type)
	local cfg = MeltLevelSuitPlus and MeltLevelSuitPlus[_type] or {}
	local index = 0
	for i, v in ipairs(cfg.list or {}) do
		if all_fusion_level >= v.level then
			index = i
		end
	end

	return index, all_fusion_level
end

function EquipmentFusionData.GetStarSuitAttr(_type, index)
	local cfg = MeltLevelSuitPlus or {}
	local cur_cfg = cfg[_type] and cfg[_type].list and cfg[_type].list[index] or {}

	return cur_cfg
end

function EquipmentFusionData:GetCurFusionLevel(_type)
	local equip_list = EquipData.Instance:GetEquipData()

	local list = {}
	for slot, equip in pairs(equip_list) do
		local equip_type = equip.type or -1
		list[equip_type] = list[equip_type] or {}
		table.insert(list[equip_type], equip)
	end
	
	local level = nil
	for equip_type, _ in pairs(self.item_type_list[_type]) do
		if list[equip_type] then
			for i, equip in ipairs(list[equip_type]) do
				local fusion_lv = equip.fusion_lv or 0
				level = level or fusion_lv
				level = math.min(level, fusion_lv)
			end
		else
			level = 0
			break
		end
	end

	return level or 0
end

-- 获取融合分解消耗
function EquipmentFusionData.GetFusionRecycleCousumes(item_id, fusion_lv)
	local fusion_type = ItemData.GetIsBasisEquip(item_id) and 1 or 2

	local cfg = EquipForgingDecomCfg or {}
	local decom_cfg = cfg.DecomCfg or {}
	local cur_decom_cfg = decom_cfg[fusion_type] or {}
	local consumes = cur_decom_cfg[fusion_lv] and cur_decom_cfg[fusion_lv].consumes or {}

	return consumes
end

--------------------

function EquipmentFusionData:RecvMainInfoCallBack()
	local cfg = EquipMeltCfg or {}
	local limit = cfg.limit or {}
	local limit_1 = limit[1] or {days = 0, circle = 999}
	local limit_2 = limit[2] or {days = 0, circle = 999}
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local open_server_day = OtherData.Instance:GetOpenServerDays()
	self.open_1 = open_server_day >= limit_1.days and circle >= limit_1.circle
	self.open_2 = open_server_day >= limit_2.days and circle >= limit_2.circle

	-- 有开启时,刷新红点和创建监听
	if self.open_1 or self.open_2 then
		RemindManager.Instance:DoRemindDelayTime(RemindName.EquipmentFusion)
		self:CreatEvent()
	end

	-- 有未开启时,创建"转数"和"开服开数"监听
	if not self.open_1 or not self.open_2 then
		self.cricle_change_event = EventProxy.New(RoleData.Instance)
		self.cricle_change_event:AddEventListener(OBJ_ATTR.ACTOR_CIRCLE, BindTool.Bind(self.OnCondChange, self))
		self.open_day_change_event = GlobalEventSystem:Bind(OtherEventType.OPEN_DAY_CHANGE, BindTool.Bind(self.OnCondChange, self))
	end
end

-- 创建背包和穿戴监听
function EquipmentFusionData:CreatEvent()
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	self.open_event = true
end

-- 功能开放监听
function EquipmentFusionData:OnCondChange()
	local open_1, open_2 = self.open_1, self.open_2

	local cfg = EquipMeltCfg or {}
	local limit = cfg.limit or {}
	local limit_1 = limit[1] or {days = 0, circle = 999}
	local limit_2 = limit[2] or {days = 0, circle = 999}
	local circle = OtherData.Instance:GetOpenServerDays()
	local open_server_day = OtherData.Instance:GetOpenServerDays()
	self.open_1 = open_server_day >= limit_1.days and circle >= limit_1.circle
	self.open_2 = open_server_day >= limit_2.days and circle >= limit_2.circle

	if (not self.open_event) and (self.open_1 or self.open_2)then
		self:CreatEvent()
	end

	-- 功能都开启时,注销"转数"和"开服开数"监听
	if self.open_1 and self.open_2 then
		if self.cricle_change_event then
			self.cricle_change_event:DeleteMe()
			self.cricle_change_event = nil
		end
			
		if self.open_day_change_event then
			GlobalEventSystem:UnBind(self.open_day_change_event)
			self.open_day_change_event = nil
		end
	end

	-- 开放功能时,立刻刷新红点
	if open_1 ~= self.open_1 or open_2 ~= self.open_2 then
		RemindManager.Instance:DoRemind(RemindName.EquipmentFusion)
	end
end

function EquipmentFusionData:OnBagItemChange(event)
	local need_flush = false

	for i, v in ipairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			need_flush = true
		else
			-- 有红点提示时,只监听删除物品,没红点提示时,监听物品增加
			if self.remind_item_id then
				local item_id = v.data and v.data.item_id
				if item_id == self.remind_item_id then
					if v.change_type == ITEM_CHANGE_TYPE.DEL or v.change_type == ITEM_CHANGE_TYPE.CHANGE then
						need_flush = true
					end
				end
			else
				local item_type = v.data and v.data.type or -1
				if v.change_type == ITEM_CHANGE_TYPE.ADD or v.change_type == ITEM_CHANGE_TYPE.CHANGE then
					if self.item_type_list[1] and self.item_type_list[1][item_type] then
						need_flush = true
					elseif self.item_type_list[2] and self.item_type_list[2][item_type] then
						need_flush = true
					end
				end
			end
		end

		if need_flush then
			RemindManager.Instance:DoRemindDelayTime(RemindName.EquipmentFusion)
			break
		end
	end
end

function EquipmentFusionData:OnChangeOneEquip(param_t)
	if self.remind_slot == nil then
		-- 未显示红点时,只监听穿上装备
		local put_on = EquipData and EquipData.CHANGE_EQUIP_REASON and EquipData.CHANGE_EQUIP_REASON.PUT_ON
		if put_on == param_t.reason then
			local slot = param_t.slot or 0
			if type(self.put_on_slot) == "table" then -- 初始化后才缓存槽位
				self.put_on_slot[slot] = true -- 缓存需要判断的槽位 缓存后红点刷新只判断缓存的槽位
			end
			RemindManager.Instance:DoRemindDelayTime(RemindName.EquipmentFusion)
		end
	elseif self.remind_slot == param_t.slot then
		RemindManager.Instance:DoRemindDelayTime(RemindName.EquipmentFusion)
	end
end

function EquipmentFusionData:GetRemindIndex()
	local def = ViewDef.Equipment.Fusion
	if not ViewManager.Instance:CanOpen(def) then return 0 end

	self.remind_item_id = nil
	self.remind_slot = nil

	local open_1 = self.open_1
	local open_2 = self.open_2

	local equip_list = EquipData.Instance:GetEquipData() or {}

	-- 穿上新装备时的回调优化
	if self.put_on_slot and next(self.put_on_slot) then
		local list = {}
		for slot, v in ipairs(self.put_on_slot) do
			list[slot] = equip_list[slot]
		end
		equip_list = list
	end
	self.put_on_slot = {} -- 初始化槽位缓存 用于"穿带装备"监听回调优化

	local can_fusion = false
	for slot, equip in pairs(equip_list) do
		local item_id = equip.item_id or 0

		-- 判断物品类型是否可融合
		local fusion_type = 0
		if open_1 and ItemData.GetIsBasisEquip(item_id) then --是否为基础装备
			fusion_type = 1
			can_fusion = true
		elseif open_2 and (ItemData.IsReXueEquip(item_id) --是否为热血装备
				or ItemData.IsZhanShenEquip(item_id) --是否为战神装备
				or ItemData.IsShaShenEquip(item_id)) --是否为杀神装备
		then
			fusion_type = 2
			can_fusion = true
		end

		local cur_fusion_lv = 0

		-- 判断消耗是否足够
		if can_fusion then
			local cfg = EquipMeltCfg or {}
			local meltcfg = cfg.meltcfg and cfg.meltcfg[fusion_type] or {}
			cur_fusion_lv = EquipmentFusionData.GetFusionLv(equip)
			local cur_meltcfg = meltcfg[cur_fusion_lv + 1]
			if cur_meltcfg then
				local limit_level, zhuan = ItemData.GetItemLevel(item_id)
				can_fusion = fusion_type == 2 or zhuan >= cur_meltcfg.circleLimit
			else
				can_fusion = false
			end
			
			-- 基础装备需装备达到对应转数才可融合
			if can_fusion then
				local consumes = cur_meltcfg.consumes or {}
				can_fusion = BagData.CheckConsumesCount(consumes)
			end
		end

		-- 是否有融合等级相同的装备
		if can_fusion then
			can_fusion = false
			local can_fusion_list = {}
			local bag_list = BagData.Instance:GetDataListSeries()
			local cur_equip_list = BagData.Instance:GetSeriesByItemId(item_id)
			if next(cur_equip_list) then -- 背包中有这个装备时,才判断融合等级是否相同
				for series, _ in pairs(cur_equip_list) do
					local item = BagData.Instance:GetOneItemBySeries(series)
					local fusion_lv = EquipmentFusionData.GetFusionLv(item)
					if fusion_lv == cur_fusion_lv then
						self.remind_item_id = item_id -- 缓存显示红点的物品ID 用于背包物品监听回调优化
						self.remind_slot = slot -- 缓存显示红点的装备槽位 用于"穿带装备"监听回调优化
						can_fusion = true
						break
					end
				end
			end
		end

		-- 有可融合时,暂停判断
		if can_fusion then
			break
		end
	end

	local index = can_fusion and 1 or 0
	return index
end
