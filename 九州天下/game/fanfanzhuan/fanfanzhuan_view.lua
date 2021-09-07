FanFanZhuanView = FanFanZhuanView or BaseClass(BaseView)

-- 累计充值次数最大档次
local MAX_PROG_GRADE = 3

function FanFanZhuanView:__init()
	self.ui_config = {"uis/views/fanfanzhuan","FanFanZhuanView"}
	self.item_list = {}
	self.display_item_list = {}
	self.item_buffer = {}
	self.card_status = {}
	self.rare_list = {}
	self.contain_cell_list = {}
	self.all_buy_gold = 0
	self.zhenbaoge_reflush_gold = 0
	self.zhenbaoge_auto_flush_times = 0

	self.auto_buy_flag_list = {
		["auto_type_1"] = false,
		["auto_type_10"] = false,
		["auto_type_50"] = false,
	}
	self:SetMaskBg()
end

function FanFanZhuanView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnclickReset", BindTool.Bind(self.OnclickReset, self))
	self:ListenEvent("refresh_ten", BindTool.Bind2(self.RefreshAllItems, self, 10))
	self:ListenEvent("refresh_many", BindTool.Bind2(self.RefreshAllItems, self, 50))
	self:ListenEvent("open_tips", BindTool.Bind(self.OpenTreasureLoftTips, self))
	self:ListenEvent("OnClickWarehouse", BindTool.Bind(self.OnClickWarehouse, self))
	self:ListenEvent("OnClickTurnPageLeft", BindTool.Bind2(self.OnClickTurnPage, self, "left"))
	self:ListenEvent("OnClickTurnPageRight", BindTool.Bind2(self.OnClickTurnPage, self, "right"))
	
	self.item_list = {}
	for i=1,6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end

	self.level_item_list = {}
	self.is_show_select_list = {}
	self.page_point_list = {}
	for i=0,2 do
		self.level_item_list[i] = self:FindObj("level_item" .. i)
		self:ListenEvent("OnClickLevel" .. i, BindTool.Bind2(self.OnClickLevel,self,i))
		self.is_show_select_list[i] = self:FindVariable("is_show_select" .. i)
		self.page_point_list[i] = self:FindVariable("PagePoint" .. i)
		-- self.level_item_list[i]:AddClickListener(BindTool.Bind2(self.OnClickLevel,self,i))
	end
	
	for i = 0, 8 do
		self.display_item_list[i] = ItemCell.New()
		self.display_item_list[i]:SetInstanceParent(self:FindObj("ItemDisplay" .. i))

		self["card_item" .. i] = self:FindObj("card_item" .. i)

		self["price_" .. i] = self:FindVariable("price" .. i)
		self["is_show" .. i] = self:FindVariable("is_show" .. i)
		self["item_name" .. i] = self:FindVariable("item_name" .. i)
		self:ListenEvent("choose_item"..i, BindTool.Bind2(self.SendRollCard,self,i))
	end

	self.text_once = self:FindVariable("text_once")
	self.text_ten = self:FindVariable("text_ten")
	self.text_many = self:FindVariable("text_many")
	self.text_times = self:FindVariable("text_times")
	self.text_left_time = self:FindVariable('text_left_time')
	self.key_num_label = self:FindVariable("key_num")
	self.is_have_key = self:FindVariable("is_have_key")
	self.show_key_str = self:FindVariable("show_key_str")
	self.key_str = self:FindVariable("key_str")

	self.key_redpoint = self:FindObj("KeyRedPoint")
	self.tab_redpoint = self:FindObj("TabRedPoint")

	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")
	self.list_view_delegate = self.scroller.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	-- 三个等级 0， 1， 2
	self.cur_level = 0
	self.is_rotation = false
	self.req_type = RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_REFRESH_CARD
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

end

