BagView = BagView or BaseClass(XuiBaseView)

function BagView:InitBagView()
	self.cd_timer = nil
	self.tabbar = nil
	self:InitTabbar()
	--背包网格
	local bag_cells = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BAG_GRID_COUNT)
	self.bag_grid = BaseGrid.New()
	self.bag_grid:SetGridName(GRID_TYPE_BAG)
	self.bag_grid:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
	local ph_baggrid = self.ph_list.ph_bag_grid
	local grid_node = self.bag_grid:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count = bag_cells, col=5, row=5})
	grid_node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_bag_bag.node:addChild(grid_node, 100)
	grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
	self.bag_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
	self.bag_grid:SetDataList(ItemData.Instance:GetBagItemDataList())
	self.bag_grid:SetIsShowTips(false)

	ClientCommonButtonDic[CommonButtonType.BAG_ITEM_GRID] = self.bag_grid

	self.node_t_list.bagCellNumText.node:setString(ItemData.Instance:GetItemTotalNum() .. "/" .. bag_cells)

	self.bag_radio = RadioButton.New()
	self.bag_radio:SetRadioButton(self.node_t_list.layout_bag_grid_page)
	self.bag_radio:SetSelectCallback(BindTool.Bind1(self.BagRadioHandler, self))
	self.bag_grid:SetRadioBtn(self.bag_radio)
	self:CreateShopItems()
	self:CreateRoleInfoWidget()
	self:ShowLeftLayout()
	
	self.node_t_list.btn_huishou.node:addClickEventListener(BindTool.Bind1(self.OnClickHuishouHandler, self))
	self.node_t_list.btn_cleanup.node:addClickEventListener(BindTool.Bind1(self.OnClickCleanupHandler, self))
	self.node_t_list.btn_storage.node:addClickEventListener(BindTool.Bind1(self.OnClickStorageHandler, self))
	self.node_t_list.btn_shop.node:addClickEventListener(BindTool.Bind1(self.OnClickShopHandler, self))
	self.node_t_list.btn_shop_return.node:addClickEventListener(BindTool.Bind1(self.OnClickShopReturnHandler, self))
	self.node_t_list.layout_tip.node:setVisible(false)
	self:CreateExpBallLayout()
	ClientCommonButtonDic[CommonButtonType.BAG_RECYCLE_BTN] = self.node_t_list.btn_huishou.node
	ClientCommonButtonDic[CommonButtonType.BAG_SHOP_BTN] = self.node_t_list.btn_shop.node
	self.img_flag = XUI.CreateImageView(985, 80, ResPath.GetMainui("remind_flag"), true)
	self.img_flag:setScale(0.8)
	self.img_flag:setVisible(false)
	self.node_t_list.layout_bag_bag.node:addChild(self.img_flag, 999)
end

function BagView:CreateShopItems()
	local ph = self.ph_list.ph_bag_shop_list
	self.shop_list_view = ListView.New()
	self.shop_list_view:Create(ph.x, ph.y, ph.w, ph.h, nil, BagShopItemRender, nil, nil, self.ph_list.ph_bag_shop_item)
	self.node_t_list.layout_bag_shop.node:addChild(self.shop_list_view:GetView(), 100)
	self.shop_list_view:SetItemsInterval(4)
	self.shop_list_view:SetMargin(1)

	self.shop_list_view:JumpToTop(true)
	self.shop_list_view:SelectIndex(1)

	ClientCommonButtonDic[CommonButtonType.BAG_SHOP_LIST_VIEW] = self.shop_list_view
end

function BagView:OnClickCleanupHandler()
	if BagData.Instance:GetCleanupCdIsEnd() == false then return end
	ItemData.Instance:SortBagList()
	self:SetCleanupCdTime()
end

function BagView:OnClickHuishouHandler()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	local function RBtnEvent()
		Scene.Instance:CommonSwitchTransmitSceneReq(117)
	end
	
	if TipsCtrl.HasVipPower(2, true, {vip = 2, scene_name = Lang.SceneName.s00004, npc_name = Lang.EntityName.n00099, 
		power_name = Language.Bag.RecycleVipTips, r_btn = Language.Bag.RecycleVipbtnRight, r_btn_event = RBtnEvent}) then
		ViewManager.Instance:Open(ViewName.Recycle)
		ViewManager.Instance:FlushView(ViewName.Recycle, 0, "vip_opt")
	end
end

