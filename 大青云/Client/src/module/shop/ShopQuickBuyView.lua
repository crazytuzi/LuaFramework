--[[
快捷购买面板(物品获得建议)
郝户
2014年11月7日17:23:54
]]

_G.UIShopQuickBuy = BaseUI:new("UIShopQuickBuy");

--物品对应的两个商品id，分别对应元宝和绑元
UIShopQuickBuy.shopIdMoney     = nil;
UIShopQuickBuy.shopIdBindMoney = nil;

--当前选择的商品id
UIShopQuickBuy.currentShopId = 0;
--面板跟随
UIShopQuickBuy.uiPanel    = nil;
UIShopQuickBuy.container  = nil;

function UIShopQuickBuy:Create()
	self:AddSWF( "shopQuickBuy.swf", true, nil );
end

function UIShopQuickBuy:OnLoaded( objSwf )
	objSwf.btnClose.click  = function() self:OnBtnCloseClick(); end
	objSwf.btnMax.click    = function() self:OnBtnMaxClick(); end
	objSwf.btnBuy.click    = function() self:OnBtnBuyClick(); end
	objSwf.btnCharge.click = function() self:OnBtnChargeClick(); end
	objSwf.icon.rollOver   = function(e) self:OnIconRollOver(e); end
	objSwf.icon.rollOut    = function() self:OnIconRollOut(); end
	objSwf._buttonGroup_money.change = function(e) self:OnMoneyTypeChange(e); end
	objSwf.ns.change = function(e) self:OnNsChange(e); end

	objSwf.txtFromStore.text = StrConfig['shop105'];
	objSwf.txtFromOther.text = StrConfig['shop106'];
	objSwf.rbMoney.icon      = ResUtil:GetMoneyIconURL( enAttrType.eaUnBindMoney );
	objSwf.rbBindMoney.icon  = ResUtil:GetMoneyIconURL( enAttrType.eaBindMoney );
end

function UIShopQuickBuy:OnShow()
	self:UpdateShow();
	if self.funcWhenShow then
		self.funcWhenShow();
		self.funcWhenShow = nil
	end
end

function UIShopQuickBuy:DeleteWhenHide()
	return true;
end

function UIShopQuickBuy:OnHide()
	self.uiPanel:RemoveChild("shopQuickBuy");
	self.uiPanel    = nil;
	self.container  = nil;
	if self.funcWhenHide then
		self.funcWhenHide();
		self.funcWhenHide = nil
	end
end

function UIShopQuickBuy:OnDelete()
	self.uiPanel = nil;
	self.container = nil;
end

function UIShopQuickBuy:DoResize(nWidth,nHeight)
	if not self.bShowState then return; end
	if not self.uiPanel then self:AutoSetPos(); end
	self:OnResize(nWidth,nHeight);
end

function UIShopQuickBuy:UpdateShow()
	self.currentShopId = self.shopIdMoney;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local shopCfg = ShopUtils:GetShopCfg( self.currentShopId );
	if not shopCfg then return; end
	-- 物品信息
	local itemCfg = ShopUtils:GetItemCfg( self.currentShopId );
	if not itemCfg then return; end
	objSwf.txtName.textColor = ShopUtils:GetItemQualityColor( shopCfg.itemId ); -- 物品品质颜色
	objSwf.txtName.text = itemCfg.name;
	objSwf.txtMaxPile.htmlText = string.format( StrConfig['shop101'], itemCfg.repeats );
	-- 图标
	local shopVO = ShopVO:new();
	shopVO.id = self.currentShopId;
	objSwf.icon:setData(shopVO:GetIconUIData());
	-- 货币类型初始为元宝
	local moneyIconUrl = ResUtil:GetMoneyIconURL( enAttrType.eaUnBindMoney );
	objSwf.rbMoney.data = self.currentShopId;
	if self.shopIdBindMoney == 0 then
		objSwf.rbBindMoney.visible = false;
	else
		objSwf.rbBindMoney.visible = true;
		objSwf.rbBindMoney.data    = self.shopIdBindMoney;
	end
	objSwf.rbMoney.selected    = true;
	objSwf.moneyLoader1.source = moneyIconUrl;
	objSwf.moneyLoader2.source = moneyIconUrl;
	-- 最大购买数
	local ns = objSwf.ns;
	ns._value = self.defBuyNum;
	ns:updateLabel();
	-- 价格
	self:UpdatePrice();
end

--更新价格显示：金钱足够时价钱/总价文本显示白色，不足则显示红色
function UIShopQuickBuy:UpdatePrice()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local shopId = self.currentShopId;
	if not shopId then return; end;
	local num = objSwf.ns.value;
	local shopCfg = ShopUtils:GetShopCfg( self.currentShopId );
	if not shopCfg then return; end
	-- 货币类型图标
	local moneyType = shopCfg.moneyType;
	if not moneyType then return; end
	local price = shopCfg.price;
	-- 价格
	local txtPrice = objSwf.txtPrice;
	local txtPriceTotal = objSwf.txtPriceTotal;
	txtPrice.text = price;
	txtPriceTotal.text = price * num;
	local canBuy, _, bottleneck = ShopUtils:CheckCanBuy(shopId, num);
	if not canBuy and bottleneck == ShopConsts.ReasonAfford then
		txtPriceTotal.textColor = 0xcc0000;
	else
		txtPriceTotal.textColor = 0xffffff;
	end
