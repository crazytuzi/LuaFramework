--[[
兑换商店
2015年11月11日15:26:22
haohu
]]

_G.UIShopExchange = BaseUI:new("UIShopExchange")

function UIShopExchange:Create()
	self:AddSWF("shopExchange.swf", true, "center")
end

function UIShopExchange:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	objSwf.list.iconRollOver = function(e) self:OnIconRollOver(e) end
	objSwf.list.iconRollOut = function(e) self:OnIconRollOut(e) end
	objSwf.list.btnBuyClick = function(e) self:OnBtnBuyClick(e) end
	objSwf.list.btnCostRollOver = function(e) self:OnBtnCostRollOver(e) end
	objSwf.list.btnCostRollOut = function(e) self:OnBtnCostRollOut(e) end
end

function UIShopExchange:OnShow()
	self:UpdateShow()
end

function UIShopExchange:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local shopList = ShopModel:GetExchangeShop()
	objSwf.list.dataProvider:cleanUp()
	for _, shopVO in ipairs(shopList) do
		objSwf.list.dataProvider:push( shopVO:GetUIData() )
	end
	objSwf.list:invalidateData()
end

function UIShopExchange:OnHide()
	-- body
end

function UIShopExchange:IsTween()
	return true;
end

function UIShopExchange:GetPanelType()
	return 1;
end

function UIShopExchange:IsShowSound()
	return true;
end

function UIShopExchange:OnBtnCloseClick()
	self:Hide()
end

function UIShopExchange:OnIconRollOver(e)
	local target = e.renderer;
	local id = e.item.id;
	local cfg = t_shop[id];
	if not cfg then return; end
	local shopVO = ShopUtils:CreateShopVO( id )
    TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown,shopVO:GetBind());
end

function UIShopExchange:OnIconRollOut(e)
	TipsManager:Hide()
end

function UIShopExchange:OnBtnBuyClick(e)
	local id = e.item.id
	if not id then return end
	UIShopBuyConfirm:Open(id, ShopConsts.Policy_Single)
end

function UIShopExchange:OnBtnCostRollOver(e)
	local id = e.item.id2
	if not id then return end
	TipsManager:ShowItemTips(id);
end

function UIShopExchange:OnBtnCostRollOut(e)
	TipsManager:Hide()
end
---------------------------消息处理---------------------------------
--监听消息列表
function UIShopExchange:ListNotificationInterests()
	return {
		NotifyConsts.BagItemNumChange,
	};
end

--处理消息
function UIShopExchange:HandleNotification(name, body)
	if name == NotifyConsts.BagItemNumChange then
		self:UpdateShow()
	end
end


