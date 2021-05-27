------------------------------------------------------------
--背包相关主View
------------------------------------------------------------
BagShopView = BagShopView or BaseClass(BaseView)

function BagShopView:__init()
	self.texture_path_list[1] = 'res/xui/bag.png'
	self.config_tab = {
		-- {"common2_ui_cfg", 1, {0}},
		{"bag_ui_cfg", 3, {0}},
		-- {"common2_ui_cfg", 2, {0}},
	}
end

function BagShopView:__delete()
end

function BagShopView:ReleaseCallBack()
	if self.shop_list_view then
		self.shop_list_view:DeleteMe()
		self.shop_list_view = nil
	end
end

function BagShopView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateShopItems()

		EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))

		-- XUI.AddClickEventListener(self.node_t_list.btn_add_coin.node,function () ViewManager.Instance:OpenViewByDef(ViewDef.Shop) end, true)
		-- XUI.AddClickEventListener(self.node_t_list.btn_add_bind_coin.node,function () ViewManager.Instance:OpenViewByDef(ViewDef.Shop) end, true)
		-- XUI.AddClickEventListener(self.node_t_list.btn_add_gold.node,function () ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge) end, true)
		-- XUI.AddClickEventListener(self.node_t_list.btn_add_bind_gold.node,function () ViewManager.Instance:OpenViewByDef(ViewDef.Shop) end, true)
	end
end

function BagShopView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BagShopView:ShowIndexCallBack(index)
	self:Flush()
end

function BagShopView:OnGetUiNode(node_name)
	local num = tonumber(string.match(node_name, "^BagShop(%d+)$"))
	if num then
		if self.shop_list_view and self.shop_list_view:GetItemAt(num) and self.shop_list_view:GetItemAt(num).node_tree.btn_bag_buy then
			return self.shop_list_view:GetItemAt(num).node_tree.btn_bag_buy.node, true
		end
	end
	return BagShopView.super.OnGetUiNode(self, node_name)
end

function BagShopView:CreateShopItems()
	local ph = self.ph_list.ph_shop_item_list
	self.shop_list_view = ListView.New()
	self.shop_list_view:Create(ph.x, ph.y, ph.w, ph.h, nil, BagShopItemRender, nil, nil, self.ph_list.ph_per_shop_item)
	self.node_t_list.layout_per_shop.node:addChild(self.shop_list_view:GetView(), 100)
	self.shop_list_view:SetItemsInterval(4)
	self.shop_list_view:SetMargin(1)

	self.shop_list_view:SetDataList(ShopData.GetShopCfg(5))
	self.shop_list_view:JumpToTop(true)
	self.shop_list_view:SelectIndex(1)
end

-- 背包商城货币显示
-- function BagShopView:FlushMoney()
-- 	local coin = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN))
-- 	self.node_t_list.lbl_coin_num.node:setString(coin)
-- 	local bind_coin = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN))
-- 	self.node_t_list.lbl_bind_coin_num.node:setString(bind_coin)
-- 	local bind_gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD))
-- 	self.node_t_list.lbl_bind_gold_num.node:setString(bind_gold)
-- 	local gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
-- 	self.node_t_list.lbl_gold_num.node:setString(gold)
-- end

function BagShopView:OnFlush(param_t, index)
	-- self:FlushMoney()
end

function BagShopView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BagShopView:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_BIND_COIN 
		or key == OBJ_ATTR.ACTOR_COIN
		or key == OBJ_ATTR.ACTOR_BIND_GOLD
		or key == OBJ_ATTR.ACTOR_GOLD
	then
		self:Flush()
	end
end


----------------------------------------------------
-- 商店itemRender
----------------------------------------------------
BagShopItemRender = BagShopItemRender or BaseClass(BaseRender)

function BagShopItemRender:__init()
end

function BagShopItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function BagShopItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	self.item_cell:GetView():setAnchorPoint(cc.p(0.5, 0.5))
	self.view:addChild(self.item_cell:GetView(), 100)
	XUI.AddClickEventListener(self.node_tree.btn_bag_buy.node, BindTool.Bind1(self.OnClickBuy, self))
end

function BagShopItemRender:OnFlush()
	if nil == self.data then
		return
	end

	local item_id = self.data.item
	local item_config = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_config then
		return
	end
	self.item_cell:SetData({["item_id"] = item_id, ["num"] = self.data.buyOnceCount, ["is_bind"] = self.data.price[1].bind and 1 or 0})

	local name_color = Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6))
	RichTextUtil.ParseRichText(self.node_tree.rich_sale_item_name.node, item_config.name, 20, name_color)

	local cost_path = ShopData.GetMoneyTypeIcon(self.data.price[1].type)

	if item_id == SettingData.DELIVERY_T[1] or item_id == SettingData.DELIVERY_T[2] or item_id == 500 then 
		self.item_cell:SetRightBottomText(50)
	end

	self.node_tree.img_cost_type.node:loadTexture(cost_path)
	self.node_tree.label_sale_item_cost.node:setColor(COLOR3B.WHITE)
	self.node_tree.label_sale_item_cost.node:setString(self.data.price[1].price)
end

function BagShopItemRender:OnClickBuy()
	if nil == self.data then return end
	if self.data.price[1].type == 2 then self:OpenGetBingGoldWindow(self.data.price[1].price) end
	local buy_id = self.data.id
	local buy_count = 1
	local item_id = self.data.item
	ShopCtrl.BuyItemFromStore(buy_id, buy_count, item_id)
end

function BagShopItemRender:OpenGetBingGoldWindow(need_bind_gold)
	local bind_gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD)
	if bind_gold < need_bind_gold then -- 绑元不足时打开
		local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[3585]
		local data = string.format("{reward;0;%d;1}", 3585) .. (ways and ways or "")
		TipCtrl.Instance:OpenBuyTip(data)
		return
	end
end

function BagShopItemRender:CreateSelectEffect()
end