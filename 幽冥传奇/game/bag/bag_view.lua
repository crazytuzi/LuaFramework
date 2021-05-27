------------------------------------------------------------
--背包相关主View
------------------------------------------------------------
BagView = BagView or BaseClass(SubView)

function BagView:__init()
	self.close_mode = CloseMode.CloseVisible -- 关闭面板时,不释放

	self.texture_path_list[1] = 'res/xui/bag.png'
	self.config_tab = {
		{"bag_ui_cfg", 1, {0}},
	}

	self.is_clearing = false
	self.tab_index = 1
end

function BagView:__delete()
end

function BagView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.bag_grid then
		self.bag_grid:DeleteMe()
		self.bag_grid = nil
	end
	
	if self.bag_cell_alert then
		self.bag_cell_alert:DeleteMe()
		self.bag_cell_alert = nil
	end
end

function BagView:LoadCallBack(index, loaded_times)
	self:ResignEventListener()
	self:InitEquipTypeTabbar()
	self:CreateBagGird()
end

function BagView:ResignEventListener()	
	XUI.AddClickEventListener(self.node_t_list.btn_melting.node, function() 
		--self:Close()
		BagData.Instance:RecycleStorageChree(1)
		ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
		ViewManager.Instance:CloseViewByDef(ViewDef.MainBagView)
	end, true)

	XUI.AddClickEventListener(self.node_t_list.btn_bag_sort.node, BindTool.Bind(self.OnClickCleanupHandler, self), false)
	XUI.AddClickEventListener(self.node_t_list.btn_go_ck.node, function() 
		ViewManager.Instance:OpenViewByDef(ViewDef.Storage)
	end, false)

	-- 增加格子
	XUI.AddClickEventListener(self.node_t_list.btn_add_cell.node, function() 
		self:MaxBagCellCreate()
	end, false)

	XUI.AddClickEventListener(self.node_t_list.btn_go_shop.node, function() ViewManager.Instance:OpenViewByDef(ViewDef.PerShop) end, false)

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
	
	GlobalEventSystem:Bind(GuideCtrl.ClearingEnd, BindTool.Bind(self.ClearingEnd, self))
end

function BagView:OnBagItemChange()
	self:Flush()
end

function BagView:OnClickCleanupHandler()
	if self.is_clearing == false then
		self.is_clearing = true --正在清理背包
		BagData.Instance:SortAllBagList()
		GuideCtrl.Instance:RemindItemUse()
	end
	--BagData.Instance:SortBagList(self.tabbar:GetCurSelectIndex())
	--GuideCtrl.Instance:RemindItemUse(self.tabbar:GetCurSelectIndex())
end

function BagView:ClearingEnd()
	if self.is_clearing then
		self.is_clearing = false
	end
end

function BagView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BagView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	-- self:DispatchEvent(GameObjEvent.REMOVE_ALL_LISTEN)

	-- 释放增加格子的二次窗口
	if self.bag_cell_alert then
		self.bag_cell_alert:DeleteMe()
		self.bag_cell_alert = nil
	end
end

function BagView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(self.tab_index)
	self:Flush()

	if self.bag_grid then
		self.bag_grid:JumpToPage(1)
	end
end

function BagView:OnFlush(param_t, index)
	-- 在跨服屏蔽熔炼按钮
	self.node_t_list.btn_melting.node:setVisible(not IS_ON_CROSSSERVER)

	local bind_coin = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN))
	self.node_t_list.lbl_bind_coin_num.node:setString("")
	local jifen = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BRAVE_POINT))
	self.node_t_list.lbl_jifen_num.node:setString("")
	local coin = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN))
	self.node_t_list.lbl_coin_num.node:setString("")
	local gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
	self.node_t_list.lbl_gold_num.node:setString("")

	local bag_cells = BagData.Instance:GetBagGridNum()
	if self.bag_grid then
		self.bag_grid:SetDataList(BagData.Instance:GetBagItemDataListByBagType(self.tab_index))
		self.bag_grid:OpenCellToIndex(bag_cells - 1)
	end

	local bag_item = BagData.Instance:GetBagItemDataListByBagType(1)
	local num = next(bag_item) == nil and 0 or #bag_item+1
	self.node_t_list.lbl_bag_num.node:setString(BagData.Instance:GetBagItemCount() .. "/" .. BagData.Instance:GetBagGridNum())
	
	for i,v in pairs(BagData.Instance:GetRemindNum()) do
		self.tabbar:SetRemindByIndex(i,v)
	end