end

function UIShopQuickBuy:OnBtnCloseClick()
	self:Hide();
end

function UIShopQuickBuy:OnBtnMaxClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;
	local maxBuyNum = ShopUtils:GetMaxBuyNum( self.currentShopId );
	if maxBuyNum == ns.value then
		FloatManager:AddNormal( StrConfig['shop102'] );
	else
		ns.value = ShopUtils:GetMaxBuyNum( self.currentShopId );
	end
end

-- 购买
function UIShopQuickBuy:OnBtnBuyClick()
	if not self.currentShopId then return; end
	if not self.objSwf then return; end
	local num = self.objSwf.ns.value;
	if num == 0 then
		FloatManager:AddNormal( StrConfig['shop201'] );
		return;
	end
	if not self:CheckCanBuy() then return; end
	ShopController:ReqBuyItem( self.currentShopId, num );
end

-- 充值
function UIShopQuickBuy:OnBtnChargeClick()
	
end

function UIShopQuickBuy:OnIconRollOver(e)
	local target = e.target;
	local cfg = t_shop[self.shopIdMoney];
	if not cfg then return; end
	local shopVO = ShopVO:new();
	shopVO.id = self.shopIdMoney;
    TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown,shopVO:GetBind());
end

function UIShopQuickBuy:OnIconRollOut()
	TipsManager:Hide();
end

function UIShopQuickBuy:OnMoneyTypeChange(e)
	if not e.data then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local shopId = e.data;
	if shopId ~= self.shopIdMoney and shopId ~= self.shopIdBindMoney then
		self.currentShopId = self.shopIdMoney;
	else
		self.currentShopId = e.data;
	end
	local shopCfg = ShopUtils:GetShopCfg( self.currentShopId );
	if not shopCfg then return; end
	-- 货币类型图标
	local moneyType = shopCfg.moneyType;
	if not moneyType then return; end
	local moneyIconUrl = ResUtil:GetMoneyIconURL( moneyType );
	objSwf.moneyLoader1.source = moneyIconUrl;
	objSwf.moneyLoader2.source = moneyIconUrl;
	-- 价格
	self:UpdatePrice();
end

function UIShopQuickBuy:OnNsChange(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = e.target;
	if ns.value ~= 0 then
		local canBuy, maxBuyNum = self:CheckCanBuy();
		if not canBuy then
			ns._value = maxBuyNum;
			ns:updateLabel();
		end
	end
	self:UpdatePrice();
end

--检查可否购买，不能购买弹出原因
function UIShopQuickBuy:CheckCanBuy()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	local canBuy, maxBuyNum, bottleneck = ShopUtils:CheckCanBuy(self.currentShopId, ns.value);
	if not canBuy then
		if bottleneck == ShopConsts.ReasonAfford then
			if self.currentShopId == self.shopIdMoney then
				FloatManager:AddNormal( StrConfig['shop103'], ns );
			else
				FloatManager:AddNormal( StrConfig['shop104'], ns );
			end
		elseif bottleneck == ShopConsts.ReasonBag then
			FloatManager:AddNormal( StrConfig['shop107'], ns );
		elseif bottleneck == ShopConsts.ReasonDayLimit then
			FloatManager:AddNormal( StrConfig['shop108'], ns );
		end
	end
	return canBuy, maxBuyNum;
end

function UIShopQuickBuy:Update( interval )
	if not self.bShowState then return; end
	if not self.uiPanel then return; end
	if not self.uiPanel:IsShow() then
		self:Hide();
		return;
	end
end

-- 必选
--@param itemId 要购买的物品id
--@param uiPanel:要跟随的面板，不传为不跟随
--@param defBuyNum:默认购买数，不传默认为1
--@param container:面板要加载进的容器
function UIShopQuickBuy:Open(itemId,uiPanel,container,defBuyNum,funcWhenShow,funcWhenHide)
	if not uiPanel then return; end
	if not container then return; end
	local shopIdMoney = MallUtils:GetMoneyShop(itemId);
	if shopIdMoney == 0 then return; end
	self.shopIdMoney     = shopIdMoney;
	self.shopIdBindMoney = MallUtils:GetBindMoneyShop(itemId);
	self.uiPanel         = uiPanel;
	self.defBuyNum       = defBuyNum or 1;
	self.container       = container;
	self.funcWhenShow    = funcWhenShow;
	self.funcWhenHide    = funcWhenHide;
	if self:IsShow() then
		if self.uiPanel==uiPanel and self.container==container then
			self:UpdateShow();
		else
			self:Hide();
			uiPanel:AddChild(self, "shopQuickBuy");
			self:SetContainer(container);
			self:Show();
		end
	else
		uiPanel:AddChild(self, "shopQuickBuy");
		self:SetContainer(container);
		self:Show();
	end
end