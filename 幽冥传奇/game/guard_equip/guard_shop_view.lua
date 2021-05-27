--------------------------------------------------------
-- 守护商店  配置 GuardGodEquipShopConfig
--------------------------------------------------------

GuardShopView = GuardShopView or BaseClass(BaseView)

function GuardShopView:__init()
	self.title_img_path = ResPath.GetWord("word_guard_equip_shop")
	self.texture_path_list[1] = 'res/xui/guard_equip.png'
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"guard_equip_ui_cfg", 2, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.shop_type = 1
end

function GuardShopView:__delete()
end

--释放回调
function GuardShopView:ReleaseCallBack()
	
end

--加载回调
function GuardShopView:LoadCallBack(index, loaded_times)
	self:CreateTabbar()
	self:CreateShopItemList()

	local cfg = GuardGodEquipShopConfig or {}
	local consumes = cfg.refreshConsumes or {}
	local count = consumes[1] and consumes[1].count
	self.node_t_list["lbl_flush_consume"].node:setString(count)

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_flush_shop"].node, BindTool.Bind(self.OnFlushShop, self))

	-- 数据监听
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(GuardEquipData.Instance, self):AddEventListener(GuardEquipData.GUARD_SHOP_DATA_CHANGE, BindTool.Bind(self.OnGuardShopDataChange, self))
end

function GuardShopView:OpenCallBack()
	GuardEquipCtrl.SendGuardShopInfoReq()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuardShopView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

--显示指数回调
function GuardShopView:ShowIndexCallBack(index)
	self:CreateTimer()

	local cfg = GuardGodEquipShopConfig or {}
	local openviplvs = cfg.openviplvs or {}
	local vip_lv = VipData.Instance:GetVipLevel()
	for i,v in ipairs(openviplvs) do
		self.tabbar:SetToggleVisible(i, v <= vip_lv)
	end

	local show_id = cfg.show_id or 0
	local item_num = BagData.Instance:GetItemNumInBagById(show_id, nil)
	self.node_t_list["lbl_consume_count"].node:setString(item_num)
end
----------视图函数----------

function GuardShopView:CreateTabbar()
	local ph = self.ph_list["ph_tabbar_list"]
	local name_list = Language.GuardEquip.ShopName
	local parent = self.node_t_list["layout_guard_shop"].node
	local tabbar = Tabbar.New()
	tabbar:CreateWithNameList(parent, ph.x, ph.y, BindTool.Bind(self.TabSelectCellBack, self),
		name_list, true, ResPath.GetGuardEquip("guard_shop"), 23)
	tabbar:SetSpaceInterval(15)
	self.tabbar = tabbar
	self:AddObj("tabbar")
end

function GuardShopView:CreateTimer()
	self.time = GuardEquipData.Instance:GetMyRefreLeftTime()
	self.node_t_list["lbl_flush_time"].node:setString(Language.GuardEquip.ShopTimeText .. TimeUtil.FormatSecond(self.time, true))
	self.node_t_list["lbl_flush_time"].node:setVisible(true)
	if nil == self.timer then
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushTimer, self), 1)
	end
end

function GuardShopView:FlushTimer()
	self.time = GuardEquipData.Instance:GetMyRefreLeftTime()
	self.node_t_list["lbl_flush_time"].node:setString(Language.GuardEquip.ShopTimeText .. TimeUtil.FormatSecond(self.time, true))
	if self.time <= 0 then
		self.node_t_list["lbl_flush_time"].node:setVisible(false)
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function GuardShopView:CreateShopItemList()
	local ph = self.ph_list["ph_item_list"]
	local ph_item = self.ph_list["ph_item"]
	local parent = self.node_t_list["layout_guard_shop"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 2, ph_item.h + 5, self.ShopItemShow, ScrollDir.Vertical, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	grid_scroll:SetDataList(GuardEquipData.Instance:GetGuardShopShowList(1))
	self.shop_item_list = grid_scroll
	self:AddObj("shop_item_list")
end

----------end----------

function GuardShopView:TabSelectCellBack(index)
	self.shop_type = index
	local list = GuardEquipData.Instance:GetGuardShopShowList(index)
	self.shop_item_list:SetDataList(list)
end

function GuardShopView:OnBagItemChange(event)
	if not self:IsOpen() then return end

	local cfg = GuardGodEquipShopConfig or {}
	local show_id = cfg.show_id or 0
	local item_num = BagData.Instance:GetItemNumInBagById(show_id, nil)
	self.node_t_list["lbl_consume_count"].node:setString(item_num)
	
	local shop_need_flush = false
	for i,v in ipairs(event.GetChangeDataList()) do
		local item_type = v.data and v.data.type or -1
		if v.change_type == ITEM_CHANGE_TYPE.LIST or item_type == ItemData.ItemType.itGuardEquip then
			shop_need_flush = true
			break
		end
	end
	if shop_need_flush then
		local list = GuardEquipData.Instance:GetGuardShopShowList(self.shop_type)
		self.shop_item_list:SetDataList(list)
	end
end

function GuardShopView:OnFlushShop()
	GuardEquipCtrl.SendFlushGuardEquipReq(self.shop_type)
end

function GuardShopView:OnGuardShopDataChange(shop_type)
	if shop_type == self.shop_type then
		local list = GuardEquipData.Instance:GetGuardShopShowList(shop_type)
		self.shop_item_list:SetDataList(list)
	end
end

--------------------

----------------------------------------
-- 项目渲染命名
----------------------------------------
GuardShopView.ShopItemShow = BaseClass(BaseRender)
local ShopItemShow = GuardShopView.ShopItemShow
function ShopItemShow:__init()
	self.cell = nil
end

function ShopItemShow:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function ShopItemShow:CreateChild()
	BaseRender.CreateChild(self)
	local cell = BaseCell.New()
	local ph = self.ph_list["ph_cell"]
	cell:SetPosition(ph.x, ph.y)
	self.view:addChild(cell:GetView(), 20)
	self.cell = cell

	XUI.AddClickEventListener(self.node_tree["btn_buy"].node, BindTool.Bind(self.OnBuy, self), true)
end

function ShopItemShow:OnFlush()
	if nil == self.data then return end
	local cfg = self.data.cfg or {}
	local awards = cfg.awards or {}
	local item_data = ItemData.InitItemDataByCfg(awards[1])
	self.cell:SetData(item_data)

	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
	self.node_tree["lbl_item_name"].node:setString(item_cfg.name)

	local consumes = cfg.consumes or {}
	local consume_data = consumes[1] or {}
	local consume_count = consume_data.count or ""
	self.node_tree["lbl_consume_count"].node:setString(consume_count)

	local vis = self.data.buy_count >= 1
	self.node_tree["img_is_buy"].node:setVisible(vis)
	self.node_tree["btn_buy"].node:setEnabled(not vis)

	
	self.cell:SetUpFlagIconVisible(self.data.is_better and (not vis))	
end

function ShopItemShow:CreateSelectEffect()
	return
end

function ShopItemShow:OnBuy()
	GuardEquipCtrl.SendBuyGuardEquipReq(self.data.shop_type, self.data.shop_index)
end

function ShopItemShow:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end