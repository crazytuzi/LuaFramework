ThreePieceView = ThreePieceView or BaseClass(BaseView)

function ThreePieceView:__init()
	self.ui_config = {"uis/views/randomact/threepiece_prefab", "ThreePieceView"}
	self.play_audio = true
	self.cell_list = {}
end

function ThreePieceView:__delete()

end

function ThreePieceView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self.act_time = self:FindVariable("Time")
	self.max_num = self:FindVariable("MaxNum")
	self.leave_num = self:FindVariable("LeaveNum")
	self.cap = self:FindVariable("Cap")
	self.recharge = self:FindVariable("Recharge")
	self.display = self:FindObj("RoleDisplay")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)
	self:InitScroller()
	self:ListenEvent("ClickRechange",
		BindTool.Bind(self.ClickRechange, self))
end

function ThreePieceView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	-- 清理变量和对象
	self.scroller = nil
	self.act_time = nil
	self.max_num = nil
	self.leave_num = nil
	self.cap = nil
	self.recharge = nil
	self.display = nil
end

function ThreePieceView:InitScroller()
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	self.data = ThreePieceData.Instance:GetRechargeCfg()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]
		if nil == target_cell then
			self.cell_list[cell] =  ThreePieceCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function ThreePieceView:OpenCallBack()
	ThreePieceCtrl.SendRATotalCharge4Info()
	self:Flush()
end

function ThreePieceView:ShowIndexCallBack(index)

end

function ThreePieceView:CloseCallBack()

end

function ThreePieceView:GetDisplayName(modle_id)
	local display_name = "threepiece_panel"
	local cfg = ItemData.Instance:GetItemConfig(tonumber(modle_id))
	if cfg == nil then
		return display_name
	end
	if cfg.is_display_role == DISPLAY_TYPE.MOUNT then
		display_name = "threepiece_mount_panel"
	elseif cfg.is_display_role == DISPLAY_TYPE.WING then
		display_name = "threepiece_wing_panel"
	end
	return display_name
end

function ThreePieceView:OnFlush(param_t)
	self.data = ThreePieceData.Instance:GetRechargeCfg()

	if self.data[1] and self.data[1].res_id then
		local display_name = self:GetDisplayName(self.data[1].res_id)
		self.model:SetPanelName(display_name)
		ItemData.ChangeModel(self.model, self.data[1].res_id)
		self.cap:SetValue(ItemData.GetFightPower(self.data[1].res_id))
	else
		self.cap:SetValue(0)
	end
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	local recharge_info = ThreePieceData.Instance:GetRechargeInfo()
	self.max_num:SetValue(500)
	self.leave_num:SetValue(500 - recharge_info.cur_total_charge_has_fetch_flag)
	self.recharge:SetValue(recharge_info.cur_total_charge)
end

function ThreePieceView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_NEW_THREE_SUIT)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond(time, 6) .. "</color>")
	elseif time > 3600 then
		self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond(time, 1) .. "</color>")
	else
		self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond(time, 2) .. "</color>")
	end
end

function ThreePieceView:ClickRechange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

---------------------------------------------------------------
--滚动条格子

ThreePieceCell = ThreePieceCell or BaseClass(BaseCell)

function ThreePieceCell:__init()
	self.recharge_txt = self:FindVariable("Recharge")
	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("ItemList"))
		self.reward_list[i]:IgnoreArrow(true)
	end
end

function ThreePieceCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function ThreePieceCell:OnFlush()
	if nil == self.data then return end
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item[0].item_id)
	if self.data.reward_item[1] == nil and #item_list > 0 then
		for k,v in pairs(self.reward_list) do
			if item_list[k] then
				v:SetData(item_list[k])
			end
			v.root_node:SetActive(item_list[k] ~= nil)
			v:SetInteractable(true)
		end
	else
		for k,v in pairs(self.reward_list) do
			if self.data.reward_item[k - 1] then
				v:SetData(self.data.reward_item[k - 1])
			end
			v.root_node:SetActive(self.data.reward_item[k - 1] ~= nil)
		end
	end


	self.recharge_txt:SetValue(self.data.need_chongzhi_num)
end