TreasureLoftView = TreasureLoftView or BaseClass(BaseView)

function TreasureLoftView:__init()
	self.ui_config = {"uis/views/treasureloft","TreasureLoftView"}
	self.item_list = {}
	self.display_item_list = {}
	self.item_buffer = {}
	self.card_status = {}
	self.rare_list = {}
	self.contain_cell_list = {}
	self.all_buy_gold = 0
	self.zhenbaoge_reflush_gold = 0
	self.zhenbaoge_auto_flush_times = 0
	self.refresh_tags = false
	self:SetMaskBg()
end

function TreasureLoftView:LoadCallBack()
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self:ListenEvent("close_view", BindTool.Bind(self.Close, self))
	self:ListenEvent("buy_all", BindTool.Bind(self.SendBuyAllItemsReq, self))
	self:ListenEvent("refresh_ten", BindTool.Bind2(self.RefreshAllItems, self, 1))
	self:ListenEvent("refresh_item", BindTool.Bind2(self.RefreshAllItems, self, 0))
	self:ListenEvent("open_tips", BindTool.Bind(self.OpenTreasureLoftTips, self))

	self.refresh_gold = self:FindVariable("refresh_gold")
	self.remain_time = self:FindVariable("remain_time")
	self.buy_all_desc = self:FindVariable("buy_all_desc")
	self.show_gold_cost = self:FindVariable("show_gold_cost")
	self.key_num = self:FindVariable("KeyNum")

	for i = 1, 9 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))

		self.display_item_list[i] = ItemCell.New()
		self.display_item_list[i]:SetInstanceParent(self:FindObj("ItemDisplay" .. i))
		self.display_item_list[i]:ListenClick(BindTool.Bind2(self.SendRollCard,self,i))

		self["card_item" .. i] = self:FindObj("card_item" .. i)

		self["price_" .. i] = self:FindVariable("price" .. i)
		self["is_show" .. i] = self:FindVariable("is_show" .. i)
		self["item_name" .. i] = self:FindVariable("item_name" .. i)
		self:ListenEvent("choose_item"..i, BindTool.Bind2(self.SendRollCard,self,i))

	end

	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:InitRareItemsDisplay()
	self:InitRollView()
	self:FlushKeyNum()
	--self:FlushActEndTime()
end

function TreasureLoftView:__delete()
	
end

function TreasureLoftView:ReleaseCallBack()
	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	for i=1,9 do
		self["price_" .. i] = nil
		self["is_show" .. i] = nil
		self["card_item" .. i] = nil
		self["item_name" .. i] = nil
		self.item_list[i]:DeleteMe()
		self.display_item_list[i]:DeleteMe()
	end

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	self.refresh_gold = nil
	self.remain_time = nil
	self.list_view = nil
	self.buy_all_desc = nil
	self.show_gold_cost = nil
	self.key_num = nil
	self.item_list = {}
	self.display_item_list = {}
	self.item_buffer = {}
	self.card_status = {}

	-- if self.act_next_timer then
	-- 	GlobalTimerQuest:CancelQuest(self.act_next_timer)
	-- 	self.act_next_timer = nil
	-- end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end
	if self.tweener2 then
		self.tweener2:Pause()
		self.tweener2 = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
	end

	if self.delay_timer2 then
		GlobalTimerQuest:CancelQuest(self.delay_timer2)
	end
end

function TreasureLoftView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_QUERY_INFO)
	self:Flush()
end

function TreasureLoftView:CloseCallBack()

end

function TreasureLoftView:OpenTreasureLoftTips()
	TipsCtrl.Instance:ShowHelpTipView(191)
end

function TreasureLoftView:GetNumberOfCells()
	local data = TreasureLoftData.Instance:GetRewardListData()
	if #data%2 ~= 0 then
		return math.ceil(#data/2)
	else
		return #data/2
	end
end

-- function TreasureLoftView:FlushActEndTime()
-- 	-- 活动倒计时
-- 	if self.act_next_timer then
-- 		GlobalTimerQuest:CancelQuest(self.act_next_timer)
-- 		self.act_next_timer = nil
-- 	end
-- 	self:FlushUpdataActEndTime()
-- 	self.act_next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushUpdataActEndTime, self), 60)
-- end

