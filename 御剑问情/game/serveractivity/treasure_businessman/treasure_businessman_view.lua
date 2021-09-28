TreasureBusinessmanView = TreasureBusinessmanView or BaseClass(BaseView)

function TreasureBusinessmanView:__init()
	self.ui_config = {"uis/views/businessmanview_prefab","BusinessmanView"}
	self.item_list = {}
	self.display_item_list = {}
	self.item_buffer = {}
	self.card_status = {}
	self.rare_list = {}
	self.all_buy_gold = 0
	self.zhenbaoge2_reflush_gold = 0
	self.zhenbaoge2_auto_flush_times = 0
	self.refresh_tags = false
end

function TreasureBusinessmanView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.Close, self))
	self:ListenEvent("buy_all", BindTool.Bind(self.SendBuyAllItemsReq, self))
	self:ListenEvent("refresh_ten", BindTool.Bind2(self.RefreshAllItems, self, 1))
	self:ListenEvent("refresh_item", BindTool.Bind2(self.RefreshAllItems, self, 0))
	self:ListenEvent("open_tips", BindTool.Bind(self.OpenTreasureLoftTips, self))
	self:ListenEvent("click_record", BindTool.Bind(self.OpenLogView, self))

	self.refresh_gold = self:FindVariable("refresh_gold")
	self.refresh_ten_gold = self:FindVariable("refresh_ten_gold")
	self.remain_time = self:FindVariable("remain_time")
	self.buy_all_desc = self:FindVariable("buy_all_desc")
	self.total_times = self:FindVariable("total_times")
	self.slider_val = self:FindVariable("slider_val")

	for i = 1, 6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end
	for i = 1, 9 do
		self.display_item_list[i] = ItemCell.New()
		self.display_item_list[i]:SetInstanceParent(self:FindObj("ItemDisplay" .. i))
		self.display_item_list[i]:ListenClick(BindTool.Bind2(self.SendRollCard,self,i))

		self["card_item" .. i] = self:FindObj("card_item" .. i)

		self["price_" .. i] = self:FindVariable("price" .. i)
		self["is_show" .. i] = self:FindVariable("is_show" .. i)
		self["item_name" .. i] = self:FindVariable("item_name" .. i)
		self:ListenEvent("choose_item"..i, BindTool.Bind2(self.SendRollCard,self,i))

	end

	self.total_reward_item_list = {}
	for i = 1, 6 do
		local total_reward_item = TotalrewardItem.New(self:FindObj("reward_item"..i))
		table.insert(self.total_reward_item_list, total_reward_item)
		self.total_reward_item_list[i]:SetCurIndex(i)
	end

	self:InitRareItemsDisplay()
	self:InitRollView()
end

function TreasureBusinessmanView:__delete()

end

function TreasureBusinessmanView:ReleaseCallBack()
	for i=1,6 do
		self.item_list[i]:DeleteMe()
	end
	for i=1,9 do
		self["price_" .. i] = nil
		self["is_show" .. i] = nil
		self["card_item" .. i] = nil
		self["item_name" .. i] = nil
		self.display_item_list[i]:DeleteMe()
	end

	for k,v in pairs(self.total_reward_item_list) do
		v:DeleteMe()
	end
	self.total_reward_item_list = {}

	self.refresh_gold = nil
	self.refresh_ten_gold = nil
	self.remain_time = nil
	self.buy_all_desc = nil
	self.total_times = nil
	self.slider_val = nil
	self.item_list = {}
	self.display_item_list = {}
	self.item_buffer = {}
	self.card_status = {}

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
		self.delay_timer = nil
	end

	if self.delay_timer2 then
		GlobalTimerQuest:CancelQuest(self.delay_timer2)
		self.delay_timer2 = nil
	end
end

function TreasureBusinessmanView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_QUERY_INFO)
	self:Flush()
end

function TreasureBusinessmanView:CloseCallBack()

