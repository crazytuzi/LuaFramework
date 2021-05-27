------------------------------------------------------------
--商城相关主View
------------------------------------------------------------
ShopView = ShopView or BaseClass(BaseView)

--初始化
function ShopView:__init()
	self.texture_path_list[1] = "res/xui/shangcheng.png"
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 3, {0}},
		{"shop_ui_cfg", 1, {0}},
		{"shop_ui_cfg", 5, {0}},
	}

	self.tabbar_group = {ViewDef.Shop.Prop, ViewDef.Shop.Bind_yuan, ViewDef.Shop.Yongzhe}
	require("scripts/game/shop/shop_normal_view").New(ViewDef.Shop.Prop, self)
	require("scripts/game/shop/shop_normal_view").New(ViewDef.Shop.Bind_yuan, self)
	require("scripts/game/shop/shop_normal_view").New(ViewDef.Shop.Yongzhe, self)

	self.tabbar = nil
	self.index = nil
	self.num_keyboard = nil
	self.item_count = 1
	self.item_id = nil
end

function ShopView:__delete()
end

--释放回调
function ShopView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if nil ~= self.num_keyboard then
		self.num_keyboard:DeleteMe()
		self.num_keyboard = nil
	end

	self.index = nil
	self.item_cfg = nil
	self.auto_use = nil
	self.item_id = nil
end

function ShopView:LoadCallBack(index, loaded_times)
	self:InitTabbar()
	self:InitCreat()
	self:CreateKeyBoard()
	self.node_t_list.btn_charge.node:setVisible((not IS_ON_CROSSSERVER))
--    if IS_AUDIT_VERSION then
--        self.node_t_list.btn_charge.node:setVisible(false)
--    end
	
	-- self.tabbar:SetToggleVisible(1, false)
	--立即充值按钮监听
	XUI.AddClickEventListener(self.node_t_list.btn_charge.node, BindTool.Bind(self.OnChargeIngotsClicked, self), true)

	XUI.AddClickEventListener(self.node_t_list.img9_buy_num_bg.node, BindTool.Bind1(self.OnOpenPopNum, self), false)
	XUI.AddClickEventListener(self.node_t_list.btn_minus.node, BindTool.Bind2(self.OnClickChangeNum, self, -1))
	XUI.AddClickEventListener(self.node_t_list.btn_plus.node, BindTool.Bind2(self.OnClickChangeNum, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_buy.node, BindTool.Bind1(self.OnClickBuy, self))

	--特效
	local path, name = ResPath.GetEffectUiAnimPath(500)
	local eff_1 = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, 0.12, false)
	eff_1:setPosition(385, 485)
	self.node_t_list.layout_comon_bg.node:addChild(eff_1, 6)
	eff_1:setVisible(true)

	local eff_2 = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, 0.12, false)
	eff_2:setPosition(780, 485)
	eff_2:setScaleX(-1)
	self.node_t_list.layout_comon_bg.node:addChild(eff_2, 6)
	eff_2:setVisible(true)
	-- if IS_ON_CROSSSERVER then
	-- 	self.index = 2
	-- 	self.tabbar:SetToggleVisible(1, false)
	-- 	ViewManager.Instance:OpenViewByDef(ViewDef.Shop.Prop)
	-- 	ViewDef.Shop.default_child = "Prop"
	-- else
	-- 	if not ViewManager.Instance:IsOpen(ViewDef.Shop.Bind_yuan) then
	-- 		self.index = 1
	-- 		ViewManager.Instance:OpenViewByDef(ViewDef.Shop.Mystical)
	-- 		ViewDef.Shop.default_child = "Mystical"
	-- 	else
	-- 		self.index = 3
	-- 		ViewManager.Instance:OpenViewByDef(ViewDef.Shop.Bind_yuan)
	-- 		ViewDef.Shop.default_child = "Bind_yuan"
	-- 	end
	-- end
end

--商店打开回调
function ShopView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.ShopOpen))
end

--商店关闭回调
function ShopView:CloseCallBack(is_all)
	--播放声音
	AudioManager.Instance:StopEffect(ResPath.GetAudioEffectResPath(AudioEffect.ShopOpen))
	AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.ShopClose))
end

--显示指数回调
function ShopView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(1)
	self:Flush()
end

function ShopView:OnFlush(params_t, index)
	if not params_t then return end

	for k, v in pairs(params_t) do
		if k == "shop_buy" then
			self:FlushItem(v.data, v.type, v.id)
		end
	end
end

