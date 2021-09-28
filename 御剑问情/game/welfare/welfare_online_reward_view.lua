OnlineRewardView = OnlineRewardView or BaseClass(BaseRender)

function OnlineRewardView:__init()
	self.next_target_time = 99999
	self.cell_list = {}
	self.scroller_data = WelfareData.Instance:GetOnlineRewardCfg()
	self:InitScroller()

	self.hour = self:FindVariable("Hour")
	self.minute = self:FindVariable("Minute")
	self.second = self:FindVariable("Second")

	self.time_change_callback = BindTool.Bind(self.HandleTime, self)
	WelfareData.Instance:NotifyWhenTimeChange(self.time_change_callback)
end

function OnlineRewardView:__delete()
	if WelfareData.Instance ~= nil then
		WelfareData.Instance:UnNotifyWhenTimeChange(self.time_change_callback)
	end
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
end

function OnlineRewardView:HandleTime()
	local total_online_time = WelfareData.Instance:GetTotalOnlineTime()
	if total_online_time >= self.next_target_time * 60 then
		self:Flush()
	end

	local hour, min, sec = WelfareData.Instance:GetOnlineTime()
	self.hour:SetValue(hour)
	self.minute:SetValue(min)
	self.second:SetValue(sec)
end

function OnlineRewardView:Flush()
	self.next_target_time = 99999
	self.scroller_data = WelfareData.Instance:GetOnlineRewardCfg()
	self.scroller.scroller:RefreshActiveCellViews()
end

function OnlineRewardView:InitScroller()
	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")

	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local reward_cell = self.cell_list[cell]

		if nil == reward_cell then
			self.cell_list[cell] = OnlineRewardCell.New(cell.gameObject)
			reward_cell = self.cell_list[cell]
			reward_cell:SetMotherView(self)
		end

		local cell_data = self.scroller_data[data_index]
		reward_cell:SetData(cell_data)
	end
end

function OnlineRewardView:RecordGrayButton(min)
	if min < self.next_target_time then
		self.next_target_time = min
	end
end

---------------------------------------------------------------
--滚动条格子

OnlineRewardCell = OnlineRewardCell or BaseClass(BaseCell)

function OnlineRewardCell:__init()
	self.had_got = self:FindVariable("IsHadGot")
	self.online_time = self:FindVariable("OnlineTime")
	self.button = self:FindObj("Button").button
	self.button:AddClickListener(BindTool.Bind(self.GetRewardClick, self))
	self.mother_view = nil

	self.item_cell_list = {}
	local obj_group = self:FindObj("ItemManager")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "ItemCell") ~= nil then
			self.item_cell_list[count] = ItemCellReward.New()
			self.item_cell_list[count]:SetInstanceParent(obj)
			count = count + 1
		end
	end
end

function OnlineRewardCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
end

function OnlineRewardCell:SetMotherView(view)
	self.mother_view = view
end

function OnlineRewardCell:OnFlush()
	local count = 1
	if self.data.reward_item[0].item_id ~= 0 then
		self.item_cell_list[count]:SetData(self.data.reward_item[0])
		count = count + 1
	end
	if self.data.reward_item[1].item_id ~= 0 then
		self.item_cell_list[count]:SetData(self.data.reward_item[1])
		count = count + 1
	end
	if count <= #self.item_cell_list then
		for i=count,#self.item_cell_list do
			self.item_cell_list[i]:SetActive(false)
		end
	end

	self.online_time:SetValue(self.data.minutes..Language.Xunbao.FenZhong)

	local mark = WelfareData.Instance:OnlineRewardMark(self.data.seq)

	--已领取
	if mark then
		self.had_got:SetValue(true)
	--未领取
	else
		local can_get = WelfareData.Instance:CheckIsCanGetReward(self.data.minutes)
		--可领取
		if can_get then
			self.had_got:SetValue(false)
			self.button.interactable = true
		--不可领取
		else
			self.mother_view:RecordGrayButton(self.data.minutes)
			self.had_got:SetValue(false)
			self.button.interactable = false
		end
	end
end

function OnlineRewardCell:GetRewardClick()
	WelfareCtrl.Instance:SendGetOnlineReward(self.data.seq)
end
