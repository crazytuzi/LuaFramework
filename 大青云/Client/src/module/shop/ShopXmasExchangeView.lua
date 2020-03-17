--[[
圣诞兑换商店
2015年12月22日14:52:21
haohu
]]

_G.UIShopXmasExchange = BaseUI:new("UIShopXmasExchange")

function UIShopXmasExchange:Create()
	self:AddSWF("shopXmasExchange.swf", true, "center")
end

function UIShopXmasExchange:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	objSwf.list.iconRollOver = function(e) self:OnIconRollOver(e) end
	objSwf.list.iconRollOut = function(e) self:OnIconRollOut(e) end
	objSwf.list.btnBuyClick = function(e) self:OnBtnBuyClick(e) end
	objSwf.list.btnCostRollOver = function(e) self:OnBtnCostRollOver(e) end
	objSwf.list.btnCostRollOut = function(e) self:OnBtnCostRollOut(e) end
end

function UIShopXmasExchange:OnShow()
	self:UpdateShow()
end

function UIShopXmasExchange:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local shopList = ShopModel:GetXmasExchangeShop()
	objSwf.list.dataProvider:cleanUp()
	for _, shopVO in ipairs(shopList) do
		objSwf.list.dataProvider:push( shopVO:GetUIData() )
	end
	objSwf.list:invalidateData()
end

function UIShopXmasExchange:OnHide()
	-- body
end

function UIShopXmasExchange:IsTween()
	return true;
end

function UIShopXmasExchange:GetPanelType()
	return 1;
end

function UIShopXmasExchange:IsShowSound()
	return true;
end

function UIShopXmasExchange:OnBtnCloseClick()
	self:Hide()
end

function UIShopXmasExchange:OnIconRollOver(e)
	local target = e.renderer;
	local id = e.item.id;
	local cfg = t_shop[id];
	if not cfg then return; end
	local shopVO = ShopUtils:CreateShopVO( id )
    TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown,shopVO:GetBind());
end

function UIShopXmasExchange:OnIconRollOut(e)
	TipsManager:Hide()
end

function UIShopXmasExchange:OnBtnBuyClick(e)
	local id = e.item.id
	if not id then return end
	UIShopBuyConfirm:Open(id, ShopConsts.Policy_Single)
end

function UIShopXmasExchange:OnBtnCostRollOver(e)
	local id = e.item.id2
	if not id then return end
	TipsManager:ShowItemTips(id);
end

function UIShopXmasExchange:OnBtnCostRollOut(e)
	TipsManager:Hide()
end
---------------------------消息处理---------------------------------
--监听消息列表
function UIShopXmasExchange:ListNotificationInterests()
	return {
		NotifyConsts.BagItemNumChange,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.HasBuyListRefresh,
	};
end

--处理消息
function UIShopXmasExchange:HandleNotification(name, body)
	if name == NotifyConsts.BagItemNumChange then
		self:UpdateShow()
	elseif name == NotifyConsts.HasBuyListRefresh then
		self:UpdateShow()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaZhenQi then
			self:UpdateShow()
		end
	end
end