function BagView:OnClickStorageHandler()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	
	local function RBtnEvent()
		Scene.Instance:CommonSwitchTransmitSceneReq(118)
	end
	if TipsCtrl.HasVipPower(1, true, {vip = 1, scene_name = Lang.SceneName.s00004, npc_name = Lang.EntityName.n00035, 
		power_name = Language.Bag.StorageVipTips, r_btn = Language.Bag.StorageVipbtnRight, r_btn_event = RBtnEvent}) then
		ViewManager.Instance:Open(ViewName.Storage)
	end
end

function BagView:OnClickShopHandler()
	self:ChangeLeftShow()
end

function BagView:OnClickShopReturnHandler()
	self:ChangeLeftShow()
end

function BagView:DeleteBagView()
	ClientCommonButtonDic[CommonButtonType.BAG_SHOP_LIST_VIEW] = nil
	ClientCommonButtonDic[CommonButtonType.BAG_RECYCLE_BTN] = nil
	ClientCommonButtonDic[CommonButtonType.BAG_SHOP_BTN] = nil
	ClientCommonButtonDic[CommonButtonType.BAG_ITEM_GRID] = nil

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.bag_grid then
		self.bag_grid:DeleteMe()
		self.bag_grid = nil
	end

	if self.bag_radio then
		self.bag_radio:DeleteMe()
		self.bag_radio = nil
	end

	if self.role_info_widget then
		self.role_info_widget:DeleteMe()
		self.role_info_widget = nil
	end

	if self.shop_list_view then
		self.shop_list_view:DeleteMe()
		self.shop_list_view = nil
	end

	if nil ~= self.exp_cell then
		self.exp_cell:DeleteMe()
		self.exp_cell = nil
	end

	if nil ~= self.exp_ball_radio_select_index then
		self.exp_ball_radio_select_index = nil
	end

	if nil ~= self.exp_ball_radio then
		self.exp_ball_radio:DeleteMe()
		self.exp_ball_radio = nil
	end

	if nil ~= self.exp_ball_show_list then
		self.exp_ball_show_list = nil
	end

	if nil ~= self.exp_cell_data then
		self.exp_cell_data = nil
	end

	if nil ~= self.show_left_layout_load_callback then
		self.show_left_layout_load_callback = nil
	end

	self:ClearCdTimer()
end

function BagView:OnFlushBag(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			local coin = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN))
			self.node_t_list.label_bind_coin_num.node:setString(coin)
			local bind_gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD))
			self.node_t_list.label_bind_gold_num.node:setString(bind_gold)
			local gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
			self.node_t_list.label_gold_num.node:setString(gold)
			self:UpdateBagShop()
		elseif k == "baglist_change" then
			if self.tabbar:GetCurSelectIndex() == 1 then
				for key, value in pairs(v) do
					if value.change_type == ITEM_CHANGE_TYPE.LIST then
						self:RereshItem(self.tabbar:GetCurSelectIndex())
					else
						local item = self.bag_grid:GetCell(key)
						if type(item) ~= nil then
							item:SetData(ItemData.Instance:GetGridData(key))
							local items = self.bag_grid:GetAllCell()
							for k,v in pairs(items) do
								v:Flush()
							end

							GlobalTimerQuest:AddDelayTimer(function()
								self:CheckHasNextFullExpBall()
							end, 0.1)
						end
					end
				end	
				local bag_cells = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BAG_GRID_COUNT)
				self.node_t_list.bagCellNumText.node:setString(ItemData.Instance:GetItemTotalNum() .. "/" .. bag_cells)
			else
				self:RereshItem(self.tabbar:GetCurSelectIndex())
			end
		elseif k == "FlushItem" then
			self:UpdateBagShop()
		elseif k == "change_shop" then	
			self:ShowLeftLayout("shop")
		end
	end
end

function BagView:CreateRoleInfoWidget()
	self.role_info_widget = RoleInfoView.New()
	self.role_info_widget:CreateViewByUIConfig(self.ph_list.ph_role_info_widget, "equip")
	self.node_t_list.layout_role_info.node:addChild(self.role_info_widget:GetView(), 200) 
	self.role_info_widget:SetRoleData(RoleData.Instance.role_vo)
end

function BagView:OnBagPageChange(grid_view, cur_page_index, prve_page_index)
end

function BagView:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.node_t_list.layout_bag_tab.node, 0, -3,
			BindTool.Bind1(self.SelectTabCallback, self), 
			Language.Bag.TabType, false, ResPath.GetCommon("toggle_105_normal"), nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar:SetSpaceInterval(0)
	end
