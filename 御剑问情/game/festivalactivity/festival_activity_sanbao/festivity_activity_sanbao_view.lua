VersionThreePieceView = VersionThreePieceView or BaseClass(BaseRender)

function VersionThreePieceView:__init()
	self.cell_list = {}

	self.act_time = self:FindVariable("Time")
	self.max_num = self:FindVariable("MaxNum")
	self.leave_num = self:FindVariable("LeaveNum")
	self.cap = self:FindVariable("Cap")
	self.recharge = self:FindVariable("Recharge")
	self.module_name = self:FindVariable("module_name")

	self.display = self:FindObj("RoleDisplay")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)
	
	self:ListenEvent("ClickRechange", BindTool.Bind(self.ClickRechange, self))

	self:InitScroller()
end

function VersionThreePieceView:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end


function VersionThreePieceView:OpenCallBack()
	self:Flush()
end

function VersionThreePieceView:InitScroller()
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		local data = VersionThreePieceData.Instance:GetSanBaoCfg()
		return #data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index)
		local data = VersionThreePieceData.Instance:GetSanBaoCfg()
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]
		if nil == target_cell then
			self.cell_list[cell] =  VersionThreePieceCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(data[data_index])
	end
end

function VersionThreePieceView:GetDisplayName(modle_id)
	local display_name = "jxsanbao_panel"
	local cfg = ItemData.Instance:GetItemConfig(tonumber(modle_id))
	if cfg == nil then
		return display_name
	end

	if cfg.is_display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		display_name = "jxsanbao_fight_mount_panel"
	elseif cfg.is_display_role == DISPLAY_TYPE.MOUNT then
		display_name = "jxsanbao_mount_panel"
	elseif cfg.is_display_role == DISPLAY_TYPE.WING then
		display_name = "jxsanbao_wing_panel"
	end
	return display_name
end

function VersionThreePieceView:OnFlush(param_t)
	local data = VersionThreePieceData.Instance:GetSanBaoCfg()
	local fight_power = 0
	local module_name = ""

	if data[1] and data[1].res_id then
		local item_cfg = ItemData.Instance:GetItemConfig(data[1].res_id)
		if item_cfg == nil then
			return
		end

		local display_name = self:GetDisplayName(data[1].res_id)
		self.model:SetPanelName(display_name)
		ItemData.ChangeModel(self.model, data[1].res_id)
		fight_power = ItemData.GetFightPower(data[1].res_id)
		module_name = ToColorStr(item_cfg.name, item_cfg.color)		
	end

	self.module_name:SetValue(module_name)
	self.cap:SetValue(fight_power)

	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	local recharge = VersionThreePieceData.Instance:GetSanBaoChargeValue()
	self.recharge:SetValue(recharge)
end

function VersionThreePieceView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 7))
	elseif time > 3600 then
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 1))
	else
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 4))
	end
end

function VersionThreePieceView:ClickRechange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

---------------------------VersionThreePieceCell-----------------------
VersionThreePieceCell = VersionThreePieceCell or BaseClass(BaseCell)

function VersionThreePieceCell:__init()
	self.recharge_txt = self:FindVariable("Recharge")

	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("ItemList"))
		self.reward_list[i]:IgnoreArrow(true)
	end
end

function VersionThreePieceCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function VersionThreePieceCell:OnFlush()
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
			v:SetItemActive(self.data.reward_item[k - 1] ~= nil)
		end
	end


	self.recharge_txt:SetValue(self.data.need_chongzhi_num)
end