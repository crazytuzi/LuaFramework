MidAutumnLotteryView = MidAutumnLotteryView or BaseClass(BaseView)

function MidAutumnLotteryView:__init()
	self.ui_config = {"uis/views/midautumn","MidAutumnLotteryView"}
	self.play_audio = true
	self.full_screen = false
	self:SetMaskBg()

	self.one_draw_consume_num = 0
	self.ten_draw_consume_num = 0
	self.item_num = 0 
end

function MidAutumnLotteryView:__delete()

end

function MidAutumnLotteryView:ReleaseCallBack()
	self.total_num = nil
	self.one_draw_consume = nil
	self.ten_draw_consume = nil
	self.is_show_one_redpoint = nil
	self.is_show_ten_redpoint = nil
	self.is_show_no_record = nil
	self.left_time = nil
	self.is_show_mask = nil
	self.draw_times = nil
	self.list_view = nil
	self.icon_consume = nil

	for _,v in pairs(self.reward_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.reward_cell_list = {}

	for _,v in pairs(self.item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.item_list = {}

	if self.least_timer then
		CountDown.Instance:RemoveCountDown(self.least_timer)
		self.least_timer = nil
	end

	if self.item_data_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.ten_times_reward_cb = nil
end

function MidAutumnLotteryView:LoadCallBack()  
	self.total_num = self:FindVariable("total_num")
	self.one_draw_consume = self:FindVariable("one_draw_consume")
	self.ten_draw_consume = self:FindVariable("ten_draw_consume")
	self.is_show_one_redpoint = self:FindVariable("is_show_one_redpoint")
	self.is_show_ten_redpoint = self:FindVariable("is_show_ten_redpoint")
	self.is_show_no_record = self:FindVariable("is_show_no_record")
	self.left_time = self:FindVariable("left_time")
	-- self.particle_sys_obj = self:FindObj("ParticleSystem")
	self.is_show_mask = self:FindVariable("is_show_mask")
	self.draw_times = self:FindVariable("draw_times")
	self.icon_consume = self:FindVariable("icon_consume")

	self.reward_cell_list = {}
	self.list_view = self:FindObj("ListView")
	local preview_list_delegate = self.list_view.list_simple_delegate 
	preview_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells,self)
	preview_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell,self) 

	self:ListenEvent("OnOnceBtnClick",BindTool.Bind(self.OnOnceBtnClick,self))
	self:ListenEvent("OnTenTimesBtnClick",BindTool.Bind(self.OnTenTimesBtnClick,self))
	self:ListenEvent("OnTipsBtnClick",BindTool.Bind(self.OnTipsBtnClick,self))
	self:ListenEvent("OnCloseBtnClick",BindTool.Bind(self.Close,self))
	self:ListenEvent("OnRewardBtnClick", BindTool.Bind(self.OnRewardBtnClick, self))

	self:InitPreviewReward()
	self:InitCommonData()
	self:SetLeftTime()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemChangeCallBack,self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end 

function MidAutumnLotteryView:OpenCallBack()
	self.is_auto_buy = false
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY, 0)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY, 2)
	self:Flush()
end

function MidAutumnLotteryView:CloseCallBack() 
	self.ten_times_reward_cb = nil
	if self.least_timer then
		CountDown.Instance:RemoveCountDown(self.least_timer)
		self.least_timer = nil
	end
	TipsCommonAutoView.AUTO_VIEW_STR_T["midautumn_lottery"] = nil
end

function MidAutumnLotteryView:ItemChangeCallBack()
		local info_list = MidAutumnLotteryData.Instance:GetComsumeInfoList()
	if info_list == nil then
		return
	end
	local item_id = info_list.item_id
	self.item_num = ItemData.Instance:GetItemNumInBagById(item_id) 
	self.total_num:SetValue(self.item_num) 
	self.is_show_one_redpoint:SetValue(self.item_num >= self.one_draw_consume_num)
	self.is_show_ten_redpoint:SetValue(self.item_num >= self.ten_draw_consume_num)
end

function MidAutumnLotteryView:OnFlush()
	self.draw_times:SetValue(MidAutumnLotteryData.Instance:GetDrawTimes())
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:ItemChangeCallBack()
end

function MidAutumnLotteryView:InitPreviewReward()
	local cur_preview_show_cfg = MidAutumnLotteryData.Instance:GetCurDayPreviewItemShowList()
	self.item_list = {}
	for i = 1, 6 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("item" .. i))
		if nil ~= next(cur_preview_show_cfg) then
			item_cell:SetData(cur_preview_show_cfg[i].reward_item)
		end
		self.item_list[i] = item_cell
	end
	local draw_cfg = MidAutumnLotteryData.Instance:GetHappyDraw2OtherCfg()
	if nil ~= next(draw_cfg) and draw_cfg[1].one_draw_consume_item then
		local item_id = draw_cfg[1].one_draw_consume_item.item_id
		local bundle, asset = ResPath.GetItemIcon(item_id)
		self.icon_consume:SetAsset(bundle, asset)
	end
end

function MidAutumnLotteryView:InitCommonData()
	local info_list_1 = MidAutumnLotteryData.Instance:GetComsumeInfoList()
	local info_list_10 = MidAutumnLotteryData.Instance:GetComsumeInfoList(10)
	if info_list_1 == nil or info_list_10 == nil then
		return
	end

	self.one_draw_consume_num = info_list_1.num
	self.ten_draw_consume_num = info_list_10.num 
	self.one_draw_consume:SetValue(self.one_draw_consume_num or 1)
	self.ten_draw_consume:SetValue(self.ten_draw_consume_num or 10)

	self.is_show_one_redpoint:SetValue(false)
	self.is_show_ten_redpoint:SetValue(false)
	self.is_show_no_record:SetValue(true)
