--------------------------------------------------------
-- 特戒Data
--------------------------------------------------------

SpecialRingData = SpecialRingData or BaseClass(BaseData)

SpecialRingData.IN_PUT_LIST_CHANGE = "in_put_list_change" -- 特戒投入列表改变
SpecialRingData.SLOT_INFO_CHANGE = "slot_info_change" -- 特戒槽位信息改变

-- 特戒需显示的属性ID
SpecialRingData.show_attr = {[5] = true, [7] = true, [9] = true, [11] = true, [13] = true, [15] = true,
				[17] = true, [19] = true, [21] = true, [23] = true, [25] = true, [27] = true}

function SpecialRingData:__init()
	if SpecialRingData.Instance then
		ErrorLog("[SpecialRingData]:Attempt to create singleton twice!")
	end
	SpecialRingData.Instance = self

	self.effect_id_list = {}
	self.synthetic_cfg = {}
	self.in_put_list = {}
	self.max_slot = 6 -- 最大融合槽位
	self.bag_need_flush = true

	self.game_cond_change = GlobalEventSystem:Bind(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
end

function SpecialRingData:__delete()
	SpecialRingData.Instance = nil

	if self.game_cond_change then
		GlobalEventSystem:UnBind(self.game_cond_change)
		self.game_cond_change = nil
	end
end

----------设置----------

--获取合成配置
function SpecialRingData:GetSynthesisCfg()
	return ItemSynthesisConfig and ItemSynthesisConfig[7] or {}
end

-- 初始化"特戒合成"列表
function SpecialRingData:InitSpecialRingList()
	local list = {}
	local synthetic_cfg = {}
	local cfg = self:GetSynthesisCfg()
	local _type = 0
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local open_server_day = OtherData.Instance:GetOpenServerDays()
	for _type, data in ipairs(cfg.list or {}) do
		local item_list = data.itemList or {}
		for index, item in ipairs(item_list) do
			local openlimit = item.openlimit or {circle = 0, level = 0, serverday = 1,}
			if circle >= openlimit.circle and role_lv >= openlimit.level and open_server_day >= openlimit.serverday then
				local award = item.award and item.award[1] or {}
				local consume = item.consume and item.consume[1] or {}
				if index == 1 then -- 每11个为一种特戒
					list[_type] = {}
					list[_type][1] = {}
					list[_type][1].item_id = consume.id or 0
					list[_type][1].effect_id = consume.effect_id or 1
					
					self.effect_id_list[_type] = consume.effect_id or 1
				end

				list[_type][index + 1] = {}
				list[_type][index + 1].compose_index = index
				list[_type][index + 1].compose_type = _type
				list[_type][index + 1].item_id = award.id or 0
				list[_type][index + 1].effect_id = award.effect_id or 1
				list[_type][index + 1].consume = {["item_id"] = consume.id, ["num"] = consume.count}
				local consume_id = consume.id or 1
				synthetic_cfg[consume_id] = {count = consume.count, type = _type, index = index + 1}
			end
		end
	end

	self.synthetic_cfg = synthetic_cfg
	self.special_ring_list = list

	-- 记录刷新时的转生等级 转生改变才更新
	self.circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
end

-- 获取格式化后的特戒合成配置
function SpecialRingData:GetSpecialRingList()
	-- 人物转生改变才刷新
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if self.circle ~= circle then
		self:InitSpecialRingList()
	end

	return self.special_ring_list or {}
end

-- 获取特戒合成数量列表 红点提醒专用
function SpecialRingData:GetSyntheticCfg()
	if self.synthetic_cfg == nil or next(self.synthetic_cfg) == nil then
		self:InitSpecialRingList()
	end
	return self.synthetic_cfg or {}
end

-- 获取未穿戴时的显示特效
function SpecialRingData:GetSpecialRingEffectId(slot)
	self.effect_id_list = self.effect_id_list or {}
	local index = EquipData.SLOT_HAND_POS[slot] and 2 or 1
	return self.effect_id_list[index] or 1
end


function SpecialRingData:GetSpecialRingBag()
	local item_type = ItemData.ItemType.itSpecialRing
	local bag_item_list = BagData.Instance:GetBagItemDataListByType(item_type)

	return bag_item_list
end

-- 设置主戒槽位信息
function SpecialRingData:SetSpecialRingInfo(protocol)
	-- 修改特戒物品信息
	local series = protocol.series
	local item_data = BagData.Instance:GetItemInBagBySeries(series)
	local special_ring = item_data.special_ring or {}
	local slot = special_ring[protocol.slot + 1]
	slot.type = protocol.type
	slot.index = protocol.index
	ItemData.Instance:GetItemScoreByData(item_data, true) -- 刷新特戒战力

	if protocol.type ~= 0 then
		-- 特戒融合成功
		SysMsgCtrl.Instance:FloatingTopRightText(Language.SpecialRing.FloatingText[1])
	else
		-- 特戒分离成功
		SysMsgCtrl.Instance:FloatingTopRightText(Language.SpecialRing.FloatingText[2])
	end

	self.in_put_list[2] = nil
	self:DispatchEvent(SpecialRingData.SLOT_INFO_CHANGE, protocol.type, item_data)
end

function SpecialRingData.GetSpecialRingPower(item_data)
	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
	local attrs = ItemData.GetStaitcAttrs(item_cfg)
	if item_data.special_ring then
		for i,v in ipairs(item_data.special_ring) do
			local _type = v.type
			local index = v.index
			if _type > 0 then
				local cfg = SpecialRingHandleCfg or {}
				local item_id_list = cfg.ItemIdIndxs and cfg.ItemIdIndxs[_type] and cfg.ItemIdIndxs[_type].ids or {}
				local item_id = item_id_list[index] or 1
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				local fusion_attr = ItemData.GetStaitcAttrs(item_cfg)
				attrs = CommonDataManager.AddAttr(fusion_attr, attrs)
			end
		end
	end
	
	local power = CommonDataManager.GetAttrSetScore(attrs)
	return power
end
--------------------

-- 设置投入类型 _type = 1融合主戒 2融合副戒 3分离主戒
function SpecialRingData:SetInPutType(_type)
	self.in_put_type = _type
end

function SpecialRingData:GetInPutType()
	return self.in_put_type
end

function SpecialRingData:SetInPutData(item_data)
	local _type = self.in_put_type or 0
	if _type == 2 then
		if self.in_put_list[1] then
			local main_id = self.in_put_list[1].item_id
			local main_item_cfg = ItemData.Instance:GetItemConfig(main_id)
			local vice_item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
			if main_item_cfg.useType == vice_item_cfg.useType then
				-- 请投入其它类型的副戒
				SysMsgCtrl.Instance:FloatingTopRightText(Language.SpecialRing.FloatingText[3])
				return
			end

			for i,v in ipairs(item_data.special_ring) do
				if v.type ~= 0 then
					-- 请投入未融合过的副戒
					SysMsgCtrl.Instance:FloatingTopRightText(Language.SpecialRing.FloatingText[4])
					return
				end
			end
			for i,v in ipairs(self.in_put_list[1].special_ring) do
				if v.type ~= 0 and v.type == vice_item_cfg.useType then
					-- 已融合当前类型特戒
					SysMsgCtrl.Instance:FloatingTopRightText(Language.SpecialRing.FloatingText[5])
					return
				end
			end

		else
			-- 请先投入主戒
			SysMsgCtrl.Instance:FloatingTopRightText(Language.SpecialRing.FloatingText[6])
			return
		end
	elseif _type == 1 then
		local can_fusion = false
		for i,v in ipairs(item_data.special_ring) do
			if v.type == 0 then
				can_fusion = true
				break
			end
		end
		if can_fusion then
			self.in_put_list[2] = nil
		else
			-- 该特戒槽位已满
			SysMsgCtrl.Instance:FloatingTopRightText(Language.SpecialRing.FloatingText[7])
			return
		end
	end

	self.in_put_list[_type] = item_data
	self:DispatchEvent(SpecialRingData.IN_PUT_LIST_CHANGE, _type, item_data)
end

function SpecialRingData:GetInPutList()
	return self.in_put_list or {}
end

function SpecialRingData:ResetInPutList()
	self.in_put_list = {}
end

-- 功能开放后,开启红点提示
function SpecialRingData:OnGameCondChange(cond_id, is_all_ok)
	local v_open_cond = ViewDef.SpecialRing.v_open_cond or ""
	if v_open_cond == cond_id and is_all_ok then
		RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.SpecialRingSynthetic)
		BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
		GlobalEventSystem:Bind(OtherEventType.OPEN_DAY_CHANGE, BindTool.Bind(self.OnOpenDayChange, self))

		RemindManager.Instance:DoRemindDelayTime(RemindName.SpecialRingSynthetic)

		if self.game_cond_change then
			GlobalEventSystem:UnBind(self.game_cond_change)
			self.game_cond_change = nil
		end
	end
end

function SpecialRingData:OnOpenDayChange(open_server_day)
	self:InitSpecialRingList()
	RemindManager.Instance:DoRemindDelayTime(RemindName.SpecialRingSynthetic)
end

function SpecialRingData:OnBagItemChange(event)
	local remind_need_flush
	for i,v in ipairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			remind_need_flush = true
		end
	end
	event.CheckAllItemDataByFunc(function (vo)
		local item_type = vo.data.type
		if vo.change_type == ITEM_CHANGE_TYPE.LIST then
		elseif item_type == ItemData.ItemType.itSpecialRing then
			remind_need_flush = true
		end
	end)
	if remind_need_flush then
		RemindManager.Instance:DoRemindDelayTime(RemindName.SpecialRingSynthetic)
	end
end

function SpecialRingData.GetRemindIndex()
	local index = 0
	for item_id, v in pairs(SpecialRingData.Instance:GetSyntheticCfg()) do
		local bag_count = BagData.Instance:GetItemNumInBagById(item_id)
		-- 红点提示不对特戒进行已融合判断
		if bag_count >= v.count then
			index = 1
			break
		end
	end
	return index
end
