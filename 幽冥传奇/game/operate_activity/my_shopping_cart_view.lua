------------------------------------------------------------
-- 运营活动我的购物车View
------------------------------------------------------------
MyShoppingCartView = MyShoppingCartView or BaseClass(XuiBaseView)

function MyShoppingCartView:__init()
	self.is_any_click_close = true
	self.is_async_load = false
	self.texture_path_list = {
								'res/xui/limit_activity.png',
								'res/xui/boss.png',
								'res/xui/charge.png',
								'res/xui/combineserveractivity.png',
								'res/xui/operate_activity.png',
								'res/xui/vip.png',
								"res/xui/shangcheng.png",
								"res/xui/skill.png",
								"res/xui/welfare.png",
								 "res/xui/openserviceacitivity.png",
								}
	
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序	
		{"operate_activity_ui_cfg", 50, {0}},
	}

end

function MyShoppingCartView:__delete()

end

function MyShoppingCartView:ReleaseCallBack()
	-- 清理页面生成信息
	if self.data_evt then
		GlobalEventSystem:UnBind(self.data_evt)
		self.data_evt = nil
	end
	if self.cart_list then
		self.cart_list:DeleteMe()
		self.cart_list = nil
	end
end

function MyShoppingCartView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCartList()
		XUI.RichTextSetVCenter(self.node_t_list.rich_cart_total_cost.node)
		XUI.RichTextSetVCenter(self.node_t_list.rich_cart_discount_cost.node)
		self.data_evt = GlobalEventSystem:Bind(OperateActivityEventType.HAPPY_SHOP_CART_DATA, BindTool.Bind(self.SetCartListData, self))
		XUI.AddClickEventListener(self.node_t_list.btn_my_shop_cart_settle.node, BindTool.Bind(self.OnSettleCart, self))
	end
end

function MyShoppingCartView:OpenCallBack()
end

function MyShoppingCartView:CloseCallBack()
	
end

function MyShoppingCartView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MyShoppingCartView:OnFlush(param_t, index)
	self:SetCartListData()
end

function MyShoppingCartView:CreateCartList()
	if nil == self.cart_list then
		local ph = self.ph_list.ph_my_shop_cart_list
		self.cart_list = ListView.New()
		self.cart_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateActMyShopCartRender, nil, nil, self.ph_list.ph_happy_shop_item)
		self.cart_list:SetItemsInterval(3)
		self.cart_list:SetJumpDirection(ListView.Top)
		self.cart_list:SetIsUseStepCalc(false)
		-- self.cart_list:SetSelectCallBack(BindTool.Bind(self.SelectItemCallback, self))
		self.node_t_list.layout_my_shop_cart.node:addChild(self.cart_list:GetView(), 20)
		self:SetCartListData()
	end
end

function MyShoppingCartView:SelectItemCallback(item, index)
	if not item or not item:GetData() then return end
	local data = item:GetData()
	self.selec_index = index
	self.selec_act_id = data.act_id
	self:ChangeToIndex(data.act_id)
	self:Flush(data.act_id)
end

function MyShoppingCartView:SetCartListData()
	local list_data = OperateActivityData.Instance:GetHappyShopCartListData()
	self.node_t_list.txt_cart_empty.node:setVisible(#list_data <= 0)
	local total_price, dis_price, dis_cnt = OperateActivityData.Instance:GetHappyShopCartCostMoneyInfo()
	RichTextUtil.ParseRichText(self.node_t_list.rich_cart_total_cost.node, string.format(Language.OperateActivity.HappyShoppingCart[1], total_price))
	RichTextUtil.ParseRichText(self.node_t_list.rich_cart_discount_cost.node, string.format(Language.OperateActivity.HappyShoppingCart[2], dis_price, dis_cnt))
	self.node_t_list.rich_cart_rest_cnt.node:setString(string.format(Language.OperateActivity.HappyShoppingCart[3], OperateActivityData.Instance:GetHappyShopCartRestCnt()))
	if not self.cart_list then return end
	self.cart_list:SetData(list_data)
end

function MyShoppingCartView:OnGetUiNode(node_name)
	local node, is_next = XuiBaseView.OnGetUiNode(self, node_name)
	if node then
		return XuiBaseView.OnGetUiNode(self, node_name)
	end
end

function MyShoppingCartView:OnSettleCart()
	local act_id = OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, 1, 3)
	end
end


