------------------------------------------------------------
-- 神秘商店视图
------------------------------------------------------------
local ShopMysticalView = BaseClass(SubView)

function ShopMysticalView:__init()
	self.texture_path_list[1] = 'res/xui/shangcheng.png'
	self.config_tab = {
		{"shop_ui_cfg", 2, {0}}
	}
end

function ShopMysticalView:__delete()
end

function ShopMysticalView:ReleaseCallBack()
	if self.shop_mystical_grid then
		self.shop_mystical_grid:DeleteMe()
		self.shop_mystical_grid = nil
	end

	if self.refresh_alert then
		self.refresh_alert:DeleteMe()
		self.refresh_alert = nil
	end
	
	if self.buy_alert then
		self.buy_alert:DeleteMe()
		self.buy_alert = nil
	end
	self:CancelTimerQuest()

	if ShopData.Instance then
		ShopData.Instance:RemoveEventListener(self.listen_handle)
	end
end

function ShopMysticalView:LoadCallBack(index, loaded_times)
	--神秘商店刷新按钮监听
	XUI.AddClickEventListener(self.node_t_list.btn_re.node, BindTool.Bind(self.MyShopRefreshCallBack, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_free_re.node, BindTool.Bind(self.MyShopRefreshCallBack, self), true)

	local ph = self.ph_list.ph_myshop_list
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 2, 102, self.MysticalShopItemRender, ScrollDir.Vertical, false, self.ph_list.ph_shop_render2)
	self.shop_mystical_grid = grid_scroll
	self.shop_mystical_grid:SetSelectCallBack(BindTool.Bind1(self.SelectMyItemCallBack, self))
	self.node_t_list.layout_mystical_shop.node:addChild(grid_scroll:GetView(), 2)

	--极品预览
	-- local text = RichTextUtil.CreateLinkText(Language.Shop.BestPreview, 19, COLOR3B.GREEN, nil, true)
	-- text:setPosition(776, 21)
	-- self.node_t_list.layout_mystical_shop.node:addChild(text, 9)
	-- XUI.AddClickEventListener(text, BindTool.Bind(self.OnClickJP, self), true)
	self:CheckMyShopTimer()

	self.listen_handle = ShopData.Instance:AddEventListener(ShopData.MYSTICAL_DATA_CHANGE, BindTool.Bind(self.MysticalDataChangeCallBack, self))
end

--打开极品预览
function ShopMysticalView:OnClickJP()
	-- 设置物品预览显示索引为"商店极品预览"
	PreviewData.Instance:SetPreviewIndex(PreviewData.SHOP_PREVIEW)
	-- 打开极品预览视图
	ViewManager.Instance:OpenViewByDef(ViewDef.Preview)
end

--显示索引回调
function ShopMysticalView:ShowIndexCallBack(index)
	self:FlushShopMysticalGrid()
end

--刷新神秘商店网格
function ShopMysticalView:FlushShopMysticalGrid()
	local list = ShopData.Instance:GetMysticalShopList()
	self.shop_mystical_grid:SetDataList(list)
	self.node_t_list.lbl_sold_out.node:setVisible(list[1] == nil)
end

--神秘商店数据更改回调
function ShopMysticalView:MysticalDataChangeCallBack()
	self:CheckMyShopTimer()
	self:FlushShopMysticalGrid()
end

--检查计时器任务
function ShopMysticalView:CheckMyShopTimer()
	local left_time = ShopData.Instance:GetMyRefreLeftTime()
	self.node_t_list.layout_re.node:setVisible(left_time > 0)
	self.node_t_list.btn_free_re.node:setVisible(left_time == 0)
	if left_time > 0 then
		self:FlushMyShopLeftTime()
		if nil == self.my_shop_timer then
			self.my_shop_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.MyShopSecTime, self), 1)
		end
	else
		self:CancelTimerQuest()
	end
end

--取消计时器任务
function ShopMysticalView:CancelTimerQuest()
	GlobalTimerQuest:CancelQuest(self.my_shop_timer)
	self.my_shop_timer = nil
end

--神秘商店倒计时每秒回调
function ShopMysticalView:MyShopSecTime()
	local left_time = ShopData.Instance:GetMyRefreLeftTime()
	self:FlushMyShopLeftTime()
	if left_time == 0 then
		self:CheckMyShopTimer()
	end
end

--刷新神秘商店免费刷新剩余时间
function ShopMysticalView:FlushMyShopLeftTime()
	local left_time = ShopData.Instance:GetMyRefreLeftTime()
	self.node_t_list.txt_my_left_time.node:setString(Language.Shop.MyShopLifeTime .. TimeUtil.FormatSecond(left_time))
end

--刷新按钮点击回调
function ShopMysticalView:MyShopRefreshCallBack()
	if ShopData.Instance:GetMyRefreLeftTime() == 0 then
		self.RefreshMysticalItem()
	else
		self:ShowRefreshConfirm()
	end