-- function TreasureLoftView:FlushUpdataActEndTime()
-- 	local time_str = JinYinTaData.Instance:GetActEndTime()
-- 	local time_tab = TimeUtil.Format2TableDHMS(time_str)
-- 	local value_str = string.format(Language.JinYinTa.ActEndTime,time_tab.day,time_tab.hour,time_tab.min)
--  	self.remain_time:SetValue(value_str)
--  	if time_str <= 0  then
--  		-- 移除计时器
-- 		if self.act_next_timer then
-- 			GlobalTimerQuest:CancelQuest(self.act_next_timer)
-- 			self.act_next_timer = nil
-- 		end
	 	
--  	end
-- end

function TreasureLoftView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TreasureLoftItems.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
		contain_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	local data = TreasureLoftData.Instance:GetRewardListData()
	cell_index = cell_index + 1
	contain_cell:InitItems(data)
	contain_cell:SetRowNum(cell_index)
	contain_cell:Flush()
end

function TreasureLoftView:InitRareItemsDisplay()
	local rare_item_table = TreasureLoftData.Instance:GetDisplayItemTable()
	if rare_item_table ~= nil then
		for i=1, 9 do
			if rare_item_table[i - 1] then
				self.item_list[i]:SetData(rare_item_table[i - 1])
				self["is_show" .. i]:SetValue(true)
			end
		end
	end
end

function TreasureLoftView:FlushKeyNum()
	local num = ItemData.Instance:GetItemNumInBagById(26771)
	if num > 0 then
		self.show_gold_cost:SetValue(true)
		self.key_num:SetValue(num)
	else
		self.show_gold_cost:SetValue(false)
	end
end

function TreasureLoftView:InitRollView()
	local zhenbaoge_cfg = KaifuActivityData.Instance:GetZhenBaoGeCfg()
	if zhenbaoge_cfg == nil then return end
	local other_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	local str = ""
	if other_cfg ~= nil and other_cfg.other[1] ~= nil and other_cfg.other[1].zhenbaoge_all_buy_reward ~= nil then
		str = ItemData.Instance:GetItemName(other_cfg.other[1].zhenbaoge_all_buy_reward.item_id)
	end
	local tips = string.format(Language.TreasureLoft.BuyAllDesc, str)

	self.zhenbaoge_reflush_gold = other_cfg.other[1].zhenbaoge_reflush_gold
	self.zhenbaoge_auto_flush_times = other_cfg.other[1].zhenbaoge_auto_flush_times
	self.refresh_gold:SetValue(self.zhenbaoge_reflush_gold)
	for i = 1, GameEnum.RAND_ACTIVITY_ZHENBAOGE_ITEM_COUNT do
		if nil ~= self.display_item_list[i] then
			self.card_status[i] = NEQ_CARD_STATUS.OPEN
			self.display_item_list[i]:SetData(zhenbaoge_cfg[1].reward_item)
			self["price_" .. i]:SetValue(zhenbaoge_cfg[1].buy_consume_gold)
		end
	end
	self.buy_all_desc:SetValue(tips)
end

function TreasureLoftView:RefreshAllItems(num)
	local flag = TreasureLoftData.Instance:HasRareItemNotBuy()
	local is_has_key = self.show_gold_cost:GetBoolean()
	local gold = (num == 0) and (self.zhenbaoge_reflush_gold) or (self.zhenbaoge_reflush_gold*self.zhenbaoge_auto_flush_times)
	if PlayerData.Instance:GetRoleVo().gold < gold and not is_has_key then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end
	local yes_func = function() self:SendReq(num) end
	local zhenbaoge_item_list = TreasureLoftData.Instance:GetTreasureLoftGridData()
	for k,v in pairs(self.item_buffer) do
		if v.is_rare == 1 and zhenbaoge_item_list[k - 1] ~= 0 then
			local tips = Language.TreasureLoft.NeedBuy
			TipsCtrl.Instance:ShowCommonTip(yes_func, nil, tips)
			-- TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func)
			return
		end
	end

	if is_has_key then
		self:SendReq(num)
		return
	end

	if 0 == num then
		local tips = string.format(Language.TreasureLoft.ResetTips, self.zhenbaoge_reflush_gold)
		if flag then 
			tips = tips .. '\n' .. Language.TreasureLoft.RareItemNotBuyTip
		end
		TipsCtrl.Instance:ShowCommonAutoView("refresh_one", tips, yes_func, nil, nil, nil, nil, nil, true, false)
	elseif 1 == num then
		local tips = string.format(Language.TreasureLoft.OneKeyResetRare, self.zhenbaoge_reflush_gold*self.zhenbaoge_auto_flush_times, self.zhenbaoge_auto_flush_times)
		if flag then 
			tips = tips .. '\n' .. Language.TreasureLoft.RareItemNotBuyTip
		end
		TipsCtrl.Instance:ShowCommonAutoView("refresh_ten", tips, yes_func, nil, nil, nil, nil, nil, true, false)
	end