function FanFanZhuanView:ReleaseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	for i=0,8 do
		self["price_" .. i] = nil
		self["is_show" .. i] = nil
		self["card_item" .. i] = nil
		self["item_name" .. i] = nil
		if nil ~= self.item_list[i] then
			self.item_list[i]:DeleteMe()
		end
		if self.display_item_list[i] then
			self.display_item_list[i]:DeleteMe()
		end
	end

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.key_num_label = nil
	self.is_have_key = nil
	self.refresh_gold = nil
	self.remain_time = nil
	self.list_view = nil
	self.buy_all_desc = nil
	self.item_list = {}
	self.display_item_list = {}
	self.item_buffer = {}
	self.card_status = {}
	self.level_item_list = {}
	self.is_show_select_list = {}
	self.page_point_list = {}
	
	self.text_once = nil
	self.text_ten = nil
	self.text_many = nil
	self.scroller = nil
	self.list_view_delegate = nil
	self.text_times = nil
	self.text_left_time = nil
	self.show_key_str = nil
	self.key_str = nil
	self.key_redpoint = nil
	self.tab_redpoint = nil

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

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	FanFanZhuanData.Instance:ClearReturnRewardList()
end

function FanFanZhuanView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end

	BaseView.Open(self)
end

function FanFanZhuanView:OpenCallBack()
	-- MainUICtrl.Instance:CloseActivityHallView()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_QUERY_INFO)
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self.is_auto_buy = false
	self:Flush()
	self:FlsuhCardShow()
end

function FanFanZhuanView:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD and status == ACTIVITY_STATUS.CLOSE then
		self:Close()
	end 
end

function FanFanZhuanView:SendRollCard(index)
	local reward_index = FanFanZhuanData.Instance:GetinfoByLevelAndIndex(self.cur_level, index)
	if reward_index >= 0 then
		return
	end

		-- 翻牌费用显示
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local gold = 0
	if self.cur_level == 0 then
		gold = randact_cfg.other[1].king_draw_chuji_once_gold
	elseif self.cur_level == 1 then
		gold = randact_cfg.other[1].king_draw_zhongji_once_gold
	elseif self.cur_level == 2 then
		gold = randact_cfg.other[1].king_draw_gaoji_once_gold
	end

	if PlayerData.Instance:GetRoleVo().gold < gold then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	local func = function(is_auto)
		self.auto_buy_flag_list["auto_type_1"] = is_auto
		self.is_rotation = true
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD, 
													RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_ONCE, self.cur_level, index)

		self["card_item" .. index].rect:SetLocalScale(1, 1, 1)
		local target_scale = Vector3(0, 1, 1)
		local target_scale2 = Vector3(1, 1, 1)
		self.tweener1 = self["card_item" .. index].rect:DOScale(target_scale, 0.5)

		local func2 = function()
			self["is_show" .. index]:SetValue(false)
			self.tweener2 = self["card_item" .. index].rect:DOScale(target_scale2, 0.5)
			self.is_rotation = false
		end
		self.tweener1:OnComplete(func2)
		-- self.delay_timer2 = GlobalTimerQuest:AddDelayTimer(func2, 0.5)
	end

	if self.auto_buy_flag_list["auto_type_1"] then
		func(true)
	else
		local str = string.format(Language.Fanfanzhuan.CostTip, gold, CommonDataManager.GetDaXie(1))
		TipsCtrl.Instance:ShowCommonAutoView("fanfanzhuan_auto1", str, func)
	end
end

--滚动条数量
function FanFanZhuanView:GetNumberOfCells()
	return 2
end

--滚动条刷新
function FanFanZhuanView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = FanFanZhuanGridItem.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	group_cell:SetPageIndex(data_index)
	group_cell:SetCurLevel(self.cur_level)
	group_cell:Flush()
	-- for i = 1, MAX_PAGE do
	-- 	local index = data_index * PAGE_CELL_NUM + i
	-- 	local data = self.act_info[index]
	-- 	if data then
	-- 		group_cell:SetActive(i, true)
	-- 		group_cell:SetIndex(i, index)
	-- 		group_cell:SetToggleGroup(i, self.scroller.toggle_group)
	-- 		group_cell:SetParent(i, self)
	-- 		group_cell:SetData(i, data)
	-- 	else
	-- 		group_cell:SetActive(i, false)
	-- 	end
	-- end
