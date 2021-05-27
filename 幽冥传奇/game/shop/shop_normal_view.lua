------------------------------------------------------------
-- 商店标准视图
------------------------------------------------------------

local ShopNormalView = BaseClass(SubView)

function ShopNormalView:__init()
	self.texture_path_list = {
		'res/xui/shangcheng.png',
	}
	self.config_tab = {
		{"shop_ui_cfg", 3, {0}},
	}
end

function ShopNormalView:__delete()
end

function ShopNormalView:ReleaseCallBack()
	if self.grid_scroll then
		self.grid_scroll:DeleteMe()
		self.grid_scroll = nil
	end
end

function ShopNormalView:LoadCallBack(index, loaded_times)
	
	self:CreatScollGird()

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))

	-- 前往回收获取积分
	local ph_txt = self.ph_list.ph_jfhs_txt
	self.txt_share_pre = RichTextUtil.CreateLinkText("前往回收获取积分", 18, COLOR3B.GREEN)
	self.txt_share_pre:setPosition(ph_txt.x, ph_txt.y)
	XUI.AddClickEventListener(self.txt_share_pre, BindTool.Bind(self.OnOpenRecycleJf, self, 1), true)
	self.node_t_list.layout_jssc.node:addChild(self.txt_share_pre, 100)

end

function ShopNormalView:OnOpenRecycleJf()
	ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
end

function ShopNormalView:CreatScollGird()
	if nil == self.grid_scroll then
		local ph = self.ph_list.ph_items_list
		self.grid_scroll = GridScroll.New()
		self.grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 2, 110, ShopNormalView.ShopItemRender, ScrollDir.Vertical, false, self.ph_list.ph_item_info_panel)
		self.node_t_list.layout_other_shop.node:addChild(self.grid_scroll:GetView(), 100)
		self.grid_scroll:SetSelectCallBack(BindTool.Bind(self.SelectItemBack, self))
		self.grid_scroll:JumpToTop()
	end
end

function ShopNormalView:ShowIndexCallBack(index)

	self:FlushMoney()
	self:Flush()
end

function ShopNormalView:OnFlush(param_t)
	local data_list
	local num_vis = true
	if self:GetViewDef() == ViewDef.Shop.Prop then
		data_list = ShopData.GetShopCfg(3)
		num_vis = true
	elseif self:GetViewDef() == ViewDef.Shop.Bind_yuan then
		data_list = ShopData.GetShopCfg(4)
		num_vis = true
	elseif self:GetViewDef() == ViewDef.Shop.Yongzhe then
		data_list = ShopData.GetShopCfg(7)
		num_vis = false
	end

	local open_server_day = OtherData.Instance:GetOpenServerDays()
	local list = {}
	for i,v in ipairs(data_list) do
		if v.opensvrday > 0 then
			if open_server_day >= v.opensvrday then
				table.insert(list, v)
			end
		else
			table.insert(list, v)
		end
	end

	self.node_t_list.layout_zssc.node:setVisible(num_vis)
	self.node_t_list.layout_jssc.node:setVisible(not num_vis)	
	self.grid_scroll:SetDataList(list)
	self.grid_scroll:JumpToTop()
end

function ShopNormalView:OnRoleAttrChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_GOLD or vo.key == OBJ_ATTR.ACTOR_COIN or OBJ_ATTR.ACTOR_BRAVE_POINT  then
		self:FlushMoney()
	end
end

--更新金钱显示
function ShopNormalView:FlushMoney()
	local gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
	local bind_gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN))
	local jifen = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BRAVE_POINT))
	
	--更新元宝和绑定元宝显示
	self.node_t_list.lbl_yuanbao_num.node:setString(gold)
	self.node_t_list.lbl_bind_yuanbao_num.node:setString(bind_gold)  
	self.node_t_list.lbl_yzjf_num.node:setString(jifen)
end

--其它商店选择回调
function ShopNormalView:SelectItemBack(item)
	if item == nil or item:GetData() == nil then return end
	local data = item:GetData()
	ViewManager.Instance:FlushViewByDef(ViewDef.Shop, 0, "shop_buy", {data = data.item, type = data.price[1].type, id = data.id})
end

