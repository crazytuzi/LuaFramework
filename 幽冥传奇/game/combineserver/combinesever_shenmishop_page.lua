CombineServerMysteriousShopPage = CombineServerMysteriousShopPage or BaseClass()


function CombineServerMysteriousShopPage:__init()
end	

function CombineServerMysteriousShopPage:__delete()
	if self.mysterious_shop_grid ~= nil then
		self.mysterious_shop_grid:DeleteMe()
		self.mysterious_shop_grid = nil
	end
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.alert_flush_view ~= nil then
		self.alert_flush_view:DeleteMe()
		self.alert_flush_view = nil 
	end
	self:RemoveEvent()
end	

--初始化页面接口
function CombineServerMysteriousShopPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateItemCell()
	self:InitEvent()
end	


--初始化事件
function CombineServerMysteriousShopPage:InitEvent()
	
	self.view.node_t_list["btn_refresh"].node:addClickEventListener(BindTool.Bind(self.FlushData, self))
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self, -1),  1)
end

--移除事件
function CombineServerMysteriousShopPage:RemoveEvent()
	
end

--更新视图界面
function CombineServerMysteriousShopPage:UpdateData(data)
	local cur_data = CombineServerData.Instance:GetShenMiShopData()
	self.mysterious_shop_grid:SetDataList(cur_data)
	self:FlushTime()
end	

function CombineServerMysteriousShopPage:FlushTime()
	local time = CombineServerData.Instance:GetRemainTime() - TimeCtrl.Instance:GetServerTime()
	if time < 0 then
		if self.time >= 2 then
			return
		end
		if self.time <= 1 then
			CombineServerCtrl.Instance:RefreshItem(1, 0)
		end
		self.time = self.time + 1
	else
		local c_time = TimeUtil.FormatSecond2Str(time)
		local txt = string.format(Language.CombineServerActivity.Refreshtime, c_time)
		self.view.node_t_list.txt_refresh_time.node:setString(txt)
	end
end

function CombineServerMysteriousShopPage:CreateItemCell()
	if self.mysterious_shop_grid == nil then
		self.mysterious_shop_grid = BaseGrid.New()
		local ph_baggrid = self.view.ph_list.ph_shop_grid
		local grid_node = self.mysterious_shop_grid:CreateCells({ w = ph_baggrid.w, h = ph_baggrid.h, cell_count = 4, col = 2, row =2, itemRender = MysteriousRender, direction = ScrollDir.Horizontal ,ui_config = self.view.ph_list.ph_item_info_panel})
		grid_node:setAnchorPoint(0, 0)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.view.node_t_list.layout_mysterious_item.node:addChild(grid_node, 100)
	end
end

function CombineServerMysteriousShopPage:FlushData()
	if self.alert_flush_view == nil then
		self.alert_flush_view = Alert.New()
	end
	local data = CombineServerData.GetRefreshConsume()
	local count = data and data[1] and data[1].count or 30
	self.alert_flush_view:SetShowCheckBox(true)
	local txt = string.format(Language.CombineServerActivity.Refresh_Tips, count)
	self.alert_flush_view:SetLableString(txt)
	self.alert_flush_view:SetOkFunc(function ()
		CombineServerCtrl.Instance:RefreshItem(1, 1)
  	end)
  	self.alert_flush_view:Open()
end

MysteriousRender = MysteriousRender or BaseClass(BaseRender)

function MysteriousRender:__init()
	self.cell = nil
	self.alert_view = nil 
end

function MysteriousRender:__delete()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil 
	end
	if self.alert_view ~= nil then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
end

function MysteriousRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell == nil then
		local ph = self.ph_list.ph_item_cell
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.cell:GetView(), 100)
	end
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind1(self.BuyShopItem, self), true)
end

function MysteriousRender:OnFlush()
	self.node_tree.img_buy_bg.node:setVisible(vis)
	if self.data == nil then return end
	if self.data.cfg_data == nil then return end
	local data = {item_id = self.data.cfg_data.id, num = self.data.cfg_data.count, is_bind = self.data.cfg_data.bind}
	self.cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.cfg_data.id)
	if item_cfg == nil then
		return 
	end
	self.node_tree.lbl_item_name.node:setString(item_cfg.name)
	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	self.node_tree.lbl_item_cost.node:setString(self.data.cfg_data.price)
	self.node_tree.lbl_now_item_cost.node:setString(self.data.cfg_data.discprice)
	local path = nil 
	if self.data.cfg_data.discpriceType == 0 then
		path = ResPath.GetCommon("icon_money")
	elseif self.data.cfg_data.discpriceType == 2 then
		path = ResPath.GetCommon("bind_gold")
	elseif self.data.cfg_data.discpriceType == 3 then
		path = ResPath.GetCommon("gold")
	end
	self.node_tree.img_cost_now.node:loadTexture(path)
	local path_1 = nil
	if self.data.cfg_data.priceType == 0 then
		path_1 = ResPath.GetCommon("icon_money")
	elseif self.data.cfg_data.priceType == 2 then
		path_1 = ResPath.GetCommon("bind_gold")
	elseif self.data.cfg_data.priceType == 3 then
		path_1 = ResPath.GetCommon("gold")
	end
	self.node_tree.img_cost.node:loadTexture(path_1)
	local vis = false
	if self.data.buy_num < (self.data.cfg_data.buyNumLimit or 1) then
		self.node_tree.buyBtn.node:setGrey(false)
		vis = false
	else
		self.node_tree.buyBtn.node:setGrey(true)
		vis = true
	end
	self.node_tree.img_buy_bg.node:setVisible(vis)
	self.node_tree.img_buy_bg.node:setLocalZOrder(999)
end

function MysteriousRender:BuyShopItem()
	if self.data.buy_num < (self.data.cfg_data.buyNumLimit or 1) then
		if self.data == nil then return end
		if self.data.cfg_data == nil then return end
		if self.alert_view == nil then
			self.alert_view = Alert.New()
		end
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.cfg_data.id)
		if item_cfg == nil then
			return 
		end
		local money_name = Language.CombineServerActivity.Money_Name[self.data.cfg_data.discpriceType]
		local txt = string.format(Language.CombineServerActivity.ShenMi_Shop, money_name, self.data.cfg_data.discprice, string.format("%06x", item_cfg.color), item_cfg.name, self.data.cfg_data.count)
		self.alert_view:SetLableString(txt)
		self.alert_view:SetOkFunc(function ()
			CombineServerCtrl.Instance:BuyExtractItem(1, self.data.index)
	  	end)
	  	self.alert_view:Open()
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CombineServerActivity.Had_Buy)
	end
end