end

function TreasureLoftView:SendReq(num)
	if num == 0 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_FLUSH)
		self.refresh_tags = true
	elseif num == 1 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_RARE_FLUSH)
		self.refresh_tags = true
	elseif num == 2 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_BUY_ALL)
	end
end

function TreasureLoftView:SendRollCard(index)
	if NEQ_CARD_STATUS.DEFAULT == self.card_status[index] then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_BUY, index -1)
		return
	end
	self.display_item_list[index]:SetHighLight(false)
	if not next(self.item_buffer) then return end
	local item_name = ItemData.Instance:GetItemName(self.item_buffer[index].item.item_id)

	local tips = string.format(Language.TreasureLoft.DrawTips, self.item_buffer[index].price , item_name, self.item_buffer[index].item.num)
	local yes_func = function()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_BUY, index -1)
	end
	TipsCtrl.Instance:ShowCommonAutoView("buy_one", tips, yes_func, nil, nil, nil, nil, nil, true, false)
end

function TreasureLoftView:SendBuyAllItemsReq()
	-- if not next(self.item_buffer) then self:SendReq(2) return end
	local str = ""
	local randact_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	if randact_cfg ~= nil and randact_cfg.other[1] ~= nil and randact_cfg.other[1].zhenbaoge_all_buy_reward ~= nil then
		str = ItemData.Instance:GetItemName(randact_cfg.other[1].zhenbaoge_all_buy_reward.item_id)
	end
	if self.all_buy_gold > 0 then
		local tips = string.format(Language.TreasureLoft.AllBuyTips,self.all_buy_gold, str)
		local yes_func = function() self:SendReq(2) end
		TipsCtrl.Instance:ShowCommonAutoView("buy_ten", tips, yes_func, nil, nil, nil, nil, nil, true, false)
	else
		self:SendReq(2)
	end
end

function TreasureLoftView:DoCardFlipAction()
	for i=1,9 do
		self["is_show" .. i]:SetValue(true)
		-- if self.tweener1 then
		-- 	self.tweener1:Pause()
		-- end
		self["card_item" .. i].rect:SetLocalScale(1, 1, 1)
		local target_scale = Vector3(0, 1, 1)
		local target_scale2 = Vector3(1, 1, 1)
		self.tweener1 = self["card_item" .. i].rect:DOScale(target_scale, 0.5)

		local func2 = function()
			self.tweener2 = self["card_item" .. i].rect:DOScale(target_scale2, 0.5)
		end
		self.delay_timer2 = GlobalTimerQuest:AddDelayTimer(func2, 0.5)

	end
	local func = function()
		self:ResetItemGrid()
	end
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(func, 0.5)
end

function TreasureLoftView:ResetItemGrid( ... )
	for i=1,9 do
		self["is_show" .. i]:SetValue(false)
	end
	self.refresh_tags = false
end

function TreasureLoftView:FlushNextFlushTimer()
	local nexttime = TreasureLoftData.Instance:GetNextFlushTimeStamp() - TimeCtrl.Instance:GetServerTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if nexttime ~= nil then	
		 self:UpdataRollerTime(0, nexttime)
		 self.count_down = CountDown.Instance:AddCountDown(nexttime,1,BindTool.Bind1(self.UpdataRollerTime, self))	
	end
end

function TreasureLoftView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - elapse_time
	if self.remain_time ~= nil then
		if time > 0 then
			self.remain_time:SetValue(TimeUtil.FormatSecond2HMS(time))
		else
			self.remain_time:SetValue("00:00:00")
		end
	end