-- --其它商店购买确认提示
-- function ShopNormalView:ShowBuyConfirmAlert(buy_id, item_count, item_id, price, price_type, auto_use)
-- 	local item_config = ItemData.Instance:GetItemConfig(item_id)
-- 	if nil == item_config then return end
	
-- 	local item_color = string.format("%06x", item_config.color)
-- 	local str = string.format(Language.Shop.BuyTips, price * item_count, ShopData.GetMoneyTypeName(price_type), item_color, item_config.name, item_count)
	
-- 	self.buy_alert = self.buy_alert or Alert.New()
-- 	self.buy_alert:SetShowCheckBox(true)
-- 	self.buy_alert:SetLableString(str)
-- 	self.buy_alert:SetOkFunc(function()
-- 		if price_type == 2 then self:OpenGetBingGoldWindow(price * item_count) end
-- 		ShopCtrl.BuyItemFromStore(buy_id, item_count, item_id)
-- 	end)
-- 	self.buy_alert:Open()
-- end

-- function ShopNormalView:OpenGetBingGoldWindow(need_bind_gold)
-- 	local bind_gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD)
-- 	if bind_gold < need_bind_gold then -- 绑元不足时打开
-- 		local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[3585]
-- 		local data = string.format("{reward;0;%d;1}", 3585) .. (ways and ways or "")
-- 		TipCtrl.Instance:OpenBuyTip(data)
-- 		return
-- 	end
-- end

------------------------------------------------------------
-- 其它商店物品配置
------------------------------------------------------------
ShopNormalView.ShopItemRender = ShopNormalView.ShopItemRender or BaseClass(BaseRender)
local ShopItemRender = ShopNormalView.ShopItemRender
function ShopItemRender:__init()
	self.item_cell = nil
end

function ShopItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShopItemRender:CreateChild()
	BaseRender.CreateChild(self)

	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	self.item_cell:SetCellBg(ResPath.GetShangCheng("shop_cell_bg"))
	self.item_cell:GetView():setAnchorPoint(cc.p(0.5, 0.5))
	self.view:addChild(self.item_cell:GetView(), 10)
	-- XUI.AddClickEventListener(self.node_tree.btn_buy.node, BindTool.Bind(self.OnClickBuyBtn, self), true)
end

function ShopItemRender:OnFlush()
	if nil == self.data then return end
	self.item_cell:SetData({["item_id"] = self.data.item, ["num"] = self.data.buyOnceCount, ["is_bind"] = self.data.price[1].bind and 1 or 0})
	if self.data.item == SettingData.DELIVERY_T[1] or self.data.item == SettingData.DELIVERY_T[2] then
		self.item_cell:SetRightBottomText(self.data.buyOnceCount * 50)
	end
	
	local item_config = ItemData.Instance:GetItemConfig(self.data.item)
	self.node_tree.lbl_item_name.node:setString(item_config.name)
	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	
	local cost_path = ShopData.GetMoneyTypeIcon(self.data.price[1].type)
	self.node_tree.img_cost.node:loadTexture(cost_path)
	self.node_tree.lbl_item_cost.node:setColor(COLOR3B.GOLD)
	self.node_tree.lbl_item_cost.node:setString(self.data.price[1].price)

	local item = ShopData.GetItemPriceCfg(self.data.item, self.data.price[1].type, self.data.id)
	self.node_tree.img_xg.node:setVisible(item.dayLimit ~= 0)
end

-- function ShopItemRender:CreateSelectEffect()
-- 	return
-- end

-- function ShopItemRender:OnClickBuyBtn()
-- 	if nil ~= self.click_callback then
-- 		self.click_callback(self)
-- 	end
-- end

function ShopItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

--快速购买确认
QuickBuyWithConfirm = QuickBuyWithConfirm or BaseClass(QuickBuy)
function QuickBuyWithConfirm:SetConfirmCallback(callback)
	self.confirm_callback = callback
end

function QuickBuyWithConfirm:OnClickBuy()
	if self.confirm_callback then
		self.confirm_callback(self.item_price_cfg.id, self.item_count, self.item_id, self.auto_use)
	else
		QuickBuy.OnClickBuy(self)
	end
end

return ShopNormalView