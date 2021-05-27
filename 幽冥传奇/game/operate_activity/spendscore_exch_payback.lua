--消费积分兑换返利券
OpActSpendscoreExchPaybackPage = OpActSpendscoreExchPaybackPage or BaseClass()

function OpActSpendscoreExchPaybackPage:__init()
	self.view = nil

end

function OpActSpendscoreExchPaybackPage:__delete()
	self:RemoveEvent()
	if self.grid_scroll then
		self.grid_scroll:DeleteMe()
		self.grid_scroll = nil
	end

	self.view = nil
end


function OpActSpendscoreExchPaybackPage:InitPage(view)
	self.view = view
	-- self.view.node_t_list.rich_spend_score_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self:CreateItemsShowPanel()
	self:InitEvent()
	self:OnSpendScoreDataChange()
	XUI.AddClickEventListener(self.view.node_t_list.btn_spendsocre_exch_check.node, BindTool.Bind(self.OnCheck, self), true)
end

--初始化事件
function OpActSpendscoreExchPaybackPage:InitEvent()
	self.spend_score_evt = GlobalEventSystem:Bind(OperateActivityEventType.SPENDSCORE_EXCH_PAYBACK_DATA, BindTool.Bind(self.OnSpendScoreDataChange, self))
	-- self.shop_item_update_evt = GlobalEventSystem:Bind(OperateActivityEventType.SPEND_SCORE_UPDATE_ITEM, BindTool.Bind(self.OnShopItemUpdate,self))
	-- self.shop_item_delete_evt = GlobalEventSystem:Bind(OperateActivityEventType.SPEND_SCORE_DEL_ITEM, BindTool.Bind(self.OnShopItemDelete,self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

--移除事件
function OpActSpendscoreExchPaybackPage:RemoveEvent()
	if self.spend_score_evt then
		GlobalEventSystem:UnBind(self.spend_score_evt)
		self.spend_score_evt = nil
	end

	if self.shop_item_update_evt then
		GlobalEventSystem:UnBind(self.shop_item_update_evt)
		self.shop_item_update_evt = nil
	end

	if self.shop_item_delete_evt then
		GlobalEventSystem:UnBind(self.shop_item_delete_evt)
		self.shop_item_delete_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

end

-- 刷新
function OpActSpendscoreExchPaybackPage:UpdateData(param_t, index)
	local des = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK).act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_spendscore_exch_des.node, des, 20, COLOR3B.YELLOW)
end

function OpActSpendscoreExchPaybackPage:OnShopItemUpdate(shop_item)
	if not self.grid_scroll then return end
	self:FlushInfo()
	for i,cell in ipairs(self.grid_scroll:GetItems()) do
		local data = cell:GetData()
		if data and data.idx == shop_item.idx then
			cell:SetData(shop_item)
			break
		end
	end
end	

function OpActSpendscoreExchPaybackPage:OnShopItemDelete()
	if not self.grid_scroll then return end
	self:FlushInfo()
	local data = OperateActivityData.Instance:GetSpendscoreExchangeItemData()
	self.grid_scroll:SetDataList(data)
end	

function OpActSpendscoreExchPaybackPage:CreateItemsShowPanel()
	if self.grid_scroll then return end

	local ph = self.view.ph_list.ph_spendscore_exch_list
	local item_ui_cfg = self.view.ph_list.ph_spendscore_exch_item
	self.grid_scroll = GridScroll.New()
	self.grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 2, item_ui_cfg.h + 5, SpendScoreExchaPaybackItemRender, ScrollDir.Vertical, false, item_ui_cfg)
	-- self.grid_scroll:SetSelectCallBack(BindTool.Bind(self.SelectItemCallBack, self))
	self.view.node_t_list.layout_spendscore_exchange.node:addChild(self.grid_scroll:GetView(), 100)

	local data = OperateActivityData.Instance:GetSpendscoreExchangeItemData()
	self.grid_scroll:SetDataList(data)
	self.grid_scroll:JumpToTop()	
end

function OpActSpendscoreExchPaybackPage:SelectItemCallBack(item)
	if item == nil or item:GetData() == nil then return end
	local data = item:GetData()
	local act_id = OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	local award_index = data.awardId
	OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, award_index, oper_type)
	-- if self.buy_alert == nil then
	-- 	self.buy_alert = Alert.New()
	-- end
	-- self.buy_alert:SetShowCheckBox(true)
	-- local price_name = ShopData.GetMoneyTypeName(data.price[1].type)
	-- local item_config = ItemData.Instance:GetItemConfig(data.item)
	-- if nil == item_config then return end
	-- local item_color = string.format("%06x", item_config.color)
	-- local str = string.format(Language.Shop.BuyTips, data.price[1].price, price_name, item_color, item_config.name, 1)
	-- self.buy_alert:SetLableString(str)
	-- self.buy_alert:SetOkFunc(function ()
	-- 	local buy_id = data.id
	-- 	local buy_count = 1
	-- 	local item_id = data.item
	-- 	local auto_use = data.autouse and data.autouse or 0
	-- 	ShopCtrl.BuyItemFromStore(buy_id, buy_count, item_id, auto_use)
	-- 	end)
	-- self.buy_alert:Open()
end

function OpActSpendscoreExchPaybackPage:FlushInfo()
	local own_score_val = OperateActivityData.Instance:GetOwnExchangeSpendscoreNum()
	local content = string.format(Language.OperateActivity.SpendScoreTexts[1], own_score_val)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_spendscore_exch_num.node, content, 20)
	local data = OperateActivityData.Instance:GetSpendscoreExchangeItemData()
	self.grid_scroll:SetDataList(data)
end

-- 倒计时
function OpActSpendscoreExchPaybackPage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.spendscore_exch_rest_time then
		self.view.node_t_list.spendscore_exch_rest_time.node:setString(time_str)
	end
end

function OpActSpendscoreExchPaybackPage:OnSpendScoreDataChange()
	self:FlushTime()
	self:FlushInfo()
end

function OpActSpendscoreExchPaybackPage:OnCheck()
	ViewManager.Instance:Open(ViewName.SpendscoreExchCheck)
	ViewManager.Instance:FlushView(ViewName.SpendscoreExchCheck, 0, nil, {data = OperateActivityData.Instance:GetSpendscoreExchangeAwardsInfo()})
end