end

function TreasureLoftView:OnFlush()
	self:FlushItemGrid()
	self:FlushServerFetchReward()
	self:FlushNextFlushTimer()
	self:FlushKeyNum()
	--self:FlushNextFlushTimer()
	--self:FlushTotalFlushNum()
end

function TreasureLoftView:FlushItemGrid()
	self.all_buy_gold = 0
	local zhenbaoge_item_list = TreasureLoftData.Instance:GetTreasureLoftGridData()
	local zhenbaoge_cfg = KaifuActivityData.Instance:GetZhenBaoGeCfg()
	if zhenbaoge_cfg == nil or zhenbaoge_item_list == nil then return end
	for i = 0, #zhenbaoge_item_list do
		if zhenbaoge_item_list[i] ~= 0 then
			local data = {}
			self.card_status[i + 1] = NEQ_CARD_STATUS.OPEN
			self["is_show" .. (i + 1)]:SetValue(false)
			self.display_item_list[i + 1]:SetData(zhenbaoge_cfg[zhenbaoge_item_list[i]].reward_item)
			self["price_" .. (i + 1)]:SetValue(zhenbaoge_cfg[zhenbaoge_item_list[i]].buy_consume_gold)
			self.rare_list[i + 1] = zhenbaoge_cfg[zhenbaoge_item_list[i]].is_rare
			if 1 == self.rare_list[i + 1] then
				self.display_item_list[i + 1]:ShowGetEffect(true)
			else
				self.display_item_list[i + 1]:ShowGetEffect(false)
			end

			data.item = zhenbaoge_cfg[zhenbaoge_item_list[i]].reward_item
			data.price = zhenbaoge_cfg[zhenbaoge_item_list[i]].buy_consume_gold
			data.is_rare = zhenbaoge_cfg[zhenbaoge_item_list[i]].is_rare

			self.item_buffer[i + 1] = data

			local item_name = ItemData.Instance:GetItemName(self.item_buffer[i + 1].item.item_id)
			self["item_name" .. (i + 1)]:SetValue(item_name)
			self.all_buy_gold = self.all_buy_gold + zhenbaoge_cfg[zhenbaoge_item_list[i]].buy_consume_gold
		else
			--self:SetCoverShow(true, i + 1)
			self["is_show" .. (i + 1)]:SetValue(true)
			self.card_status[i + 1] = NEQ_CARD_STATUS.DEFAULT
		end
	end

	if next(zhenbaoge_item_list) and self.refresh_tags then
		self:DoCardFlipAction()
	end
end

function TreasureLoftView:FlushServerFetchReward()
	self.list_view.scroller:ReloadData(0)
end

-- function TreasureLoftView:FlushNextFlushTimer()
-- 	local nexttime = TreasureLoftData.Instance:GetNextFlushTimeStamp()
-- 	if CountDown.Instance:HasCountDown("openserver_treasure_loft") then
-- 		CountDown.Instance:RemoveCountDown("openserver_treasure_loft")
-- 	end
-- 	if nexttime ~= nil then	
-- 		CountDown.Instance:AddCountDown("openserver_treasure_loft",
-- 		 BindTool.Bind1(self.UpdataRollerTime, self), BindTool.Bind1(self.CompleteRollerTime, self), nexttime, nil, 1)	
-- 	end
-- end

-- function TreasureLoftView:FlushTotalFlushNum()
-- 	local total_flush_num = TreasureLoftData.Instance:GetServerFlushTimes()
-- 	if total_flush_num ~= nil then
-- 		self.label_flush_time:setString(total_flush_num .. Language.RechargeChouChouLe.Ci)
-- 	end
-- end

------------------------------------------------------------------------
TreasureLoftItems = TreasureLoftItems  or BaseClass(BaseCell)

function TreasureLoftItems:__init()
	self.contain_list = {}
	self.row_num = 1
	for i = 1, 2 do
		self.contain_list[i] = {}
		self.contain_list[i] = TreasureVipItems.New(self:FindObj("item_" .. i))
	end
end

function TreasureLoftItems:__delete()
	for i=1, 2 do
		self.contain_list[i]:DeleteMe()
		self.contain_list[i] = nil
	end