end

function BagView:CreateBagGird()
	--背包网格
	self.bag_grid = BaseGrid.New()
	self.bag_grid:SetGridName(GRID_TYPE_BAG)
	self.bag_grid:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
	local all_num = BagData.Instance:BagAllCell()
	local ph_baggrid = self.ph_list.ph_bag_list
	local grid_node = self.bag_grid:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count = all_num, col=11, row=5, itemRender=BagCell, direction = ScrollDir.Vertical})
	grid_node:setAnchorPoint(0, 0)
	self.node_t_list.layout_bag.node:addChild(grid_node, 100)
	grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
	self.bag_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
end

function BagView:OnBagPageChange(grid_view, cur_page_index, prve_page_index)
	
end

function BagView:SelectCellCallBack(cell)
	if cell:GetIndex() > self.bag_grid:GetMaxOpenIndex() then
		self:MaxBagCellCreate()
	end
end

-- 增加格子的二次窗口创建
function BagView:MaxBagCellCreate()
	if self.bag_cell_alert == nil then
		self.bag_cell_alert = Alert.New()
		self.bag_cell_alert:SetLableString(Language.Bag.BagCellMax)
		self.bag_cell_alert:SetOkString("前往查看")
	end
	self.bag_cell_alert:SetOkFunc(function()
		ViewManager.Instance:OpenViewByDef(ViewDef.Vip)
	end)
	self.bag_cell_alert:Open()
end

function BagView:InitEquipTypeTabbar()
	local tab_group = {"全部", "装备", "材料", "其他"}
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.node_t_list.layout_bag.node, 8, 495,
		BindTool.Bind(self.SelectTabCallback, self), tab_group,
		false, ResPath.GetCommon("toggle_121"), 20)
		self.tabbar:SetSpaceInterval(10)
		self.tabbar:ChangeToIndex(1)
		self.tabbar:GetView():setLocalZOrder(100)
		self.tab_index = 1
	end
end

function BagView:SetCleanupCdTime()
	BagData.Instance:SetCleanupCdEndTime()
	self:ShowCleanupBtnCd()
end

function BagView:SelectTabCallback(index)
	self.tab_index = index
	self:Flush()
end

function BagView:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_BIND_COIN
	or key == OBJ_ATTR.ACTOR_BIND_GOLD
	or key == OBJ_ATTR.ACTOR_GOLD
	or key == OBJ_ATTR.ACTOR_BRAVE_POINT
	or OBJ_ATTR.ACTOR_STALL_GRID_COUNT
	or OBJ_ATTR.ACTOR_BAG_BUY_GRID_COUNT then
		self:Flush()
	end
end

function BagView:ItemDataListChangeCallback(event)
	self:Flush()
end

----------------------------------------------------
-- 背包itemRender
----------------------------------------------------
BagCell = BagCell or BaseClass(BaseCell)

function BagCell:__init()
	
end

function BagCell:__delete()
end

function BagCell:OnFlush(...)
	BaseCell.OnFlush(self)
	self:SetItemTipFrom(EquipTip.FROM_BAG)
	self:SetRemind(false)
	if self.data == nil then return end
	

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local remind = item_cfg and (item_cfg.type == 102 or item_cfg.type == 144) and not CLIENT_GAME_GLOBAL_CFG.ignore_remind_items[item_cfg.item_id]

	self:SetRemind(remind, false, false)
end

