FuBenXuKongShiLianView = FuBenXuKongShiLianView or BaseClass(XuiBaseView)

function FuBenXuKongShiLianView:__init()
	self:SetModal(false)
	self.can_penetrate = true
	self.texture_path_list[1] = 'res/xui/fuben.png'
	self.config_tab = {
		{"fuben_view_ui_cfg", 3, {0}},
	}
end

function FuBenXuKongShiLianView:__delete()
end

function FuBenXuKongShiLianView:ReleaseCallBack()
	if self.buy_item_list then
		self.buy_item_list:DeleteMe()
		self.buy_item_list = nil
	end
	if self.alert_window then
		self.alert_window:DeleteMe()
		self.alert_window = nil 
	end
end

function FuBenXuKongShiLianView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		local x = screen_w*3/4
		local y = screen_h/2 - 20
		self.node_t_list.layout_buy_item.node:setPosition(x, y)
		XUI.AddClickEventListener(self.node_t_list.layout_buy_item.layout_buy.btn_buy_item.node, BindTool.Bind1(self.OnBuyItem, self), true)
	end
end


function FuBenXuKongShiLianView:OpenCallBack()
	
end

function FuBenXuKongShiLianView:CloseCallBack()

end

function FuBenXuKongShiLianView:ShowIndexCallBack(index)
	self:Flush()
end

function FuBenXuKongShiLianView:OnFlush(param_t, index)
	local data = MagicCityData.Instance:GetBuyItem()
	local item_cfg = ItemData.Instance:GetItemConfig(data[1].item)
	if item_cfg == nil then
		return
	end
	self.node_t_list.layout_buy.txt_name.node:setString(item_cfg.name)
	local txt = string.format(Language.Fuben.Buy_Gold, data[1].price and data[1].price[1] and data[1].price[1].price)
	self.node_t_list.layout_buy_item.layout_buy.btn_buy_item.node:setTitleText(txt)
end

function FuBenXuKongShiLianView:OnBuyItem()
	if nil == self.alert_window then
		self.alert_window = Alert.New()
	end
	local data = MagicCityData.Instance:GetBuyItem()
	local desc = string.format(Language.Fuben.Desc_Alert, data[1].price and data[1].price[1] and data[1].price[1].price)
	self.alert_window:SetLableString(desc)
	self.alert_window:SetOkFunc(BindTool.Bind2(self.SendAgreeBuyler, self))
	self.alert_window:SetShowCheckBox(true)
	self.alert_window:Open()
end

function FuBenXuKongShiLianView:SendAgreeBuyler()
	local data = MagicCityData.Instance:GetBuyItem()
	ShopCtrl.BuyItemFromStore(data[1].id, 1, data[1].item, 1)
end
--function FuBenXuKongShiLianView:CreateItemList()
	-- if self.buy_item_list == nil then
	-- 	local ph = self.ph_list.ph_item_list
	-- 	self.buy_item_list = ListView.New()
	-- 	self.buy_item_list:Create(0, 0, ph.w, ph.h, nil, BuyItem, nil, nil, self.ph_list.ph_list_item)
	-- 	self.node_t_list.layout_buy_item.node:addChild(self.buy_item_list:GetView(), 999)
	-- 	self.buy_item_list:SetMargin(5)
	-- 	self.buy_item_list:SetItemsInterval(10)
	-- 	self.buy_item_list:SelectIndex(1)
	-- 	self.buy_item_list:GetView():setAnchorPoint(0, 0)
	-- 	self.buy_item_list:SetJumpDirection(ListView.Top)
	-- end
	--self.buy_item_list:SetDataList(MagicCityData.Instance:GetBuyItem())
--end

-- BuyItem = BuyItem or BaseClass(BaseRender)
-- function BuyItem:__init()
-- 	self.shop_cell = nil 
-- end

-- function BuyItem:__delete()
-- 	-- if self.shop_cell then
-- 	-- 	self.shop_cell:DeleteMe()
-- 	-- 	self.shop_cell = nil 
-- 	-- end
-- 
-- end

-- function BuyItem:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	-- if self.shop_cell == nil then
-- 	-- 	local ph = self.ph_list.ph_item
-- 	-- 	self.shop_cell = QianghuaEquipCell.New()
-- 	-- 	self.shop_cell:SetPosition(ph.x, ph.y)
-- 	-- 	self.shop_cell:GetView():setAnchorPoint(0, 0)
-- 	-- 	self.view:addChild(self.shop_cell:GetView(), 100)
-- 	-- end
-- 	-- XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind2(self.BuyGongJiItem, self))
-- end

-- function BuyItem:OnFlush()
-- 	-- if self.data == nil then return end 
-- 	-- local item_cfg = ItemData.Instance:GetItemConfig(self.data.item)
-- 	-- if item_cfg == nil then
-- 	-- 	return
-- 	-- end
-- 	-- self.node_tree.txt_name.node:setString(item_cfg.name)
-- 	-- local price = 
-- 	-- self.node_tree.txt_price.node:setString(price)
-- 	-- self.shop_cell:SetData({item_id = self.data.item, num = 1, is_bind = 0})
-- end

-- function BuyItem:BuyGongJiItem()
-- 	
-- end

-- function BuyItem:SendAgreeBuyler()
-- 	
-- end

-- function BuyItem:CreateSelectEffect()
-- 	-- body
-- end
