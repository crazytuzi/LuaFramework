TipsShortCutEquipView = TipsShortCutEquipView or BaseClass(BaseView)

local FIX_TIME = 10
local AUTO_EQUIP_LEVEL = 130

function TipsShortCutEquipView:__init()
	self.ui_config = {"uis/views/tips/equiptips_prefab", "ShortcutEquip"}
	self.sure_call_back = nil
	self.play_audio = true
	self.is_auto_equip = false
	self.vew_cache_time = ViewCacheTime.NORMAL

	self.item_data_event = BindTool.Bind(self.ItemDataChangeCallback, self)
	self.view_layer = UiLayer.Pop
end

function TipsShortCutEquipView:__delete()

end

function TipsShortCutEquipView:ReleaseCallBack()
	if self.equip_item ~= nil then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	-- 清理变量和对象
	self.equip_name = nil
	self.equip_power = nil
	self.cal_time_text = nil
end

function TipsShortCutEquipView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseOnClick, self))
	self:ListenEvent("EquipButton", BindTool.Bind(self.EquipOnClick, self))
	self.equip_name = self:FindVariable("EquipName")
	self.equip_power = self:FindVariable("EquipPower")
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.cal_time_text = self:FindVariable("cal_time_text")
end

function TipsShortCutEquipView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	self:Flush()
end

function TipsShortCutEquipView:CloseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	end
end

function TipsShortCutEquipView:SetItemId(item_id,index)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()

	local equip_cfg = ItemData.Instance:GetItemConfig(item_id)
	if equip_cfg == nil then
		return
	end

	if main_vo.level < equip_cfg.limit_level then
		return
	end

	if equip_cfg.limit_prof ~= 5 and equip_cfg.limit_prof ~= GameVoManager.Instance:GetMainRoleVo().prof then
		return
	end
	if (equip_cfg.sub_type - 100) > 10 and equip_cfg.sub_type ~= 202 then
		return
	end
	if not EquipData.Instance:CheckIsAutoEquip(item_id, index) then
		return
	end

	if not self:IsOpen() then
		self.item_id = item_id
		self.index = index
	end
	self:Open()
end

function TipsShortCutEquipView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num, param_change)
	if item_id == self.item_id and param_change then
		self.index = index
		self:Flush()
	elseif index == self.index and item_id ~= self.item_id then
		self:Close()
	else
		self:Flush()
	end
end

function TipsShortCutEquipView:OnFlush()
	self.is_auto_equip = false

	local item_info = self:GetItemInfoByID(self.item_id)
	local new_equip_data = ItemData.Instance:GetGridData(self.index)
	if new_equip_data == nil then
		self:Close()
		return
	end
	local power = EquipData.Instance:GetEquipCapacity(new_equip_data)
	if power <= 0 then
		self:Close()
		return
	end
	self.equip_item:SetData(new_equip_data)

	self.equip_name:SetValue("<color="..LIAN_QI_NAME_COLOR[item_info.color]..">"..item_info.name.."</color>")
	self.equip_power:SetValue(power)

	local delay_time = FIX_TIME
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
	end
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		delay_time = delay_time - UnityEngine.Time.deltaTime
		if delay_time > 0 then
			local time = math.floor(delay_time)
			if time >= 0 then
				local time_str = string.format(Language.Common.AutoEquip, time)
				self.cal_time_text:SetValue(time_str)
			end
		else
			self.is_auto_equip = true
			self:EquipOnClick()
		end
	-- 	GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.CloseView,self),0.6)
	end, 0)
end
function TipsShortCutEquipView:GetItemInfoByID(item_id)
	return ItemData.Instance:GetItemConfig(item_id)
end

function TipsShortCutEquipView:CloseOnClick()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.level <= AUTO_EQUIP_LEVEL then
		self.is_auto_equip = true
		self:EquipOnClick()
		return
	end
	self:Close()
end

function TipsShortCutEquipView:EquipOnClick()
	if self.sure_call_back ~= nil then
		self.sure_call_back()
	end
	--装备物品
	local equip_cfg = ItemData.Instance:GetItemConfig(self.item_id)

	local equip_index = EquipData.Instance:GetEquipIndexByType(equip_cfg.sub_type)
	local equip_suit_type = ForgeData.Instance:GetCurEquipSuitType(equip_index)
	local new_equip_data = ItemData.Instance:GetGridData(self.index)
	if new_equip_data == nil or new_equip_data.item_id ~= self.item_id then
		self:Close()
		return
	end
	if equip_suit_type ~= 0 and not self.is_auto_equip then
		self:Close()
		local yes_func = function ()
			-- self:CloseView()
			PackageCtrl.Instance:SendUseItem(self.index, 1, equip_index, equip_cfg.need_gold)
		end
		local no_func = function()

		end

		local equip_list = EquipData.Instance:GetDataList()
		local equip_suit_id = ForgeData.Instance:GetSuitIdByItemId(equip_list[equip_index].item_id)
		local item_suit_id = ForgeData.Instance:GetSuitIdByItemId(equip_cfg.id)
		if equip_suit_id ~= 0 and item_suit_id ~= 0 and equip_suit_id == item_suit_id and self then
			PackageCtrl.Instance:SendUseItem(self.index, 1, equip_index, equip_cfg.need_gold)
		else
			TipsCtrl.Instance:ShowCommonAutoView("", Language.Forge.ReturnSuitRock, yes_func, no_func)
		end
		return
	else
		PackageCtrl.Instance:SendUseItem(self.index, 1, equip_index, equip_cfg.need_gold)
	end
	self:Close()
end
