HappyTreeView = HappyTreeView or BaseClass(BaseRender)

function HappyTreeView:__init(instance ,mother_view)
	self.mother_view = mother_view
	self.level = self:FindVariable("Level")
	self.grow_value_list = {}
	self.grow_value_each_list = {}
	for i=1,3 do
		self.grow_value_list[i] = self:FindVariable("GrowValue"..i)
		self.grow_value_each_list[i] = self:FindVariable("GrowValueEach"..i)
	end
	self:ListenEvent("GoToClick", BindTool.Bind(self.GoToClick, self))
	self:ListenEvent("ExchangeClick", BindTool.Bind(self.ExchangeClick, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.HelpClick, self))
	self:ListenEvent("CloseHelp", BindTool.Bind(self.CloseHelp, self, false))
	self:ListenEvent("CloseExchange", BindTool.Bind(self.CloseExchange, self))

	self.show_exchange = self:FindVariable("ShowExchange")
	self.show_exchange:SetValue(false)

	self:InitScroller()

	self.is_show_help = self:FindVariable("IsShowHelp")

	self.reward_apple_list = {}
	local item_manager = self:FindObj("RewardAppleManager")
	local child_number = item_manager.transform.childCount
	for i = 0, child_number - 1 do
		self.reward_apple_list[i + 1] = HappyTreeRewardCell.New(U3DObject(item_manager.transform:GetChild(i).gameObject))
	end

	local scale = WelfareData.Instance:GetHappyTreeTotalGrowScale()
	for k,v in pairs(scale) do
		self.grow_value_each_list[k]:SetValue(v.add_value)
	end

	self.process_apple_list = {}
	item_manager = self:FindObj("ProcessAppleManager")
	child_number = item_manager.transform.childCount
	for i = 0, child_number - 1 do
		self.process_apple_list[i + 1] = U3DObject(item_manager.transform:GetChild(i).gameObject)
	end

	self.day = self:FindVariable("Day")
	self.hour = self:FindVariable("Hour")
	self.min = self:FindVariable("Min")
	self.sec = self:FindVariable("Sec")
	self.exchange_score = self:FindVariable("ExchangeScore")
	self.exchange_is_today = self:FindVariable("ExchangeIsToday")
	self.exchange_red_point = self:FindVariable("ExchangeRedPoint")

	self.time_change_callback = BindTool.Bind(self.HandleTimeChange, self)
	self.time_count = WelfareData.Instance:GetExchangeLeftTime()

	self.time_quest = GlobalTimerQuest:AddRunQuest(self.time_change_callback, 1)

	self.score_change_callback = BindTool.Bind(self.FlushScore, self)

	self:Flush()
end

function HappyTreeView:__delete()
	GlobalTimerQuest:CancelQuest(self.time_quest)
end

function HappyTreeView:SetHappyTreeExchangeRedPoint()
	local had_click = WelfareData.Instance:GetHappyTreeExchangeHadClick()
	local is_open = ActivityData.Instance:GetActivityIsOpen(22)

	if had_click then
		self.exchange_red_point:SetValue(false)
	else
		self.exchange_red_point:SetValue(is_open)
	end
	self.exchange_is_today:SetValue(is_open)
end

function HappyTreeView:HandleTimeChange()
	self.time_count = self.time_count - 1

	local day, hour, min, sec = WelfareData.Instance:TimeFormatWithDay(self.time_count)
	self.day:SetValue(day)
	self.hour:SetValue(hour)
	self.min:SetValue(min)
	self.sec:SetValue(sec)
end

function HappyTreeView:InitScroller()
	self.scroller_data = {}

	local exchange_cfg = ExchangeData.Instance:GetExchangeCfgByType(6)
	local data = {}
	for k,v in pairs(exchange_cfg) do
		if #data < 4 then
			table.insert(data,v)
		else
			table.insert(self.scroller_data,data)
			data = {}
			table.insert(data,v)
		end
	end
	if next(data) ~= nil then
		table.insert(self.scroller_data,data)
	end

	self.cell_list = {}
	self.scroller = self:FindObj("ExchangeScroller")

	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local lua_cell = self.cell_list[cell]
		if nil == lua_cell then
			self.cell_list[cell] = ExchangeMotherCell.New(cell.gameObject)
			lua_cell = self.cell_list[cell]
		end
		local cell_data = self.scroller_data[data_index]

		lua_cell:SetData(cell_data)
	end
end

function HappyTreeView:OpenCallBack()

end