end

function FanFanZhuanView:ResetItemGrid(i)
	-- for i=1,9 do
		self["is_show" .. i]:SetValue(false)
	-- end
	-- self.refresh_tags = false
end

function FanFanZhuanView:CloseCallBack()
	self.is_auto_buy = false
	self.is_rotation = false

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function FanFanZhuanView:OpenTreasureLoftTips()
	TipsCtrl.Instance:ShowHelpTipView(207)
end

function FanFanZhuanView:OnClickWarehouse()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
end

function FanFanZhuanView:OnclickReset()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD, 
											RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_REFRESH_CARD, self.cur_level)

		self.req_type = RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_REFRESH_CARD
end

function FanFanZhuanView:RefreshAllItems(req_type)
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local gold = 0
	if self.cur_level == 0 then
		gold = randact_cfg.other[1].king_draw_chuji_once_gold
	elseif self.cur_level == 1 then
		gold = randact_cfg.other[1].king_draw_zhongji_once_gold
	elseif self.cur_level == 2 then
		gold = randact_cfg.other[1].king_draw_gaoji_once_gold
	end
	local func = function(is_auto)
		self.auto_buy_flag_list["auto_type_" .. req_type] = is_auto
		-- self.is_auto_buy = is_auto
		self:OnOperate(req_type)
	end

	if self.cur_level == 0 and self.is_have_key:GetBoolean() then
		self:OnOperate(req_type)
		return
	end
	local item_num = ItemData.Instance:GetItemNumInBagById(randact_cfg.other[1].king_draw_gaoji_consume_item)
	local is_auto_use_item = self.cur_level == 2 and req_type == 50 and item_num > 0

	if not is_auto_use_item and PlayerData.Instance:GetRoleVo().gold < gold * req_type then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	if self.auto_buy_flag_list["auto_type_" .. req_type] or is_auto_use_item then
		self:OnOperate(req_type)
	else
		local str = string.format(Language.Fanfanzhuan.CostTip, gold * req_type, CommonDataManager.GetDaXie(req_type))
		TipsCtrl.Instance:ShowCommonAutoView("fanfanzhuan_auto" .. req_type, str, func)
	end
end

function FanFanZhuanView:OnOperate(req_type)
	if req_type == 10 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_10)
	else
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50)
	end
	
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD, 
									RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES, self.cur_level, req_type)
end