end

function BagView:SelectTabCallback(index)
	self.tabbar:ChangeToIndex(index)
	self:RereshItem(index)
end

function BagView:RereshItem(index)
	local data = BagData.Instance:GetBagShowData(index)
	self.bag_grid:SetDataList(data)
end

function BagView:SelectCellCallBack(cell)
	if cell == nil then
		return
	end

	local cell_data = cell:GetData()
	local is_try_open_cell = self:TryOpenCell(cell)
	if is_try_open_cell then
		return
	end
	TipsCtrl.Instance:OpenItem(cell_data, EquipTip.FROM_BAG)				--打开tip,提示使用
end

function BagView:TryOpenCell(cell)
	if cell == nil or cell:GetData() ~= nil then return end

	local grid_name = cell:GetName()
	if grid_name == GRID_TYPE_BAG or grid_name == GRID_TYPE_STORAGE then
		if cell:GetIsOpen() == false then
			local open_num = 0
			local ok_callback = nil
			if grid_name == GRID_TYPE_BAG then
				open_num = cell:GetIndex() - ItemData.Instance.max_knapsack_valid_num + 1
				ok_callback = BindTool.Bind1(self.OnOpenBagGrid, self)
			elseif grid_name == GRID_TYPE_STORAGE then
				open_num = cell:GetIndex() - ItemData.Instance.max_storage_valid_num + 1
				ok_callback = BindTool.Bind1(self.OnOpenStorageGrid, self)
			end

			local tip = self:GetOpenBagCellTip(cell:GetIndex(), grid_name)
			self.pop_alert = self.pop_alert or Alert.New()
			self.pop_alert:SetLableString(tip)
			self.pop_alert:Open()
			self.pop_alert:SetOkFunc(ok_callback)
			self.pop_alert:SetData(open_num)
		end
		return true
	end
	return false
end

function BagView:BagRadioHandler(index)
	if nil ~= self.bag_grid then
		self.bag_grid:ChangeToPage(index)
	end
end

function BagView:ChangeLeftShow()
	if self.shop_is_open then
		self:ShowLeftLayout()
	else
		self:ShowLeftLayout("shop")
	end
end


function BagView:ShowLeftLayout(name, data)
	if nil == self.node_t_list or nil == self.node_t_list.layout_role_info
		or nil == self.node_t_list.layout_bag_shop or nil == self.node_t_list.layout_jingyanzhu then
		self.show_left_layout_load_callback = BindTool.Bind(self.ShowLeftLayout, self, name, data)
		return
	end
	self.node_t_list.layout_role_info.node:setVisible(false)
	self.node_t_list.layout_bag_shop.node:setVisible(false)
	self.node_t_list.layout_jingyanzhu.node:setVisible(false)
	self.shop_is_open = false

	if name == "shop" then
		self.shop_is_open = true
		self.node_t_list.layout_bag_shop.node:setVisible(true)
	elseif name == "exp_ball" then
		self.node_t_list.layout_jingyanzhu.node:setVisible(true)
		self:SetExpCellData(data)
		self:OnFlushExpBall()
	else
		self.node_t_list.layout_role_info.node:setVisible(true)
	end
end

function BagView:GetCleanupCdTime()
	local end_time = BagData.Instance:GetCleanupCdEndTime()
	return math.ceil(end_time - Status.NowTime)
end

function BagView:SetCleanupCdTime()
	BagData.Instance:SetCleanupCdEndTime()
	self:ShowCleanupBtnCd()
end

function BagView:ShowCleanupBtnCd()
	self:ClearCdTimer()
	local cd_time = self:GetCleanupCdTime()
	self:UpdateBtnCd()
	if cd_time > 0 then
		self.cd_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(self.UpdateBtnCd, self), 1, cd_time)
	end
end

function BagView:UpdateBtnCd()
	local cd_time = self:GetCleanupCdTime()
	if nil ~= self.node_t_list.btn_cleanup.node then
		if cd_time <= 0 then
			self.node_t_list.btn_cleanup.node:setTitleText(Language.Bag.Cleanup)
			self:ClearCdTimer()
		else
			self.node_t_list.btn_cleanup.node:setTitleText(Language.Bag.Cleanup .. "(" .. cd_time .. ")")
		end
	end
end

