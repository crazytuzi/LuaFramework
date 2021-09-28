ConsunmForGiftView = ConsunmForGiftView or BaseClass(BaseView)

function ConsunmForGiftView:__init()
	self.ui_config = {"uis/views/consumeforgift_prefab","ConsumeForGift"}
	self.cell_list = {}
end

function ConsunmForGiftView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.Close, self))
	self.act_time = self:FindVariable("ActTime")
	self.jifen = self:FindVariable("JiFen")
	self.per_gold = self:FindVariable("PreGlod")
	self:InitScroller()
	TipsCtrl.Instance:ChangeAutoViewAuto(false)
end

function ConsunmForGiftView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	-- 清理变量和对象
	self.per_gold = nil
	self.scroller = nil
	self.act_time = nil
	self.jifen = nil
end

function ConsunmForGiftView:InitScroller()
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	self.data = ConsumeForGiftData.Instance:GetConsumeForGiftCfg()

	delegate.NumberOfCellsDel = function()
		return math.ceil(#self.data / 5)
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  ConsumeForGiftItem.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end

		local cfg_list = {}
		for i = 1, 5 do
			cfg_list[i] = self.data[data_index * 5 + i - 5]
		end
		
		target_cell:SetData(cfg_list)
		target_cell:InitItems(cfg_list)
	end
end

function ConsunmForGiftView:OpenCallBack()
	RemindManager.Instance:Fire(RemindName.CousumeForGiftRemind)
	local param_t = {
		rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT,
		opera_type = RA_CONSUME_FOR_GIFT_OPERA_TYPE.RA_CONSUME_FOR_GIFT_OPERA_TYPE_ALL_INFO,
	}

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(param_t.rand_activity_type, param_t.opera_type)
	self:Flush()
end

function ConsunmForGiftView:OnFlush(param_t)
	self.per_gold:SetValue(self.data[1].points_per_gold)

	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	for k, v in pairs(self.cell_list) do
		v:FlushAllFrame()
	end
	local consume_for_gift_all_info = ConsumeForGiftData.Instance:GetConsumeForGiftAllInfo()
	
	self.jifen:SetValue(string.format(Language.ConsumeForGift.TotalGold, consume_for_gift_all_info.cur_points))
end

function ConsunmForGiftView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 6) .. "</color>")
	elseif time > 3600 then
		self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 1) .. "</color>")
	else
		self.act_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 2) .. "</color>")
	end
end

---------------------------------------------------------------
--滚动条格子

ConsumeForGiftItem = ConsumeForGiftItem or BaseClass(BaseCell)

function ConsumeForGiftItem:__init()
	self.exchange_contain_list = {}
	for i = 1, 5 do
		self.exchange_contain_list[i] = {}
		self.exchange_contain_list[i] = ConsumeForGiftItemCell.New(self:FindObj("item" .. i))
	end
end

function ConsumeForGiftItem:__delete()
	for k,v in pairs(self.exchange_contain_list) do
		v:DeleteMe()
	end
	self.exchange_contain_list = {}
end

function ConsumeForGiftItem:InitItems(item_id_list)
	for i=1, 5 do
		if nil ~= item_id_list[i] then
			self.exchange_contain_list[i]:SetItemData(item_id_list[i])
			self.exchange_contain_list[i]:OnFlush()
			self.exchange_contain_list[i]:SetActive(true)
		else
			self.exchange_contain_list[i]:SetActive(false)
		end
	end
end

function ConsumeForGiftItem:FlushItems(item_id_list,toggle_group)
	
end

function ConsumeForGiftItem:SetToggleGroup(toggle_group)
	for i=1,5 do
		self.exchange_contain_list[i]:SetToggleGroup(toggle_group)
	end
end

function ConsumeForGiftItem:FlushAllFrame()
	for i=1,5 do
		self.exchange_contain_list[i]:Flush()
	end
end
----------------------------------------------------------------------------
ConsumeForGiftItemCell = ConsumeForGiftItemCell or BaseClass(BaseCell)

