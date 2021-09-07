TipsBetterEquipView = TipsBetterEquipView or BaseClass(BaseView)

function TipsBetterEquipView:__init()
	self.ui_config = {"uis/views/tips/equiptips", "BetterEquipTip"}
	self.view_layer = UiLayer.Pop
end

function TipsBetterEquipView:__delete()

end

function TipsBetterEquipView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseOnClick, self))
	self:ListenEvent("OpenPackBag", BindTool.Bind(self.OpenPackBag, self))

	self.equip_name = self:FindVariable("EquipName")
	self.equip_power = self:FindVariable("EquipPower")
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
end

function TipsBetterEquipView:ReleaseCallBack()
	if self.equip_item ~= nil then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	self.equip_name = nil
	self.equip_power = nil
end

function TipsBetterEquipView:OpenCallBack()
	self.is_auto_equip = false

	local item_info = self:GetItemInfoByID(self.item_id)
	local new_equip_data = ItemData.Instance:GetGridData(self.index)
	local power = EquipData.Instance:GetEquipCapacity(new_equip_data)
	self.equip_item:SetData(new_equip_data)

	self.equip_name:SetValue("<color="..SOUL_NAME_COLOR[item_info.color]..">"..item_info.name.."</color>")
	self.equip_power:SetValue(power)

	local delay_time = 10
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		delay_time = delay_time - UnityEngine.Time.deltaTime
		if delay_time <= 0 then
			self:Close()
			if self.timer_quest then
				GlobalTimerQuest:CancelQuest(self.timer_quest)
				self.timer_quest = nil
			end
		end
	end, 0)
end

function TipsBetterEquipView:ShowIndexCallBack(index)

end

function TipsBetterEquipView:CloseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function TipsBetterEquipView:SetItemId(item_id,index)
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

function TipsBetterEquipView:GetItemInfoByID(item_id)
	return ItemData.Instance:GetItemConfig(item_id)
end

function TipsBetterEquipView:CloseOnClick()
	-- local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- if main_role_vo.level <= AUTO_EQUIP_LEVEL then
	-- end
	self:Close()
end

function TipsBetterEquipView:OpenPackBag()
	ViewManager.Instance:Open(ViewName.Player, TabIndex.role_bag)
	self:Close()
end