function FanFanZhuanView:OnFlush()
	for i = 0, GameEnum.RA_KING_DRAW_MAX_SHOWED_COUNT - 1 do
		local seq = FanFanZhuanData.Instance:GetinfoByLevelAndIndex(self.cur_level, i)
		if seq >= 0 then
			local reward_cfg = FanFanZhuanData.Instance:GetRewardByLevelAndIndex(self.cur_level, seq)
			if nil ~= next(reward_cfg) then
				local item_cfg = ItemData.Instance:GetItemConfig(reward_cfg.reward_item.item_id)
				local item_name = item_cfg and item_cfg.name or ""
				local item_color = item_cfg and item_cfg.color or 0
				self.display_item_list[i]:SetData(reward_cfg.reward_item)
				self["item_name" .. i]:SetValue(ToColorStr(item_name, ITEM_COLOR[item_color]))
			end
		end 
	end

	local show_reward_list = FanFanZhuanData.Instance:GetShowRewardCfgByOpenDay()
	for i=1,6 do
		if nil ~= show_reward_list[i] then
			self.item_list[i]:SetData(show_reward_list[i])
			self.item_list[i]:ShowGetEffect(true)
		end
	end

	for k,v in pairs(self.is_show_select_list) do
		if k == self.cur_level then
			v:SetValue(true)
		else
			v:SetValue(false)
		end
	end

	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	-- 翻牌费用显示
	local gold = 0
	if self.cur_level == 0 then
		gold = randact_cfg.other[1].king_draw_chuji_once_gold
	elseif self.cur_level == 1 then
		gold = randact_cfg.other[1].king_draw_zhongji_once_gold
	elseif self.cur_level == 2 then
		gold = randact_cfg.other[1].king_draw_gaoji_once_gold
	end

	self.text_once:SetValue(gold)
	self.text_ten:SetValue(gold * 10)
	self.text_many:SetValue(gold * 50)
	self:SetItemKeyNum()
	--钥匙显示
	local item_num = ItemData.Instance:GetItemNumInBagById(randact_cfg.other[1].king_draw_gaoji_consume_item)
	self.show_key_str:SetValue(self.cur_level == 2 and item_num > 0)

	local item_cfg = ItemData.Instance:GetItemConfig(randact_cfg.other[1].king_draw_gaoji_consume_item)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>X" .. item_num
	self.key_str:SetValue(self.cur_level == 2 and name_str or "")

	self.key_redpoint:SetActive(self.cur_level == 2 and item_num > 0)
	self.tab_redpoint:SetActive(item_num > 0)

	if self.req_type == RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_REFRESH_CARD then
		self:FlsuhCardShow()
		self.req_type = RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_QUERY_INFO
	end
	local times = FanFanZhuanData.Instance:GetDrawTimesByLevel(self.cur_level)
	self.text_times:SetValue(times)

	-- 活动剩余时间
	local nexttime = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD)
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if nexttime ~= nil then
		local time_t = TimeUtil.Format2TableDHM(nexttime)
		if time_t.day > 0 then
			local time_str = ""
			if time_t.day > 0 then
				time_str = time_str .. time_t.day .. Language.Common.TimeList.d
			end
			if time_t.hour > 0 or "" ~= time_str then
				time_str = time_str .. time_t.hour .. Language.Common.TimeList.h
			end
			if time_t.min > 0 or "" ~= time_str then
				time_str = time_str .. time_t.min .. Language.Common.TimeList.min
			end

			self.text_left_time:SetValue(time_str)
		else
			 self:UpdataRollerTime(0, nexttime)
			 self.count_down = CountDown.Instance:AddCountDown(nexttime,1,BindTool.Bind1(self.UpdataRollerTime, self))	
		end
	end

	FanFanZhuanData.Instance:SetCurLevel(self.cur_level)

	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)

	for i,v in pairs(self.page_point_list) do
		local is_show = false
		for y=0,1 do
			if FanFanZhuanData.Instance:GetFanFanZhuanRemOne(y, i) then
				is_show = true
			end
		end
		v:SetValue(is_show)
	end
end

-- 物品不足，购买成功后刷新物品数量
function FanFanZhuanView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id ~= 26622 then return end
	self:SetItemKeyNum()
end

function FanFanZhuanView:SetItemKeyNum()
	local key_item_num = ItemData.Instance:GetItemNumInBagById(26622)
	self.is_have_key:SetValue(false)
	if key_item_num > 0 and self.cur_level == 0 then
		self.key_num_label:SetValue(key_item_num)
		self.is_have_key:SetValue(true)
	end
end

function FanFanZhuanView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - elapse_time
	if self.text_left_time ~= nil then
		if time > 0 then
			self.text_left_time:SetValue(TimeUtil.FormatSecond2HMS(time))
		else
			self.text_left_time:SetValue("00:00:00")
		end
	end
end

function FanFanZhuanView:FlsuhCardShow()
	for i = 0, GameEnum.RA_KING_DRAW_MAX_SHOWED_COUNT - 1 do
		local reward_index = FanFanZhuanData.Instance:GetinfoByLevelAndIndex(self.cur_level, i)
		if reward_index >= 0 then
			self["is_show" .. i]:SetValue(false)
		else
			self["is_show" .. i]:SetValue(true)
		end 
	end
end

function FanFanZhuanView:OnClickLevel(level)
	if self.cur_level == level then
		return
	end

	if self.is_rotation then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fanfanzhuan.IsRotation)
		return
	end

	self.cur_level = level
	self:Flush()
	self:FlsuhCardShow()