function ConsumeForGiftItemCell:__init()
	self.item_data = {}
	
	self.name = self:FindVariable("name")
	self.doublejifen = self:FindVariable("doublejifen")
	self.needjifen = self:FindVariable("needjifen")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	local cfg = ConsumeForGiftData.Instance:GetConsumeForGiftCfg()
	self:ListenEvent("OnClick",BindTool.Bind(self.OnClick, self))
end

function ConsumeForGiftItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
	self.name = nil
	self.doublejifen = nil
	self.needjifen = nil 
end

function ConsumeForGiftItemCell:OnFlush()
	self.item_cell:SetData(self.item_data.exchange_item)
	if self.item_data.exchange_item == nil then return end

	local consume_for_gift_all_info = ConsumeForGiftData.Instance:GetConsumeForGiftAllInfo()
	if consume_for_gift_all_info.cur_points == nil then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_data.exchange_item.item_id)
	self.name:SetValue(string.format(Language.ConsumeForGift.ExchangeItemName, ITEM_COLOR[item_cfg.color], item_cfg.name))
	if self.item_data.double_points_need_ex_times - consume_for_gift_all_info.item_exchange_times[self.item_data.seq + 1] <= 0 then
		-- self.doublejifen:SetValue(string.format(Language.ConsumeForGift.DoubleJiFen,0))
		self.doublejifen:SetValue(Language.ConsumeForGift.IsMax)
	else
		self.doublejifen:SetValue(string.format(Language.ConsumeForGift.DoubleJiFen, self.item_data.double_points_need_ex_times - consume_for_gift_all_info.item_exchange_times[self.item_data.seq + 1]))
	end

	if consume_for_gift_all_info.item_exchange_times[self.item_data.seq + 1] >= self.item_data.double_points_need_ex_times then
		self.needjifen:SetValue("<color='#0000f1'>" .. (self.item_data.need_points * 2).. "</color>")

		if consume_for_gift_all_info.cur_points > self.item_data.need_points * 2 then
			self.needjifen:SetValue("<color='#0000f1'>" .. (self.item_data.need_points * 2) .. "</color>")
			ConsumeForGiftData.Instance:SetRedPoint(1)
		else
			self.needjifen:SetValue("<color='#ff0000'>" .. (self.item_data.need_points * 2) .. "</color>")
		end
	else
		if consume_for_gift_all_info.cur_points > self.item_data.need_points then
			self.needjifen:SetValue("<color='#0000f1'>" .. self.item_data.need_points .. "</color>")
			ConsumeForGiftData.Instance:SetRedPoint(1)
		else
			self.needjifen:SetValue("<color='#ff0000'>" .. self.item_data.need_points .. "</color>")
		end
	end
end

function ConsumeForGiftItemCell:SetItemData(item_id_list)
	self.item_data = item_id_list
end

function ConsumeForGiftItemCell:OnClick()
	local function ok_callback()
		local param_t = {
		rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_FOR_GIFT,
		opera_type = RA_CONSUME_FOR_GIFT_OPERA_TYPE.RA_CONSUME_FOR_GIFT_OPERA_TYPE_EXCHANGE_ITEM,
		param_1 = self.item_data.seq,
	}
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(param_t.rand_activity_type, param_t.opera_type, param_t.param_1)
		-- KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING, RA_RUSH_BUYING_OPERA_TYPE.RA_RUSH_BUYING_OPERA_TYPE_BUY_ITEM, self.data.index)
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_data.exchange_item.item_id)
	local consume_for_gift_all_info = ConsumeForGiftData.Instance:GetConsumeForGiftAllInfo()
	if consume_for_gift_all_info == nil then return end 
	local des = ""
	if consume_for_gift_all_info.item_exchange_times[self.item_data.seq + 1] >= self.item_data.double_points_need_ex_times then
		des = string.format(Language.ConsumeForGift.Des,"<color='#00ff00'>" .. (self.item_data.need_points * 2) .. "</color>",ITEM_COLOR[item_cfg.color], item_cfg.name)
	else
		des = string.format(Language.ConsumeForGift.Des,"<color='#00ff00'>" .. self.item_data.need_points .. "</color>",ITEM_COLOR[item_cfg.color], item_cfg.name)
	end
	
	TipsCtrl.Instance:ShowCommonAutoView("consumeforgift", des, ok_callback)
end