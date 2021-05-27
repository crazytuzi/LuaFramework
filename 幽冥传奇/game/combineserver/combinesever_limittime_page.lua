CombineServerLimitTimeShopPage = CombineServerLimitTimeShopPage or BaseClass()


function CombineServerLimitTimeShopPage:__init()
	self.shop_grid_list = nil
end	

function CombineServerLimitTimeShopPage:__delete()
	if self.shop_grid_list ~= nil then
		self.shop_grid_list:DeleteMe()
		self.shop_grid_list = nil 
	end
	self:RemoveEvent()
end	

--初始化页面接口
function CombineServerLimitTimeShopPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.page_index = 1
	self:CreateGrid()
	self:InitEvent()
	
end	

function CombineServerLimitTimeShopPage:CreateGrid()
	local data = CombineServerData.Instance:GetLimitBuyShopItem() or {}
	local count = #data ~=0 and #data or 3
	if self.shop_grid_list == nil then
		self.shop_grid_list = BaseGrid.New()
		self.shop_grid_list:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
		local ph_baggrid = self.view.ph_list.ph_grid_list
		local grid_node = self.shop_grid_list:CreateCells({ w = ph_baggrid.w, h = ph_baggrid.h, cell_count = count, col = 3, row =1, itemRender = ShopRender, direction = ScrollDir.Horizontal ,ui_config = self.view.ph_list.ph_list_item})
		grid_node:setAnchorPoint(0, 0)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.view.node_t_list["layout_limit_item"].node:addChild(grid_node, 100)
		local cur_data = {}
		for i,v in ipairs(data) do
			cur_data[i-1] = v
		end
		self.page_index = self.shop_grid_list:GetCurPageIndex()
		self.page_count = self.shop_grid_list:GetPageCount()
		self.shop_grid_list:SetDataList(cur_data)
	end
end

function CombineServerLimitTimeShopPage:OnBagPageChange(grid_view, cur_page_index, prve_page_index)
	self.page_index = cur_page_index
end

--初始化事件
function CombineServerLimitTimeShopPage:InitEvent()
	self.view.node_t_list["btn_left"].node:addClickEventListener(BindTool.Bind(self.MoveLeft, self))
	self.view.node_t_list["btn_right"].node:addClickEventListener(BindTool.Bind(self.MoveRight, self))
end

--移除事件
function CombineServerLimitTimeShopPage:RemoveEvent()
	
end

--更新视图界面
function CombineServerLimitTimeShopPage:UpdateData(data)
	self.view.node_t_list["btn_left"].node:setVisible(self.page_index ~= 1)
	self.view.node_t_list["btn_right"].node:setVisible(self.page_count > 1)
	local data = CombineServerData.Instance:GetLimitBuyShopItem() or {}
	local cur_data = {}
	for i,v in ipairs(data) do
		cur_data[i-1] = v
	end
	self.shop_grid_list:SetDataList(cur_data)
end	

function CombineServerLimitTimeShopPage:MoveLeft()
	if self.page_index > 1 then
		self.page_index = self.page_index - 1
		self.shop_grid_list:ChangeToPage(self.page_index)
	end
end

function CombineServerLimitTimeShopPage:MoveRight()
	if self.page_index < self.page_count then
		self.page_index = self.page_index + 1
		self.shop_grid_list:ChangeToPage(self.page_index)
	end
end

ShopRender = ShopRender or BaseClass(BaseRender)
function ShopRender:__init()
	self.alert_view = nil 
end

function ShopRender:__delete()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil 
	end
	if self.alert_view ~= nil then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
end

function ShopRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell == nil then
		local ph = self.ph_list.ph_item_cell
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.cell:GetView(), 100)
	end
	XUI.AddClickEventListener(self.node_tree.btn_buy_item.node, BindTool.Bind1(self.BuyItem, self), true)
end

function ShopRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_cost_num.node:setString(self.data.consume)
	RichTextUtil.ParseRichText(self.node_tree.txt_use.node, self.data.desc, 18, COLOR3B.OLIVE)
	local  data = {item_id = self.data.item[1] and self.data.item[1].id, num =  self.data.item[1] and self.data.item[1].count, is_bind = self.data.item[1] and self.data.item[1].bind}
	self.cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item[1] and self.data.item[1].id) 
	if item_cfg == nil then
		return
	end
	self.node_tree.txt_item_name.node:setString(item_cfg.name)
	self.node_tree.txt_item_name.node:setColor(Str2C3b(string.format("%06x", item_cfg.color)))
	if self.data.state == 1 then
		self.node_tree.btn_buy_item.node:setGrey(true)
	else
		self.node_tree.btn_buy_item.node:setGrey(false)
	end
end

function ShopRender:BuyItem()
	if self.data == nil then return end
	if self.data.state == 0 then
		if self.alert_view == nil then
			self.alert_view = Alert.New()
		end
		self.alert_view:SetShowCheckBox(true)
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item[1] and self.data.item[1].id) 
		if item_cfg == nil then
			return
		end
		local txt = string.format(Language.Consign.Desc, self.data and self.data.consume or 0, string.format("%06x", item_cfg.color), item_cfg.name, self.data.item[1] and self.data.item[1].count)
		self.alert_view:SetLableString(txt)
		self.alert_view:SetOkFunc(function ()
			CombineServerCtrl.Instance:ReqLimitTimeGiftData((self.index + 1))
	  	end)
	  	self.alert_view:Open()
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CombineServerActivity.Had_Buy)
	end
end