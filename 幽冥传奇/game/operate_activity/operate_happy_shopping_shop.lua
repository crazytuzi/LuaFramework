--嗨购一车
OperActHappyShoppingPage = OperActHappyShoppingPage or BaseClass()

function OperActHappyShoppingPage:__init()
	self.view = nil

end

function OperActHappyShoppingPage:__delete()
	self:RemoveEvent()
	if self.grid_scroll then
		self.grid_scroll:DeleteMe()
		self.grid_scroll = nil
	end

	self.view = nil
end


function OperActHappyShoppingPage:InitPage(view)
	self.view = view
	self.cart_num_txt = self.view.node_t_list.txt_cart_item_num.node
	self.remind_flag = self.view.node_t_list.img_cart_remind.node
	self.rich_cart_cost_info = self.view.node_t_list.rich_cart_cost_info.node
	-- self.rich_cart_cost_info:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
	XUI.RichTextSetCenter(self.rich_cart_cost_info)
	self.cart_num_txt:setVisible(false)
	self.remind_flag:setVisible(false)
	self:CreateItemsShowPanel()
	self:InitEvent()
	self:OnDataChange()
end

--初始化事件
function OperActHappyShoppingPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_my_shop_cart.node, BindTool.Bind(self.OnGoMyCart, self))
	self.data_evt = GlobalEventSystem:Bind(OperateActivityEventType.HAPPY_SHOP_CART_DATA, BindTool.Bind(self.OnDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

--移除事件
function OperActHappyShoppingPage:RemoveEvent()
	if self.data_evt then
		GlobalEventSystem:UnBind(self.data_evt)
		self.data_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

-- 刷新
function OperActHappyShoppingPage:UpdateData(param_t, index)
	local des = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART).act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_happy_shopping_des.node, des, 24, COLOR3B.YELLOW)
	self:FlushInfo()
end

function OperActHappyShoppingPage:CreateItemsShowPanel()
	if self.grid_scroll then return end
	local ph = self.view.ph_list.ph_happy_shop_cart_list
	local item_ui_cfg = self.view.ph_list.ph_happy_shop_item
	self.grid_scroll = GridScroll.New()
	-- ClientCommonButtonDic[CommonButtonType.SHOP_GRID] = grid_scroll
	self.grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 3, item_ui_cfg.h + 10, HappyShoppingItemRender, ScrollDir.Vertical, false, item_ui_cfg)
	-- self.grid_scroll:SetSelectCallBack(BindTool.Bind(self.SelectItemCallBack, self))
	self.view.node_t_list.layout_happy_shopping.node:addChild(self.grid_scroll:GetView(), 100)

	local data = OperateActivityData.Instance:GetHappyShopCartShopItemList()
	self.grid_scroll:SetDataList(data)
	self.grid_scroll:JumpToTop()	
end

function OperActHappyShoppingPage:FlushInfo()
	local cnt = OperateActivityData.Instance:GetHappyShopCartHasCnt()
	self.cart_num_txt:setString(cnt)
	self.cart_num_txt:setVisible(cnt > 0)
	self.remind_flag:setVisible(cnt > 0)
	local total_price, dis_price, dis_cnt = OperateActivityData.Instance:GetHappyShopCartCostMoneyInfo()
	local content = ""
	if total_price > 0 then
		content = string.format(Language.OperateActivity.HappyShoppingCart[4], total_price, dis_price == 0 and total_price or dis_price)
	end
	RichTextUtil.ParseRichText(self.rich_cart_cost_info, content, 18, COLOR3B.YELLOW)
	for k, v in pairs(self.grid_scroll:GetItems()) do
		if v.SetRemindVis then
			v:SetRemindVis()
		end
	end
end

-- 倒计时
function OperActHappyShoppingPage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.txt_happy_shopping_rest_time then
		self.view.node_t_list.txt_happy_shopping_rest_time.node:setString(Language.Common.RemainTime .. ":".. time_str)
	end
end

function OperActHappyShoppingPage:OnDataChange()
	self:FlushTime()
	self:FlushInfo()	
end

function OperActHappyShoppingPage:OnGoMyCart()
	ViewManager.Instance:Open(ViewName.HappyShopCart)
	ViewManager.Instance:FlushView(ViewName.HappyShopCart,0)
end