end

------------------------------------------------------------------------
FanFanZhuanGridItem = FanFanZhuanGridItem  or BaseClass(BaseRender)

function FanFanZhuanGridItem:__init()
	self.page_index = 0
	self.cur_level = 0
	-- 累计翻牌达到的档次
	self.cur_grade = 0

	self.item_list = {}
	for i=0,2 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
		self.item_list[i]:ListenClick(BindTool.Bind(self.ItemClick, self, i))
	end

	self.text_desc_list = {}
	for i=0,2 do
		self.text_desc_list[i] = self:FindVariable("text_desc_" .. i)
	end

	self.is_show_effect_list = {}
	for i=0,2 do
		self.is_show_effect_list[i] = self:FindVariable("is_show_effect" .. i)
	end

	self.show_effect_flag_list = {}

	-- self.prog_value = self:FindVariable("prog_value")
end

function FanFanZhuanGridItem:__delete()
	self.page_index = 0

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end

	self.item_list = {}
	self.text_desc_list = {}
	self.is_show_effect_list = {}
	-- self.prog_value = nil
end

function FanFanZhuanGridItem:ItemClick(i)
	if self.cur_grade >= i + 1 then
		local index = (self.page_index * MAX_PROG_GRADE) + (i + 1)
		local return_reward_list = FanFanZhuanData.Instance:GetReturnRewardByLevel(self.cur_level)
		local data = return_reward_list[index] or {}
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD, 
													RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_FETCH_REWARD, self.cur_level, data.seq)
	else
		self.item_list[i]:OnClickItemCell()
	end
end

function FanFanZhuanGridItem:SetPageIndex(page_index)
	self.page_index = page_index
end

function FanFanZhuanGridItem:SetCurLevel(level)
	self.cur_level = level
end

function FanFanZhuanGridItem:OnFlush()
	local return_reward_list = FanFanZhuanData.Instance:GetReturnRewardByLevel(self.cur_level)
	local draw_times = FanFanZhuanData.Instance:GetDrawTimesByLevel(self.cur_level)
	self.cur_grade = 0
	for i=0,2 do
		local index = (self.page_index * MAX_PROG_GRADE) + (i + 1)
		local data = return_reward_list[index] or {}
		local cell = self.item_list[i]
		cell:SetData(data.reward_item or {})
		self.text_desc_list[i]:SetValue(data.draw_times)

		-- 获取当前达到第几个档次
		local is_show_effect = false
		local is_show_has_get = false
		if draw_times >= data.draw_times then
			local reward_flag = FanFanZhuanData.Instance:GetIsGetReward(self.cur_level, index)
			if reward_flag == 1 then
				is_show_has_get = true
			else
				is_show_effect = true
			end
			self.cur_grade = self.cur_grade + 1
			
		end
		cell:ShowHaseGet(is_show_has_get)
		-- if self.show_effect_flag_list[i] == nil or self.show_effect_flag_list[i] ~= is_show_effect then
		-- 	self.show_effect_flag_list[i] = is_show_effect
		-- 	self.is_show_effect_list[i]:SetValue(is_show_effect)
		-- end

		self.is_show_effect_list[i]:SetValue(is_show_effect)
		if is_show_effect then
			self.item_list[i]:ListenClick(BindTool.Bind(self.ItemClick, self, i))
		else
			self.item_list[i]:ListenClick()
		end
		-- cell:ShowGetEffect(is_show_effect)
		cell:SetHighLight(false)
	end

	-- local prog_value = self.cur_grade / MAX_PROG_GRADE
	-- self.prog_value:SetValue(prog_value)
end

function FanFanZhuanView:OnClickTurnPage(dir)
	local page = self.scroller.list_page_scroll:GetNowPage()
	if dir == "left" then
		page = page - 1
		if page < 0 then
			return
		end
	else
		page = page + 1
	end
	self.scroller.list_page_scroll:JumpToPage(page)
end