end

function TreasureLoftItems:GetFirstCell()
	return self.contain_list[1]
end

function TreasureLoftItems:SetRowNum(num)
	self.row_num = num
end

function TreasureLoftItems:InitItems(data)
	local index = self:GetIndex()
	for i=1,2 do
		local true_index = 2 * (self.row_num - 1) + i
		self.contain_list[i]:SetItemData(data)
		self.contain_list[i]:SetTrueIndex(true_index)
		self.contain_list[i]:OnFlush()
	end
end

function TreasureLoftItems:OnFlush()

end

function TreasureLoftItems:SetToggleGroup(toggle_group)
	for i=1,2 do
		self.contain_list[i]:SetToggleGroup(toggle_group)
	end
end

function TreasureLoftItems:FlushAllFrame()
	for i=1,2 do
		self.contain_list[i]:OnFlush()
	end
end

----------------------------------------------------------------------------
TreasureVipItems = TreasureVipItems or BaseClass(BaseCell)

function TreasureVipItems:__init()
	self.true_index = 1
	self.reward_data = {}
	self.vip_desc = self:FindVariable("vip_desc")
	self.fetch_num = self:FindVariable("fetch_num")
	self.fetch_desc = self:FindVariable("fetch_desc")
	self.cur_num = self:FindVariable("cur_num")
	self.show_eff = self:FindVariable("show_eff")
	self.red_point = self:FindVariable("red_point")
	self.show_progress_text = self:FindVariable("show_progress_text")
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick,self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	--self.item_cell:ShowHighLight(false)
end

function TreasureVipItems:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
	self.cur_num = nil
	self.fetch_num = nil
	self.vip_desc = nil
	self.fetch_desc = nil
	self.show_eff = nil
	self.red_point = nil
	self.show_progress_text = nil
	self.reward_data = {}
end

function TreasureVipItems:SetItemData(data)
	self.reward_data = data
end

function TreasureVipItems:SetTrueIndex(num)
	self.true_index = num
end

function TreasureVipItems:OnFlush()
	local item_data = self.reward_data[self.true_index - 1]
	local cur_num = TreasureLoftData.Instance:GetServerFlushTimes() or 0
	local fetch_flag = TreasureLoftData.Instance:GetZhenBaoGeFetchFlagByIndex(self.true_index)
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	if next(item_data) then
		self.vip_desc:SetValue(string.format(Language.TreasureLoft.VIP, item_data.vip_limit))
		self.fetch_num:SetValue(item_data.can_fetch_times)
		self.item_cell:SetData(item_data.reward_item)
		self.cur_num:SetValue(cur_num)
		--self.item_cell:SetActivityEffect()

		if cur_num >= item_data.can_fetch_times then
			if 1 == fetch_flag then
				self.fetch_desc:SetValue(Language.Activity.FlagAlreadyReceive)
				self.show_eff:SetValue(true)
				self.red_point:SetValue(false)
				self.item_cell:ShowHaseGet(true)
				self.item_cell:ShowGetEffect(false)
			else
				self.fetch_desc:SetValue(Language.Activity.FlagCanReceive)
				self.show_eff:SetValue(false)
				self.item_cell:ShowHaseGet(false)
				self.item_cell:ShowGetEffect(true)
				if vip_level < item_data.vip_limit then
					self.red_point:SetValue(false)
				else
					self.red_point:SetValue(true)
				end
			end
			self.show_progress_text:SetValue(true)
		else
			self.fetch_desc:SetValue(Language.TreasureLoft.RefreshTarget)
			self.item_cell:ShowHaseGet(false)
			self.show_eff:SetValue(false)
			self.red_point:SetValue(false)
			self.item_cell:ShowGetEffect(false)
			self.show_progress_text:SetValue(false)
		end
	end
	if self.click_self then
		self:OnToggleClick(true)
		self.click_self = false
	end
end

function TreasureVipItems:SelectToggle()
	--self.root_node.toggle.isOn = true
end

function TreasureVipItems:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
	self.root_node.toggle.isOn = false
end

function TreasureVipItems:OnToggleClick(is_click)
	if is_click then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_FETCH_SERVER_GIFT, self.true_index)
	end
end