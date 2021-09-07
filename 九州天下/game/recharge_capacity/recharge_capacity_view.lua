RechargeCapacityView = RechargeCapacityView or BaseClass(BaseView)

function RechargeCapacityView:__init()
	self.ui_config = {"uis/views/serveractivity/speedupcapacity","RechargeCapacity"}
	self:SetMaskBg(true)
	self.play_audio = true
	self.cell_list = {}
end

function RechargeCapacityView:__delete()

end

function RechargeCapacityView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self.act_time = self:FindVariable("ActTime")
	self:InitScroller()
end

function RechargeCapacityView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	-- 清理变量和对象
	self.scroller = nil
	self.act_time = nil
end

function RechargeCapacityView:InitScroller()
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	self.data = RechargeCapacityData.Instance:GetRechargeCapacityCfg()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end

	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  RechargeCapacityCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function RechargeCapacityView:OpenCallBack()
	self:Flush()
end

function RechargeCapacityView:ShowIndexCallBack(index)

end

function RechargeCapacityView:CloseCallBack()

end

function RechargeCapacityView:OnFlush(param_t)
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function RechargeCapacityView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RECHARGE_CAPACITY)	
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond2DHMS(time, 1) .. "</color>")	
end

---------------------------------------------------------------
--滚动条格子

RechargeCapacityCell = RechargeCapacityCell or BaseClass(BaseCell)

function RechargeCapacityCell:__init()
	self.nedd_gold = self:FindVariable("NeedGold")
	self.reward_list = {}
	for i = 1, 5 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("ItemList"))
		self.reward_list[i]:IgnoreArrow(true)
	end
	self:ListenEvent("ClickRechange",
		BindTool.Bind(self.ClickRechange, self))
end

function RechargeCapacityCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function RechargeCapacityCell:OnFlush()
	if nil == self.data then return end

	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	for k,v in pairs(self.reward_list) do
		if item_list[k] then
			v:SetData(item_list[k])
		end
		v.root_node:SetActive(item_list[k] ~= nil)
	end
	self.nedd_gold:SetValue(self.data.charge_value)
end

function RechargeCapacityCell:ClickRechange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end