end

--神秘商店元宝刷新提醒
function ShopMysticalView:ShowRefreshConfirm()
	local str = string.format(Language.Shop.AcerRefresh, 200, Language.Common.Gold)
	self.refresh_alert = self.refresh_alert or Alert.New()
	self.refresh_alert:SetShowCheckBox(true)
	self.refresh_alert:SetLableString(str)
	--发送刷新神秘商店的指令到服务端
	self.refresh_alert:SetOkFunc(self.RefreshMysticalItem)
	self.refresh_alert:Open()
end

--请求刷新神秘商店物品
function ShopMysticalView.RefreshMysticalItem()
	ShopCtrl.SendRefreshMysticalItemReq(ShopData.Instance:GetMyRefreLeftTime() == 0 and 0 or 1)
end


--神秘商店选择回调
function ShopMysticalView:SelectMyItemCallBack(item)
	self:ShowMyBuyConfirm(item)

	-- ViewManager.Instance:FlushViewByDef(ViewDef.Shop, 0, "shop_buy", {data = nil, type = nil})
end

-- 神秘商店购买确认提醒
function ShopMysticalView:ShowMyBuyConfirm(item)
	local goods = item.data.data
	local shop_cfg = item.data.shop_cfg
	local item_config = ItemData.Instance:GetItemConfig(shop_cfg.id)

	--提醒文本
	local item_color = string.format("%06x", item_config.color)
	local str = string.format(Language.Shop.BuyTips, goods.price, ShopData.GetMoneyTypeName(goods.money_type), item_color, item_config.name, shop_cfg.count)
	
	self.buy_alert = self.buy_alert or Alert.New()
	self.buy_alert:SetShowCheckBox(true)
	self.buy_alert:SetLableString(str)
	--发送购买神秘商店的指令到服务端
	self.buy_alert:SetOkFunc(function()
		ShopCtrl.SendBuyMysticalItemReq(goods.shop_id)
	end)
	self.buy_alert:Open()
end

---MysticalShopItemRender-----神秘商店物品配置
ShopMysticalView.MysticalShopItemRender = BaseClass(BaseRender)
local MysticalShopItemRender = ShopMysticalView.MysticalShopItemRender
function MysticalShopItemRender:__init()
	self.item_cell = nil
end

function MysticalShopItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.wuzhe_eff = nil
	self.tuijian_eff = nil
end

function MysticalShopItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	self.item_cell:SetCellBg(ResPath.GetShangCheng("shop_cell_bg"))
	self.item_cell:GetView():setAnchorPoint(cc.p(0.5, 0.5))
	self.view:addChild(self.item_cell:GetView(), 1)
	-- XUI.AddClickEventListener(self.node_tree.btn_buy.node, BindTool.Bind(self.OnClickBuyBtn, self), true)	

	self.wuzhe_eff = RenderUnit.CreateEffect(328, self.node_tree.layout_shop_wuzhe.node, 1,nil,nil,self.ph_list.ph_shop_discount_green.x,self.ph_list.ph_shop_discount_green.y + 8)
	self.wuzhe_eff:setVisible(false)

	self.tuijian_eff = RenderUnit.CreateEffect(329, self.node_tree.layout_shop_wuzhe.node, 1,nil,nil,self.ph_list.ph_shop_recommend.x + 20 ,self.ph_list.ph_shop_recommend.y)
	self.tuijian_eff:setVisible(false)
end

function MysticalShopItemRender:OnFlush()
	if nil == self.data then
		return
	end

	self.item_cell:SetData(ItemData.FormatItemData(self.data.shop_cfg))
	
	local item_config = ItemData.Instance:GetItemConfig(self.data.shop_cfg.id)
	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	self.node_tree.lbl_item_name.node:setString(item_config.name)
	
	local cost_path = ShopData.GetMoneyTypeIcon(self.data.data.money_type)
	self.node_tree.img_cost.node:loadTexture(cost_path)
	self.node_tree.lbl_item_cost.node:setColor(COLOR3B.GOLD)
	self.node_tree.lbl_item_cost.node:setString(self.data.data.price)

	--折扣图标显示判断
	self.node_tree.layout_shop_wuzhe.node:setVisible(self.data.data.zhekou == 5)
	self.node_tree.layout_shop_bazhe.node:setVisible(self.data.data.zhekou == 8)
	self.wuzhe_eff:setVisible(self.data.data.zhekou == 5)
	self.tuijian_eff:setVisible(self.data.data.zhekou == 5)
end

function MysticalShopItemRender:CreateSelectEffect()
	return
end

-- function MysticalShopItemRender:OnClickBuyBtn()
-- 	if nil ~= self.click_callback then
-- 		self.click_callback(self)
-- 	end
-- end

function MysticalShopItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end


return ShopMysticalView