end

function TreasureBusinessmanView:OpenTreasureLoftTips()
	TipsCtrl.Instance:ShowHelpTipView(226)
end

function TreasureBusinessmanView:OpenLogView()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN)
end

function TreasureBusinessmanView:InitRareItemsDisplay()
	for i=1, 9 do
		self["is_show" .. i]:SetValue(true)
	end
	local rare_item_table = TreasureBusinessmanData.Instance:GetDisplayItemTable()
	if rare_item_table ~= nil then
		for i = 1, 6 do
			if rare_item_table[i - 1] then
				self.item_list[i]:SetData(rare_item_table[i - 1])
			end
		end
	end
end

function TreasureBusinessmanView:InitRollView()
	local zhenbaoge2_cfg = KaifuActivityData.Instance:GetZhenBaoGe2Cfg()
	if zhenbaoge2_cfg == nil then return end
	local other_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	local str = ""
	if other_cfg ~= nil and other_cfg.other[1] ~= nil and other_cfg.other[1].zhenbaoge2_all_buy_reward ~= nil then
		str = ItemData.Instance:GetItemName(other_cfg.other[1].zhenbaoge2_all_buy_reward.item_id)
	end
	local tips = string.format(Language.TreasureLoft.BuyAllDesc, str)

	self.zhenbaoge2_reflush_gold = other_cfg.other[1].zhenbaoge2_reflush_gold
	self.zhenbaoge2_auto_flush_times = other_cfg.other[1].zhenbaoge2_auto_flush_times
	self.refresh_gold:SetValue(self.zhenbaoge2_reflush_gold)
	self.refresh_ten_gold:SetValue(self.zhenbaoge2_reflush_gold * self.zhenbaoge2_auto_flush_times)
	for i = 1, GameEnum.RAND_ACTIVITY_ZHENBAOGE_ITEM_COUNT do
		if nil ~= self.display_item_list[i] then
			self.card_status[i] = NEQ_CARD_STATUS.OPEN
			self.display_item_list[i]:SetData(zhenbaoge2_cfg[1].reward_item)
			self["price_" .. i]:SetValue(zhenbaoge2_cfg[1].buy_consume_gold)
		end
	end
	self.buy_all_desc:SetValue(tips)
end

function TreasureBusinessmanView:RefreshAllItems(num)
	local flag = TreasureBusinessmanData.Instance:HasRareItemNotBuy()
	local gold = (num == 0) and (self.zhenbaoge2_reflush_gold) or (self.zhenbaoge2_reflush_gold*self.zhenbaoge2_auto_flush_times)
	if PlayerData.Instance:GetRoleVo().gold < gold then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end
	if 0 == num then
		local tips = string.format(Language.TreasureLoft.ResetTips, self.zhenbaoge2_reflush_gold)
		if flag then 
			tips = tips .. '\n' .. Language.TreasureLoft.RareItemNotBuyTip2
		end
		local yes_func = function() self:SendReq(0) end
		TipsCtrl.Instance:ShowCommonAutoView("refresh2_one", tips, yes_func, nil, nil, nil, nil, nil, true, true)
	elseif 1 == num then
		local tips = string.format(Language.TreasureLoft.OneKeyResetRare, self.zhenbaoge2_reflush_gold*self.zhenbaoge2_auto_flush_times, self.zhenbaoge2_auto_flush_times)
		if flag then 
			tips = tips .. '\n' .. Language.TreasureLoft.RareItemNotBuyTip2
		end
		local yes_func = function() self:SendReq(1) end
		TipsCtrl.Instance:ShowCommonAutoView("refresh2_ten", tips, yes_func, nil, nil, nil, nil, nil, true, true)
	end
end

function TreasureBusinessmanView:SendReq(num)
	if num == 0 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_FLUSH)
		self.refresh_tags = true
	elseif num == 1 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_RARE_FLUSH)
		self.refresh_tags = true
	elseif num == 2 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPEAR_TYPE_BUY_ALL)
	end
