TipsTriggerCtrl = TipsTriggerCtrl or BaseClass(BaseController)

function TipsTriggerCtrl:__init()
	-- 监听系统事件
	self.player_data_change_callback = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback)

	self.item_data_change_callback = BindTool.Bind1(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)
end

function TipsTriggerCtrl:__delete()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
	PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback)
end

--玩家数据改变时
function TipsTriggerCtrl:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "capability" and old_value > 0 then				--战斗力
		if value == nil or old_value == nil or value == old_value or math.floor(value - old_value) == 0 then
			return
		end
		TipsCtrl.Instance:ShowPowerChange(value, old_value)
		-- if not IS_ON_CROSSSERVER then
		-- 	TipsCtrl.Instance:ShowPowerChange(value, old_value)
		-- else
		-- 	-- 跨服的时候保留旧战力，避免回到本服的时候弹出战力变化
		-- 	local gamevo = GameVoManager.Instance:GetMainRoleVo()
		-- 	gamevo.capability = old_value
		-- end
	end
end

local DISPOSE_TYPE = {OnItemDataChange = 0}
-- 在这里设置放入原因的各种情况并返回相应的值
function TipsTriggerCtrl.PutReasonSituation(put_reason,reason,dispose_type)
	reason = reason or 0
	dispose_type = dispose_type or 0
	local flag = false
	if dispose_type == DISPOSE_TYPE.OnItemDataChange then
		if put_reason == nil then
			return false
		end
		flag = (put_reason == PUT_REASON_TYPE.PUT_REASON_INVALID and reason == DATALIST_CHANGE_REASON.UPDATE)
				or put_reason == PUT_REASON_TYPE.PUT_REASON_GM
				or put_reason == PUT_REASON_TYPE.PUT_REASON_PICK
				or put_reason == PUT_REASON_TYPE.PUT_REASON_TASK_REWARD
				or put_reason == PUT_REASON_TYPE.PUT_REASON_CHEST_SHOP
				or put_reason == PUT_REASON_TYPE.PUT_REASON_GIFT
				or put_reason == PUT_REASON_TYPE.PUT_REASON_ZHIXIAN_TASK_REWARD
				or put_reason == PUT_REASON_TYPE.PUT_REASON_CONVERT_SHOP
	end
	return flag
end

--物品数据改变时
function TipsTriggerCtrl:OnItemDataChange(item_id, index, reason, put_reason, old_num, new_num)
	-- if IS_ON_CROSSSERVER then
	-- 	return
	-- end
	local is_get = false
	new_num = new_num or 0
	old_num = old_num or 0
	if new_num < old_num then
		local view = ViewManager.Instance:GetView(ViewName.TipsGetNewitemView)
		if view and view:GetIndex() == index then
			ViewManager.Instance:Close(ViewName.TipsGetNewitemView)
		end
	end
	if new_num > old_num then
		is_get = true
	end
	local is_tip_use = false
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT
		and self.PutReasonSituation(put_reason,reason,DISPOSE_TYPE.OnItemDataChange)
		and item_cfg.sub_type ~= 202 and item_cfg.sub_type ~= 201 then

		local gamevo = GameVoManager.Instance:GetMainRoleVo()
		if gamevo.level>= 20 and gamevo.level < 85 and (gamevo.prof == item_cfg.limit_prof or item_cfg.limit_prof == 5) then
			local is_equip = EquipData.Instance:CheckIsAutoEquip(item_id, index)
			if is_equip then
				--装备物品
				local equip_cfg = ItemData.Instance:GetItemConfig(item_id)
				local bag_data = ItemData.Instance:GetItem(item_id)
				local equip_index = EquipData.Instance:GetEquipIndexByType(equip_cfg.sub_type)
				PackageCtrl.Instance:SendUseItem(bag_data.index, 1, equip_index, equip_cfg.need_gold)
			end
		elseif item_cfg and gamevo.prof == item_cfg.limit_prof or item_cfg.limit_prof == 5 then
			TipsCtrl.Instance:ShowShorCutEquipView(item_id, index)
		end
		return
	end

	if item_cfg ~= nil then
		if item_cfg.is_tip_use == 1 then
			is_tip_use = true
		end
	end
	if is_tip_use and is_get then
		if put_reason and put_reason ~= 0 then
			if put_reason == PUT_REASON_TYPE.PUT_REASON_ACTIVE_DEGREE then
				--活跃度类型物品
				TipsCtrl.Instance:OpenGuildRewardView({item_id = item_id, num = new_num - old_num, auto_use = true, new_num = new_num})
			else
				TipsCtrl.Instance:ShowGetNewItemView(item_id, index)
			end
		end
	end
end