function BagView:ClearCdTimer()
	if nil ~= self.cd_timer then
		GlobalTimerQuest:CancelQuest(self.cd_timer)
		self.cd_timer = nil
	end
end

function BagView:UpdateBagShop()
	local data = BagData.GetBagShop()
	local cur_data = {}
	for k, v in pairs(data) do
		table.insert(cur_data,v)
	end
	
	self.shop_list_view:SetDataList(cur_data)
	self.shop_list_view:SetSelectItemToTop(1)
	local num = BagData.Instance:GetCanUseGoldBuyItem() or 0
	self.img_flag:setVisible(num > 0 and true or false)
end

function BagView:CreateExpBallLayout()
	local ph = self.ph_list.ph_cell_exp
	local cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	cell:SetAnchorPoint(0.5, 0.5)
	cell:SetSkinStyle({bg = ResPath.GetCommon("cell_101")})
	self.node_t_list.layout_jingyanzhu.node:addChild(cell:GetView(), 100)

	-- local cell_data = {item_id = 482, num = 1, is_bind = 0}
	-- cell:SetData(cell_data)
	self.exp_cell = cell

	local cfg = ItemConvertExpCfg.EpxBeadCfg

	-- 选择
	self.exp_ball_radio_select_index = 1
	self.exp_ball_show_list = {}

	self.exp_ball_radio = RadioButton.New()
	self.exp_ball_radio:SetRadioButton(self.node_t_list.layout_jingyanzhu_radio)
	self.exp_ball_radio:SetSelectCallback(BindTool.Bind1(self.SelectExpBallRadioHandler, self))
	for i=1,#cfg.awards do
		local ph = self.ph_list["ph_toggle_" .. i]
		local toggle = XUI.CreateToggleButton(ph.x, ph.y, 0, 0, false, ResPath.GetCommon("check_1_bg"), 
			ResPath.GetCommon("check_1_cross"), "", true)
		self.node_t_list.layout_jingyanzhu_radio.node:addChild(toggle)
		self.exp_ball_radio:AddToggle(toggle)
		
		self.exp_ball_show_list[i] = {}
		local toggle_bg = XUI.CreateImageView(ph.x, ph.y, ResPath.GetCommon("check_1_bg"))
		self.node_t_list.layout_jingyanzhu_radio.node:addChild(toggle_bg, -1)
		self.exp_ball_show_list[i].toggle_bg = toggle_bg

		local text_layout = self.node_t_list.layout_jingyanzhu_option["layout_jingyanzhu_txt_" .. i]
		text_layout.lbl_exp_1.node:setString(string.format(Language.Bag.ExpBallTimes, tonumber(cfg.awards[i].expRate) or 0))
		local exp = (tonumber(cfg.baseExp) or 0) * (tonumber(cfg.awards[i].expRate) or 0)
		text_layout.lbl_exp_2.node:setString(CommonDataManager.ConverMoney(exp))
		local free_level = tonumber(cfg.awards[i].viplv)
		local free_txt = ""
		if free_level <= 0 then
			free_txt = Language.Bag.ExpBallFullFree
		else
			free_txt = string.format(Language.Bag.ExpBallVipFree, free_level)
		end
		text_layout.lbl_exp_3.node:setString(string.format(Language.Bag.ExpBallFree, free_txt))

		self.exp_ball_show_list[i].text_layout = text_layout

		XUI.AddClickEventListener(text_layout.node, BindTool.Bind(self.OnClickExpBallTxtCallback, self, i), false)
	end

	self.exp_ball_radio:SelectIndex(self.exp_ball_radio_select_index)

	self.node_t_list.btn_get_jingyan.node:addClickEventListener(BindTool.Bind1(self.OnClickGetExp, self))

	self.is_flush_left_show = false
end

function BagView:SetExpCellData(data)
	if nil == data or nil == data.item_id then return end
	self.exp_cell:SetData(data)
end

function BagView:SetExpBallTextVisibleToIndex(index)
	if nil == self.exp_ball_show_list or #self.exp_ball_show_list < 4 then return end
	local cfg = ItemConvertExpCfg.EpxBeadCfg
	for i=1,#cfg.awards do
		local visible = (i <= index)
		self.exp_ball_radio:SetToggleVisible(i, visible)
		self.exp_ball_show_list[i].toggle_bg:setVisible(visible)
		self.exp_ball_show_list[i].text_layout.node:setVisible(visible)
	end
end

