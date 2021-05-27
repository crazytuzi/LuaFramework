SpecialRingView = SpecialRingView or BaseClass(XuiBaseView)

function SpecialRingView:__init()
	self.texture_path_list[1] = "res/xui/fuben.png"
	self.texture_path_list[2] = "res/xui/funcnote.png"
	self.config_tab = {
						{"itemtip_ui_cfg", 15, {0}},
					}
end

function SpecialRingView:__delete()
end

function SpecialRingView:ReleaseCallBack()
	if self.alert_window ~= nil then
		self.alert_window:DeleteMe()
		self.alert_window = nil 
	end
end

function SpecialRingView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.layout_btn.node, BindTool.Bind1(self.ClickBuyGift, self))
		XUI.AddClickEventListener(self.node_t_list.img_bg.node, BindTool.Bind1(self.OpenTips, self))
		self.buy_info_change_evt = GlobalEventSystem:Bind(ShopEventType.FAST_SHOP_DATA_UPDATE, BindTool.Bind(self.CheckNeedClose, self))
	end
end


function SpecialRingView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function SpecialRingView:OpenCallBack()
	
end

function SpecialRingView:CloseCallBack()
	
end

function SpecialRingView:OnFlush(param_t, index)

end

function SpecialRingView:CheckNeedClose()
	local item_data = ShopData.Instance:GetShopOneItemData(2, 4381)
	if not item_data then return end
	if item_data.need_del == true then
		self:Close()
	end
end

function SpecialRingView:ClickBuyGift()
	if self.alert_window == nil then
		self.alert_window = Alert.New()
		self.alert_window:SetOkFunc(BindTool.Bind2(self.ClickBuy, self))
	end
	local shop_data = ShopData.Instance:GetItemCfg(2, 4381)
	local price = shop_data and shop_data.price and shop_data.price[1] and shop_data.price[1].price or 1000
	local item_cfg = ItemData.Instance:GetItemConfig(4381)
	if item_cfg == nil then return end
	local name = item_cfg.name 
	local color = string.format("%06x", item_cfg.color)
	local txt = string.format(Language.Fuben.Desc, price, color, name)
	self.alert_window:SetLableString(txt)
	self.alert_window:Open()	
end

function SpecialRingView:OpenTips()
	local data = {item_id = 4381, num = 1, is_bind = 0}
	TipsCtrl.Instance:OpenItem(data, EquipTip.FROME_BROWSE_ROLE, {not_compare = true})
end

function SpecialRingView:ClickBuy()
	local shop_data = ShopData.Instance:GetItemCfg(2, 4381)
	if shop_data then
		ShopCtrl.BuyItemFromStore(shop_data.id, 1, shop_data.item, 1)
	end
end