--设置上升标记
function BagCell:SetRemind(is_visible, lay, action)
	if lay then
		self.is_remind = is_visible
	end
	if is_visible and self.remind_icon == nil then
		self.remind_icon = self:CreateImage(ResPath.GetMainui("remind_flag"), BaseCell.SIZE - 30, BaseCell.SIZE - 27, 4)
		self.remind_icon:setScale(0.8)
		self.remind_icon:setAnchorPoint(0, 0)
	end
	if self.remind_icon then
		self.remind_icon:setVisible(is_visible)
		self.remind_icon:stopAllActions()
		self.remind_icon:setOpacity(255)
	end
	if is_visible and action then
		local fade_in = cc.FadeIn:create(0.8)
		local fade_out = cc.FadeOut:create(0.3)
		local sequence = cc.Sequence:create(fade_out, fade_in)
		local forever = cc.RepeatForever:create(sequence)
		self.remind_icon:runAction(forever)
	end
end

function BagCell:CreateSelectEffect()
end

--------------------------------------------------------
BagGridScroll = BagGridScroll or BaseClass(GridScroll)
function BagGridScroll:__init()
end

function BagGridScroll:__delete()
end

-- 刷新items列表
function BagGridScroll:RefreshItems()
	if self.data_list == nil or self.item_render == nil or self.view == nil then
		return
	end
	
	local item_count = #self.items
	local data_count = #self.data_list
	if item_count > data_count then					-- item太多 隐藏
		for i = item_count, data_count + 1, - 1 do
			self.items[i]:SetVisible(false)
		end
	elseif item_count < data_count then				-- item不足 创建
		local item = nil
		for i = item_count + 1, data_count do
			item = self.item_render.New(self.width, self.height)
			item:SetAnchorPoint(0.5, 0.5)
			item:SetIsUseStepCalc(self.is_use_step_calc)
			if nil ~= self.ui_config then
				item:SetUiConfig(self.ui_config, false)
			end
			table.insert(self.items, item)
			self.view:addChild(item:GetView())
			
			item:AddClickEventListener(BindTool.Bind2(self.OnItemClickCallback, self, item))
		end
	end
	
	if self.refresh_is_asc then						-- 升序刷新
		for i = 1, data_count, 1 do
			self.items[i]:SetIndex(i)
			self.items[i]:SetVisible(true)
			self.items[i]:SetData(self.data_list[i])
		end
	else
		for i = data_count, 1, - 1 do
			self.items[i]:SetIndex(i)
			self.items[i]:SetVisible(true)
			self.items[i]:SetData(self.data_list[i])
		end
	end
	
	self:RefreshPosition()
end

-- 排位置
function BagGridScroll:RefreshPosition()
	if self.line_count <= 0 then
		return
	end
	local data_count = #self.data_list
	
	local size = self.view:getContentSize()
	local inner_size = cc.size(size.width, size.height)
	
	if self.direction == ScrollDir.Vertical then
		local line = math.ceil(data_count / self.line_count)
		inner_size.height = line * self.line_dis
		if inner_size.height < size.height then
			inner_size.height = size.height
		end
		local item_w = size.width / self.line_count
		
		for i = 1, data_count, 1 do
			local x =((i - 1) % self.line_count) * item_w + item_w / 2
			local y =(inner_size.height + 12) -(math.floor((i - 1) / self.line_count) * self.line_dis + self.line_dis / 2)	-- 特殊处理y向上偏移了12
			self.items[i]:SetPosition(x, y)
		end
	else
		local line = math.ceil(data_count / self.line_count)
		inner_size.width = line * self.line_dis
		if inner_size.width < size.width then
			inner_size.width = size.width
		end
		local item_h = size.height / self.line_count
		
		for i = 1, data_count, 1 do
			local x = math.floor((i - 1) / self.line_count) * self.line_dis + self.line_dis / 2
			local y = size.height -(((i - 1) % self.line_count) * item_h + item_h / 2)
			self.items[i]:SetPosition(x, y)
		end
	end
	
	self.view:setInnerContainerSize(inner_size)
end
--------------------------------------------------------
