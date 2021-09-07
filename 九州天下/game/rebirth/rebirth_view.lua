require("game/rebirth/rebirth_advance_view")
require("game/rebirth/rebirth_equip_view")
require("game/rebirth/rebirth_suit_view")
RebirthView = RebirthView or BaseClass(BaseView)
-- 转生
function RebirthView:__init()
	self.ui_config = {"uis/views/rebirthview","RebirthView"}
	self:SetMaskBg()
	self.full_screen = false
	self.play_audio = true
	self.def_index = TabIndex.advance
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function RebirthView:__delete()
	self.full_screen = nil
	self.play_audio = nil
	
end

function RebirthView:ReleaseCallBack()
	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.toggle_advance = nil
	self.toggle_equip = nil
	
	if self.advance_view then
		self.advance_view:DeleteMe()
		self.advance_view = nil
	end

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
	
	self.open_xilian_tab = nil
	self.red_point_list = nil
end

function RebirthView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.advance_view then
		self.advance_view:ClearData()
	end
end
function RebirthView:LoadCallBack()
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self:ListenEvent("Close", BindTool.Bind(self.OnCloseHandler, self))
	self:ListenEvent("AddGold", BindTool.Bind(self.OnAddGoldHandle, self))

	self.toggle_advance = self:FindObj("ToggleAdvance")
	self.toggle_equip = self:FindObj("ToggleEquip")

	self.toggle_advance.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.advance))
	self.toggle_equip.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.equip))

	self.advance_view = RebirthAdvanceView.New()
	local advance_content = self:FindObj("AdvanceContent")
	advance_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.advance_view:SetInstance(obj)
	end)

	self.equip_view = RebirthEquipView.New()
	local equip_content = self:FindObj("EquipContent")
	equip_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.equip_view:SetInstance(obj)
	end)

	self.open_xilian_tab = self:FindVariable("OpenXilianTab")

	self.red_point_list = {
		[RemindName.RebirthAdvance] = self:FindVariable("IsAdvanceRedShow"),
		[RemindName.RebirthEquip] = self:FindVariable("IsEquipRedShow"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function RebirthView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function RebirthView:OpenCallBack()
	RebirthCtrl.Instance:SendReqRebirthAllInfo(REBIRTH_REQ_TYPE.ZHUANSHENGSYSTEM_REQ_TYPE_ALL_INFO)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function RebirthView:OnToggleChange(index, ison)
	if ison then
		self:ChangeToIndex(index)
	end
end
function RebirthView:ShowIndexCallBack(index)
	if self.advance_view then
		self.advance_view:ClearData()
	end
	
	if index == TabIndex.advance then
		self.toggle_advance.toggle.isOn = true

	elseif index == TabIndex.equip then
		self.toggle_equip.toggle.isOn = true
		if self.equip_view then
			self.equip_view:OpenCallBack()
		end
	end

	self:Flush()
end

function RebirthView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "all" then
			if self.show_index == TabIndex.advance then
				if self.advance_view then
					self.advance_view:Flush()
				end
			elseif self.show_index == TabIndex.equip then
				if self.equip_view then
					self.equip_view:Flush()
				end
			end
		end
	end
	 --套装开启的等级
	local suit_opened_grade = RebirthData.Instance:GetSuitOpenedGrade()
	self.open_xilian_tab:SetValue(suit_opened_grade > 0)
end

function RebirthView:OnCloseHandler()
	ViewManager.Instance:Close(ViewName.RebirthView)
end

function RebirthView:OnAddGoldHandle()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.RebirthView)
end

function RebirthView:FlushRebirthUpgrade(result)
	self.advance_view:FlushRebirthUpgrade(result)
end

function RebirthView:GetCurSelectSuit()
	if self.equip_view then
		return self.equip_view:GetCurSelectSuit()
	end
end

function RebirthView:SetCurSelectSuit(cur_select)
	if self.equip_view then
		self.equip_view:SetCurSelectSuit(cur_select)
	end
end

function RebirthView:GetCapability()
	return self.equip_view:GetCapability()
end

function RebirthView:SetEquipIndex(equip_index)
	self.equip_view:SetEquipIndex(equip_index)
end

function RebirthView:ItemDataChangeCallback()
	if self.advance_view ~= nil then
		self.advance_view:Flush()
		RemindManager.Instance:Fire(RemindName.RebirthAdvance)
	end
	if self.equip_view ~= nil then
		self.equip_view:Flush()
		RemindManager.Instance:Fire(RemindName.RebirthEquip)
	end
end
