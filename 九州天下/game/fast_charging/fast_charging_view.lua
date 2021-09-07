FastChargingView = FastChargingView or BaseClass(BaseView)

function FastChargingView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/serveractivity/fastcharging", "FastChargingView"}
	self.play_audio = true
	self.cell_list = {}
end

function FastChargingView:__delete()

end

function FastChargingView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self.act_time = self:FindVariable("ActTime")
	self:InitScroller()
end

function FastChargingView:ReleaseCallBack()
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

function FastChargingView:InitScroller()
	self.scroller = self:FindObj("ListView")
	self.data = FastChargingData.Instance:GetFastChargingCfg()
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = FastChargingCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function FastChargingView:OpenCallBack()
	self:Flush()
end

function FastChargingView:ShowIndexCallBack(index)

end

function FastChargingView:CloseCallBack()

end

function FastChargingView:OnFlush(param_t)
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function FastChargingView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHARGE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_str = TimeUtil.FormatSecond2DHMS(time)
	self.act_time:SetValue("<color=#ffffff>" .. time_str .. "</color>")
	-- if time > 3600 * 24 then
	-- 	self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 6) .. "</color>")
	-- elseif time > 3600 then
	-- 	self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 1) .. "</color>")
	-- else
	-- 	self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 2) .. "</color>")
	-- end
end

---------------------------------------------------------------
--滚动条格子

FastChargingCell = FastChargingCell or BaseClass(BaseCell)

function FastChargingCell:__init()
	self.recharge_txt = self:FindVariable("RechargeTxt")
	self.reward_list = {}
	for i = 1, 4 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("ItemList"))
	end
	self:ListenEvent("ClickRechange",
		BindTool.Bind(self.ClickRechange, self))
end

function FastChargingCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function FastChargingCell:OnFlush()
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	for k,v in pairs(self.reward_list) do
		if item_list[k] then
			v:SetData(item_list[k])
		end
		v.root_node:SetActive(item_list[k] ~= nil)
	end
	self.recharge_txt:SetValue(self.data.charge_value)
end

function FastChargingCell:ClickRechange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end