end

function TreasureBusinessmanView:SendRollCard(index)
	if NEQ_CARD_STATUS.DEFAULT == self.card_status[index] then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_BUY, index -1)
		return
	end
	self.display_item_list[index]:SetHighLight(false)
	if not next(self.item_buffer) then return end
	local item_name = ItemData.Instance:GetItemName(self.item_buffer[index].item.item_id)

	local tips = string.format(Language.TreasureLoft.DrawTips, self.item_buffer[index].price , item_name, self.item_buffer[index].item.num)
	local yes_func = function()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_BUY, index -1)
	end
	TipsCtrl.Instance:ShowCommonAutoView("buy_one", tips, yes_func, nil, nil, nil, nil, nil, true, true)
end

function TreasureBusinessmanView:SendBuyAllItemsReq()
	-- if not next(self.item_buffer) then self:SendReq(2) return end
	local str = ""
	local randact_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	if randact_cfg ~= nil and randact_cfg.other[1] ~= nil and randact_cfg.other[1].zhenbaoge2_all_buy_reward ~= nil then
		str = ItemData.Instance:GetItemName(randact_cfg.other[1].zhenbaoge2_all_buy_reward.item_id)
	end
	if self.all_buy_gold > 0 then
		local tips = string.format(Language.TreasureLoft.AllBuyTips,self.all_buy_gold, str)
		local yes_func = function() self:SendReq(2) end
		TipsCtrl.Instance:ShowCommonAutoView("buy_ten", tips, yes_func, nil, nil, nil, nil, nil, true, true)
	else
		self:SendReq(2)
	end
end

function TreasureBusinessmanView:DoCardFlipAction()
	for i=1,9 do
		self["is_show" .. i]:SetValue(true)
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

function TreasureBusinessmanView:ResetItemGrid( ... )
	for i=1,9 do
		self["is_show" .. i]:SetValue(false)
	end
	self.refresh_tags = false
end

function TreasureBusinessmanView:FlushNextFlushTimer()
	local nexttime = TreasureBusinessmanData.Instance:GetNextFlushTimeStamp() - TimeCtrl.Instance:GetServerTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if nexttime ~= nil then	
		 self:UpdataRollerTime(0, nexttime)
		 self.count_down = CountDown.Instance:AddCountDown(nexttime,1,BindTool.Bind1(self.UpdataRollerTime, self))	
	end
end

function TreasureBusinessmanView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - elapse_time
	if self.remain_time ~= nil then
		if time > 0 then
			self.remain_time:SetValue(TimeUtil.FormatSecond2HMS(time))
		else
			self.remain_time:SetValue("00:00:00")
		end
	end
end

function TreasureBusinessmanView:OnFlush()
	self:FlushItemGrid()
	self:FlushServerFetchReward()
	self:FlushNextFlushTimer()
end