end

function MidAutumnLotteryView:SetLeftTime()
	local left_second = MidAutumnLotteryData.Instance:GetLeftTime()
	local time_tab = TimeUtil.Format2TableDHMS(left_second)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(left_second,1)
	else
		str = TimeUtil.FormatSecond(left_second)
	end
	if self.left_time then
		self.left_time:SetValue(str)
	end

	if self.least_timer == nil then
		self.least_timer = CountDown.Instance:AddCountDown(left_second,1,function()
			left_second = left_second - 1
			self:SetLeftTime(left_second)
		end)
	end 
end

function MidAutumnLotteryView:OnRewardBtnClick()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
end

function MidAutumnLotteryView:GetNumberOfCells()
	return MidAutumnLotteryData.Instance:GetBaoDiRewardCfgLength()
end

function MidAutumnLotteryView:RefreshCell(cell, data_index)
	data_index =  data_index + 1
	local reward_cell = self.reward_cell_list[cell]
	if reward_cell == nil then
		reward_cell = MidAutumnRewardItem.New(cell.gameObject)
		self.reward_cell_list[cell] = reward_cell
	end
	local reward_cfg = MidAutumnLotteryData.Instance:GetHappydraw2BaoDiSortRewardCfg() 
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(reward_cfg[data_index])
end

function MidAutumnLotteryView:OnOnceBtnClick() 
	MidAutumnLotteryData.Instance:SetAnimState(true)
	local item_id = MidAutumnLotteryData.Instance:GetComsumeInfoList().item_id
	if self.item_num >= self.one_draw_consume_num then
		MidAutumnLotteryData.Instance:SetIfUseIngot(0)
		MidAutumnLotteryData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_1)
		-- 活动类型：2199 -- 操作类型：1 （抽奖）-- 是否十抽：0/1 -- 是否使用元宝：0/1
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY,1,0,0)
	else
		local function ok_callback()
			MidAutumnLotteryData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_1)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY,1,0,1)
		end
		
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg == nil or not next(item_cfg) then
			return
		end
		local color = item_cfg.color
		local color_str = ITEM_COLOR[color]
		local name = item_cfg.name or "" 
		local need_gold = MidAutumnLotteryData.Instance:GetNeedGoldByDrawTimes()
		local des = string.format(Language.MidAutumn.NotEnoughOnce,color_str,name,need_gold)
		MidAutumnLotteryData.Instance:SetIfUseIngot(1)
		TipsCtrl.Instance:ShowCommonAutoView("midautumn_lottery", des, ok_callback)
	end
end

function MidAutumnLotteryView:OnTenTimesBtnClick()
	MidAutumnLotteryData.Instance:SetAnimState(true)
	local item_id = MidAutumnLotteryData.Instance:GetComsumeInfoList(10).item_id 
	
	if self.item_num >= self.ten_draw_consume_num then 
		MidAutumnLotteryData.Instance:SetIfUseIngot(0)
		MidAutumnLotteryData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_10)
		-- 活动类型：2199 -- 操作类型：1 （抽奖）-- 是否十抽：0/1 -- 是否使用元宝：0/1
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY, 1, 1, 0)
	else
		local function ok_callback()
			MidAutumnLotteryData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_10)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY, 1, 1, 1)
		end
		
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg == nil or not next(item_cfg) then
			return
		end
		local color = item_cfg.color
		local color_str = ITEM_COLOR[color]
		local name = item_cfg.name or "" 
		local need_gold = MidAutumnLotteryData.Instance:GetNeedGoldByDrawTimes(10)
		local des = string.format(Language.MidAutumn.NotEnoughTenTimes,color_str,name,need_gold) 
		MidAutumnLotteryData.Instance:SetIfUseIngot(1)
		TipsCtrl.Instance:ShowCommonAutoView("midautumn_lottery", des, ok_callback)
	end

end

function MidAutumnLotteryView:OnTipsBtnClick()
	local tips_id = 259  
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

---------------------------保底奖励-----------------------------------------------------------------
MidAutumnRewardItem = MidAutumnRewardItem or BaseClass(BaseCell)
function MidAutumnRewardItem:__init()
	self.draw_times = self:FindVariable("draw_times")
	self.is_received = self:FindVariable("is_received")

	self.item_cell_list = {} 
	for i = 1, 2 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("item_cell" .. i))
	end
end

function MidAutumnRewardItem:__delete()
	self.draw_times = nil
	self.is_received = nil

	for i = 1, 2 do
		if self.item_cell_list[i] then
			self.item_cell_list[i]:DeleteMe()
		end
	end
	self.item_cell_list = {}
end

function MidAutumnRewardItem:OnFlush()
	self.draw_times:SetValue(self.data.draw_times)
	self.is_received:SetValue(self.data.is_received == 1)
	local gift_item_list = ItemData.Instance:GetGiftItemList(self.data.reward.item_id)
	for i=1, #gift_item_list do
		self.item_cell_list[i]:SetData({item_id = gift_item_list[i].item_id,num = gift_item_list[i].num})
	end
end