function HappyTreeView:Flush()
	local level = WelfareData.Instance:GetHappyTreeLevel()
	self.level:SetValue(level)
	for i=1,3 do
		local grow_value = WelfareData.Instance:GetHappyTreeGrowValueByType(i)
		local grow_cfg = WelfareData.Instance:GetHappyTreeGrowCfgByType(i)
		self.grow_value_list[i]:SetValue(grow_value.."/"..grow_cfg.max_value)
	end

	local reward_list = WelfareData.Instance:GetHappyTreeRewardCfg()
	local count = 1
	local apple_level = 0
	for k,v in ipairs(reward_list) do
		if count <= #self.reward_apple_list then
			self.process_apple_list[count]:SetActive(true)
			self.process_apple_list[count].image:LoadSprite(ResPath.GetWelfareRes("Happy_Tree_Apple_2"))
			if WelfareData.Instance:GetRewardFetchFlagByType(v.fecth_type) then
				apple_level = apple_level + 1
			end

			self.reward_apple_list[count]:SetActive(true)
			self.reward_apple_list[count]:SetData(v)
			count = count + 1
		end
	end

	for i = 1, apple_level do
		self.process_apple_list[i].image:LoadSprite(ResPath.GetWelfareRes("Happy_Tree_Apple_1"))
	end

	if count <= #self.reward_apple_list then
		for i=count,#self.reward_apple_list do
			self.process_apple_list[i]:SetActive(false)
			self.reward_apple_list[i]:SetActive(false)
		end
	end
end

--按下前往
function HappyTreeView:GoToClick()
	self.mother_view:Close()
	ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao)
end

function HappyTreeView:FlushScore()
	local score = ExchangeData.Instance:GetScoreList()[7]
	self.exchange_score:SetValue(score)
end

--按下兑换
function HappyTreeView:ExchangeClick()
	if self.exchange_red_point:GetBoolean() then
		WelfareData.Instance:SetHappyTreeExchangeHadClick()
		self.exchange_red_point:SetValue(false)
	end

	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.score_change_callback)
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
	self.show_exchange:SetValue(true)
end

--关闭兑换
function HappyTreeView:CloseExchange()
	ExchangeCtrl.Instance:UnNotifyWhenScoreChange(self.score_change_callback)
	self.show_exchange:SetValue(false)
end

--按下帮助
function HappyTreeView:HelpClick()
	local tips_id = 110 -- 欢乐果树帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--关闭帮助
function HappyTreeView:CloseHelp()
	self.is_show_help:SetValue(false)
end

--------------------------奖励苹果格子--------------------------
HappyTreeRewardCell = HappyTreeRewardCell or BaseClass(BaseCell)

function HappyTreeRewardCell:__init()
	self.had_got = self:FindVariable("HadGot")

	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.process_text = self:FindVariable("ProcessText")
	self.process_value = self:FindVariable("ProcessValue")
	self.can_get = self:FindVariable("CanGet")
	self:ListenEvent("GetClick", BindTool.Bind(self.GetClick, self))
end

function HappyTreeRewardCell:__delete()

end

function HappyTreeRewardCell:OnFlush()
	self.item_cell:SetData(self.data.reward_item)

	local fetch_flag = WelfareData.Instance:GetRewardFetchFlagByType(self.data.fecth_type)
	if fetch_flag then
		--已领取
		self.had_got:SetValue(true)
	else
		--未领取
		self.had_got:SetValue(false)
		local total_grow_value = WelfareData.Instance:GetHappyTreeTotalGrowValue()
		if total_grow_value >= self.data.growth_val then
			--可领取
			self.can_get:SetValue(true)
		else
			--不可领取
			self.can_get:SetValue(false)
			self.process_value:SetValue(total_grow_value/self.data.growth_val)
			self.process_text:SetValue(total_grow_value.."/"..self.data.growth_val)
		end
	end
end

function HappyTreeRewardCell:GetClick()
	WelfareCtrl.Instance:SendGetHappyTreeReward(self.data.fecth_type - 1)
end

--------------------------滚动条母格子--------------------------
ExchangeMotherCell = ExchangeMotherCell or BaseClass(BaseCell)

function ExchangeMotherCell:__init()
	self.child_cell_list = {}
	local child_number = self.root_node.transform.childCount
	for i = 0, child_number - 1 do
		self.child_cell_list[i + 1] = ExchangeChildCell.New(U3DObject(self.root_node.transform:GetChild(i).gameObject))
	end
end

function ExchangeMotherCell:__delete()

end

function ExchangeMotherCell:OnFlush()
	local count = 1
	for k,v in pairs(self.data) do
		self.child_cell_list[count]:SetActive(true)
		self.child_cell_list[count]:SetData(v)
		count = count + 1
	end
	if count <= #self.child_cell_list then
		for i=count,#self.child_cell_list do
			self.child_cell_list[i]:SetActive(false)
		end
	end
end

--------------------------滚动条子格子--------------------------
ExchangeChildCell = ExchangeChildCell or BaseClass(BaseCell)

function ExchangeChildCell:__init()
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.cost = self:FindVariable("Cost")

	self:ListenEvent("ExchangeClick", BindTool.Bind(self.ExchangeClick, self))
end

function ExchangeChildCell:__delete()

end

function ExchangeChildCell:OnFlush()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.item_cell:SetData(self.data)
	self.cost:SetValue(self.data.price)
end

function ExchangeChildCell:ExchangeClick()
	local is_open = ActivityData.Instance:GetActivityIsOpen(22)
	if is_open then
		-- TipsCtrl.Instance:ShowHappyTreeExchange(self.data)
		TipsCtrl.Instance:ShowExchangeView(self.data.item_id, EXCHANGE_PRICE_TYPE.HAPPYTREE, EXCHANGE_CONVER_TYPE.DAO_JU, nil)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Activity.HuoDongWeiKaiQi)
	end
end