function TreasureBusinessmanView:FlushItemGrid()
	self.all_buy_gold = 0
	local zhenbaoge_item_list = TreasureBusinessmanData.Instance:GetTreasureLoftGridData()
	local zhenbaoge2_cfg = KaifuActivityData.Instance:GetZhenBaoGe2Cfg()
	if zhenbaoge2_cfg == nil or zhenbaoge_item_list == nil then return end
	for i = 0, #zhenbaoge_item_list do
		if zhenbaoge_item_list[i] ~= 0 then
			local data = {}
			self.card_status[i + 1] = NEQ_CARD_STATUS.OPEN
			self["is_show" .. (i + 1)]:SetValue(false)
			self.display_item_list[i + 1]:SetData(zhenbaoge2_cfg[zhenbaoge_item_list[i]].reward_item)
			self["price_" .. (i + 1)]:SetValue(zhenbaoge2_cfg[zhenbaoge_item_list[i]].buy_consume_gold)
			self.rare_list[i + 1] = zhenbaoge2_cfg[zhenbaoge_item_list[i]].is_rare
			if 1 == self.rare_list[i + 1] then
				self.display_item_list[i + 1]:ShowGetEffect(true)
			else
				self.display_item_list[i + 1]:ShowGetEffect(false)
			end

			data.item = zhenbaoge2_cfg[zhenbaoge_item_list[i]].reward_item
			data.price = zhenbaoge2_cfg[zhenbaoge_item_list[i]].buy_consume_gold
			data.is_rare = zhenbaoge2_cfg[zhenbaoge_item_list[i]].is_rare

			self.item_buffer[i + 1] = data

			local item_name = ItemData.Instance:GetItemName(self.item_buffer[i + 1].item.item_id)
			self["item_name" .. (i + 1)]:SetValue(item_name)
			self.all_buy_gold = self.all_buy_gold + zhenbaoge2_cfg[zhenbaoge_item_list[i]].buy_consume_gold
		else
			self["is_show" .. (i + 1)]:SetValue(true)
			self.card_status[i + 1] = NEQ_CARD_STATUS.DEFAULT
		end
	end

	if next(zhenbaoge_item_list) and self.refresh_tags then
		self:DoCardFlipAction()
	end
end

function TreasureBusinessmanView:FlushServerFetchReward()
local data = TreasureBusinessmanData.Instance:GetRewardListData()
	for i = 1, 6 do
		self.total_reward_item_list[i]:SetData(data[i - 1])
	end
	local flush_times = TreasureBusinessmanData.Instance:GetServerFlushTimes() or 0
	self.total_times:SetValue(flush_times)
	self.slider_val:SetValue(TreasureBusinessmanData.Instance:GetProValueByTimes(flush_times))
end
----------------------------------TotalrewardItem-------------------------------------
TotalrewardItem = TotalrewardItem or BaseClass(BaseRender)

function TotalrewardItem:__init()
    self.item = self:FindObj("Item")
    self.times = self:FindVariable("Times")
    self.item_cell = ItemCell.New()
    self.item_cell:SetInstanceParent(self.item)
    self.have_got = self:FindVariable("HaveGot")
    self.show_eff = self:FindVariable("ShowEff")
end

function TotalrewardItem:__delete()
    if self.item_cell then
        self.item_cell:DeleteMe()
    end
end

function TotalrewardItem:SetCurIndex(index)
	self.cur_index = index
end

function TotalrewardItem:SetData(data)
    self.times:SetValue(data.can_fetch_times)
    self.show_eff:SetValue(false)
    local fetch_flag = TreasureBusinessmanData.Instance:GetZhenBaoGeFetchFlagByIndex(self.cur_index)
    local cur_num = TreasureBusinessmanData.Instance:GetServerFlushTimes() or 0
    local can_get = cur_num >= data.can_fetch_times
    local click_func = nil
    if cur_num >= data.can_fetch_times then
    	if 1 == fetch_flag then
    		self.have_got:SetValue(true)
    	else
    		self.have_got:SetValue(false)
    		click_func = function()
                self.item_cell:SetHighLight(false)
                KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_FETCH_SERVER_GIFT, self.cur_index)
                AudioService.Instance:PlayRewardAudio()
            end
            self.item_cell:ListenClick(click_func)
    	end
    else
    	self.have_got:SetValue(false)
    	click_func = function()
            TipsCtrl.Instance:OpenItem(data.reward_item)
            self.item_cell:SetHighLight(false)
        end
         self.item_cell:ListenClick(click_func)
    end
    self:ShowData(can_get and fetch_flag ~= 1)
    self.item_cell:SetData(data.reward_item)
end

function TotalrewardItem:ShowData(is_show)
    if self.item_cell and is_show then
        self.item_cell:IsDestroyEffect(true)
        self.show_eff:SetValue(true)
    end
end