--标签栏初始化
function ShopView:InitTabbar()
	if nil == self.tabbar then
		local tabgroup = {}
		for k, v in pairs(self.tabbar_group) do
			tabgroup[#tabgroup + 1] = v.name
		end
		self.tabbar = Tabbar.New()
		self.tabbar:SetTabbtnTxtOffset(2, 12)
		self.tabbar:CreateWithNameList(self.node_t_list.layout_comon_bg.node, self.ph_list.ph_tabbar.x, self.ph_list.ph_tabbar.y + 60,
		BindTool.Bind(self.TabSelectCellBack, self),
		tabgroup, true, ResPath.GetCommon("toggle_110"), 25, true)
		-- self.tabbar:SetSpaceInterval(15)
		self.tabbar:GetView():setLocalZOrder(1)
	end
end

--选择标签回调
function ShopView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.tabbar_group[index])
	--刷新标签栏显示
	self.tabbar:ChangeToIndex(index)
	self.item_count = 1

	local item = 1
	if index < 4 then
		item = index + 1
	elseif index == 4 then
		item = 7
	end
	
	local data_list = ShopData.GetShopCfg(item)
	if next(data_list) == nil then return end
	self:FlushItem(data_list[1].item, data_list[1].price[1].type, data_list[1].id)
end

--打开充值界面
function ShopView:OnChargeIngotsClicked()
	if IS_ON_CROSSSERVER then return end
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

-- 购买物品
function ShopView:InitCreat()
	if self.item_cell then return end

	local item_cell = BaseCell.New()
	item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:SetIsShowTips(true)
	self.node_t_list.layout_item_info.node:addChild(item_cell:GetCell(), 200, 200)
	self.item_cell = item_cell

	local data_list = ShopData.GetShopCfg(3)
	
	self:FlushItem(data_list[1].item, data_list[1].price[1].type)
end

-- 购买物品展示
function ShopView:FlushItem(item_id, type, id)
	self.item_id = tonumber(item_id)
	self.item_cfg = ShopData.GetItemPriceCfg(self.item_id, type, id)

	if nil == self.item_cfg then
		return
	end

	local item_config = ItemData.Instance:GetItemConfig(self.item_id)
	if nil == item_config then
		return
	end

	local price_type = self.item_cfg.price[1].type
	self.node_t_list.img_cost_type.node:loadTexture(ShopData.GetMoneyTypeIcon(price_type))

	local item_data = {item_id = self.item_id, num = self.item_cfg.buyOnceCount, is_bind = self.item_cfg.price[1].bind and 1 or 0}
	self.item_cell:SetData(item_data)

	self.node_t_list.lbl_name.node:setString(item_config.name)
	local text = Language.Shop.limitBuyNot
	if self.item_cfg.dayLimit ~= 0 then
		text = string.format(Language.Shop.limitBuyTime, self.item_cfg.dayLimit)
	end
	self.node_t_list.lbl_limit.node:setString(text)
	self.node_t_list.lbl_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))

	RichTextUtil.ParseRichText(self.node_t_list.lbl_desc.node, item_config.desc, 16, COLOR3B.GOLD)

	self:RefreshPurchaseView(1)
end

--创建数字键盘
function ShopView:CreateKeyBoard()
	if self.num_keyboard then return end

	self.num_keyboard = NumKeypad.New()
	self.num_keyboard:SetOkCallBack(BindTool.Bind1(self.OnClickEnterNumber, self))
end

function ShopView:GetMaxBuyNum()
	if self.item_cfg == nil then
		return 1
	end

	local item_price = self.item_cfg.price[1].price
	local price_type = self.item_cfg.price[1].type
	local obj_attr_index = ShopData.GetMoneyObjAttrIndex(price_type)
	local role_money = RoleData.Instance:GetAttr(obj_attr_index)
	local enough_num = math.floor(role_money / item_price)

	return enough_num > 0 and enough_num or 1
end

function ShopView:OnOpenPopNum()
	if nil ~= self.num_keyboard then
		self.num_keyboard:Open()
		self.num_keyboard:SetText(self.item_count)
		self.num_keyboard:SetMaxValue(self:GetMaxBuyNum())
	end
end

--输入数字
function ShopView:OnClickEnterNumber(num)
	self:RefreshPurchaseView(num)
end

function ShopView:OnClickChangeNum(change_num)
	local num = self.item_count + change_num
	
	if num < 1 then
		return
	end

	if num > self:GetMaxBuyNum() then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.MaxValue)
		return
	end

	self.item_count = num
	self:RefreshPurchaseView(self.item_count)
end

--刷新购买版界面
function ShopView:RefreshPurchaseView(item_count)
	if self.item_cfg == nil then
		return
	end

	local item_price = self.item_cfg.price[1].price
	self.node_t_list.lbl_num.node:setString(item_count)
	self.node_t_list.lbl_all_price.node:setString(item_count * item_price)
	self.item_count = item_count
	if self.item_id == SettingData.DELIVERY_T[1] or self.item_id == SettingData.DELIVERY_T[2] then
		self.item_cell:SetRightBottomText(item_count * 50)
	end
end

function ShopView:OnClickBuy()
	if self.item_cfg == nil then
		return
	end

	--有些物品不需要使用
	local need_auto_use = not ItemData.Instance:GetItemConfig(self.item_id).openUi
	ShopCtrl.BuyItemFromStore(self.item_cfg.id, self.item_count, self.item_id, (self.auto_use and need_auto_use) and 1 or 0)
	self.auto_use = nil
end

-- 设置一次购买并使用
function ShopView:SetOnceAutoUse(auto_use)
	self.auto_use = auto_use and 1 or 0
end