function BagView:SelectExpBallRadioHandler(index)
	self.exp_ball_radio_select_index = index

	local cfg = ItemConvertExpCfg.EpxBeadCfg
	if nil ~= cfg and nil ~= cfg.awards then
		for i=1, #cfg.awards do
			local text_layout = self.node_t_list.layout_jingyanzhu_option["layout_jingyanzhu_txt_" .. i]
			for i1=1, 3 do
				text_layout["lbl_exp_" .. i1].node:setColor(i == index and COLOR3B.GREEN or COLOR3B.WHITE)
			end
		end
	end
end

function BagView:OnClickExpBallTxtCallback(index)
	if not self.exp_ball_radio then return end
	self.exp_ball_radio:SelectIndex(index)
end

function BagView:OnFlushExpBall()
	local vip_level = VipData.Instance.vip_level
	local cfg = ItemConvertExpCfg.EpxBeadCfg
	for i,v in ipairs(cfg.awards) do
		if vip_level < tonumber(v.viplv) then
			self:SetExpBallTextVisibleToIndex(i)
			return
		end
	end
	self:SetExpBallTextVisibleToIndex(4)
end

function BagView:OnClickGetExp()
	self.is_flush_left_show = true
	local data = self.exp_cell:GetData()
	BagCtrl.Instance:SendUseSpecialItemReq(ItemSpecialType.ExpBead, self.exp_ball_radio_select_index, data.series)
end

function BagView:CheckHasNextFullExpBall()
	if not self.is_flush_left_show then return end
	self.is_flush_left_show = false
	local next_data = ItemData.Instance:GetNextFullExpBall()
	if next_data == nil then
		self:ShowLeftLayout()
		return
	else
		self:ShowLeftLayout("exp_ball", next_data)
		return
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
	if self.play_btn_effect then
		--self.play_btn_effect:setStop()
		self.play_btn_effect = nil 
	end
end

function BagShopItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	self.item_cell:GetView():setAnchorPoint(cc.p(0, 0))
	self.view:addChild(self.item_cell:GetView(), 100)
	-- self.item_cell:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.btn_bag_buy.node, BindTool.Bind1(self.OnClickBuy, self))
	XUI.AddClickEventListener(self.item_cell:GetView(), BindTool.Bind(self.OnExpTips, self))
end

function BagShopItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local item_id = self.data.itemId
	local item_config = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_config then
		return
	end
	self.item_cell:SetData({["item_id"] = item_id, ["num"] = 1, ["is_bind"] = 0})

	local name_color = Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6))
	RichTextUtil.ParseRichText(self.node_tree.rich_sale_item_name.node, item_config.name, 20, name_color)
	local price = self.data.consumes[1] and self.data.consumes[1].count
	self.node_tree.label_sale_item_cost.node:setString(price)
	if self.data.consumes[1] and self.data.consumes[1].type == 3 then
		self.node_tree.img_cost_type.node:loadTexture(ResPath.GetCommon("icon_money"))
	elseif self.data.consumes[1] and self.data.consumes[1].type == 10 then
		self.node_tree.img_cost_type.node:loadTexture(ResPath.GetCommon("gold"))
		self:SetEffct()
	end
end

function BagShopItemRender:SetEffct()
	if self.play_btn_effect == nil then
		self.play_btn_effect = AnimateSprite:create()
		self.view:addChild(self.play_btn_effect,999)
	end
    self.play_btn_effect:setPosition(425, 50)
	self.play_btn_effect:setScaleX(0.7)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(10)
	self.play_btn_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
end

function BagShopItemRender:OnClickBuy()
	if nil == self.data then return end
	ViewManager.Instance:Open(ViewName.NpcBuy)
	ViewManager.Instance:FlushView(ViewName.NpcBuy, 0, "param", {self.data})
	-- local item_id = self.data.itemId
	-- BagCtrl.Instance:SendBuyItem(0, item_id, 1)
end

function BagShopItemRender:OnExpTips()
	local data = {}
	data.item_id = self.data.itemId
	if ItemData.GetIsExpButtle(data.item_id) then
		TipsCtrl.Instance:OpenItem(data, EquipTip.FROM_BAG_ON_BUY)
	else
		self.item_cell:OnClick()
	end
end

function BagShopItemRender:CreateSelectEffect()
end

function BagShopItemRender:GetGuideView()
	if self.node_tree and self.node_tree.btn_bag_buy then
		return self.node_tree.btn_bag_buy.node
	end
	return nil
end

function BagShopItemRender:CompareGuideData(data)
	return false
end