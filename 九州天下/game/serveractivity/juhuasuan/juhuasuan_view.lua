JuHuaSuanView = JuHuaSuanView or BaseClass(BaseView)

function JuHuaSuanView:__init()
	self.ui_config = {"uis/views/serveractivity/juhuasuan", "JuHuaSuanView"}
	self.play_audio = true
	self.cell_list = {}
	self.end_time = 0
	self.data = {}
	self.reward_id = 0
	self:SetMaskBg(true)
end

function JuHuaSuanView:__delete()

end

function JuHuaSuanView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("ClickBuyAll",
		BindTool.Bind(self.ClickBuyAll, self))
	self.act_time = self:FindVariable("ActTime")
	self.gold_need = self:FindVariable("GoldNeed")
	self.btn_enble = self:FindVariable("BuyBtnEnble")
	self.num = self:FindVariable("Num")
	self:InitScroller()
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("Item"))

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function JuHuaSuanView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end

	-- 清理变量和对象
	self.scroller = nil
	self.act_time = nil
	self.gold_need = nil
	self.btn_enble = nil
	self.num = nil

	if self.money_bar ~= nil then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
end

function JuHuaSuanView:InitScroller()
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	self.data = JuHuaSuanData.Instance:GetJuHuaSuanData()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = JuHuaSuanCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function JuHuaSuanView:OpenCallBack()
	self:Flush()
end

function JuHuaSuanView:ShowIndexCallBack(index)

end

function JuHuaSuanView:ClickBuyAll()
	local item_cfg = ItemData.Instance:GetItemConfig(self.reward_id)
	local reward_name = ""
	if item_cfg then
		reward_name = item_cfg.name
	end
	TipsCtrl.Instance:ShowCommonAutoView("", string.format(Language.RandAct.BuyAllGiftTips, JuHuaSuanData.Instance:BuyAllNeed(), reward_name), BindTool.Bind(self.SendBuyAllGift, self))
end

function JuHuaSuanView:SendBuyAllGift()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS, XIANYUAN_TREAS_OPERA_TYPE.BUY_ALL)
end

function JuHuaSuanView:CloseCallBack()

end

function JuHuaSuanView:OnFlush(param_t)
	self.data = JuHuaSuanData.Instance:GetJuHuaSuanData()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	local buy_all_need = JuHuaSuanData.Instance:BuyAllNeed()
	self.gold_need:SetValue(buy_all_need)
	self.btn_enble:SetValue(buy_all_need > 0)
	if self.data and self.data[1] then
		self.num:SetValue(self.data[1].max_reward_day)
	end
	local act_other_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	self.reward_id = act_other_cfg.xianyuan_treas_all_buy_reward.item_id
	self.reward_item:SetData(act_other_cfg.xianyuan_treas_all_buy_reward)
end

function JuHuaSuanView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	else
		self.act_time:SetValue("<color='#FFFFFFFF'>" .. TimeUtil.FormatSecond2Str(time, 0) .. "</color>")
	end
end

---------------------------------------------------------------
--滚动条格子

JuHuaSuanCell = JuHuaSuanCell or BaseClass(BaseCell)

function JuHuaSuanCell:__init()
	self.recharge_txt = self:FindVariable("RechargeTxt")
	self.gold_need = self:FindVariable("GoldNeed")
	self.btn_enble = self:FindVariable("BtnEnble")
	self.btn_txt = self:FindVariable("BtnTxt")
	self.show_red = self:FindVariable("ShowRed")
	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("ItemList"))
	end
	self:ListenEvent("ClickBuy",
		BindTool.Bind(self.ClickBuy, self))
end

function JuHuaSuanCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function JuHuaSuanCell:OnFlush()
	if nil == self.data then return end
	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id) --30066
	--local item_list = ItemData.Instance:GetGiftItemList(30066)
	for k,v in pairs(self.reward_list) do
		if item_list[k] then
			v:SetData(item_list[k])
		end
		v.root_node:SetActive(item_list[k] ~= nil)
	end
	self.recharge_txt:SetValue(self.data.theme_name)
	self.gold_need:SetValue(self.data.consume_gold)
	local has_buy = JuHuaSuanData.Instance:HasBuyGift(self.data.seq)
	local can_receive = JuHuaSuanData.Instance:GetCanReceiveGift(self.data.seq)
	if not has_buy or can_receive then
		self.btn_txt:SetValue(has_buy and Language.Common.BuyOrGet[2] or Language.Common.BuyOrGet[1])
	else
		self.btn_txt:SetValue(string.format(Language.RandAct.BtnTxt, JuHuaSuanData.Instance:GetReceiceGiftNum(self.data.seq)))
	end
	self.btn_enble:SetValue(not has_buy or can_receive)
	self.show_red:SetValue(has_buy and can_receive)
end

function JuHuaSuanCell:ClickBuy()
	if self.data == nil then return end
	if JuHuaSuanData.Instance:HasBuyGift(self.data.seq) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS, XIANYUAN_TREAS_OPERA_TYPE.FETCH_REWARD, self.data.seq)
	else
		TipsCtrl.Instance:ShowCommonAutoView("", string.format(Language.RandAct.BuyGiftTips, self.data.consume_gold), BindTool.Bind(self.SendBuyGift, self))
	end
end

function JuHuaSuanCell:SendBuyGift()
	if self.data == nil then return end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS, XIANYUAN_TREAS_OPERA_TYPE.BUY, self.data.seq)
end