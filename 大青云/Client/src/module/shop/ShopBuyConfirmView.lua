--[[
商店：购买确认面板
郝户
2014年11月5日18:18:41
]]

_G.UIShopBuyConfirm = BaseUI:new("UIShopBuyConfirm");

--商店商品id
UIShopBuyConfirm.shopItemId = nil;
UIShopBuyConfirm.shopVO = nil;
--默认购买数策略(最大叠加、单个购买)
UIShopBuyConfirm.numPolicy = nil;
UIShopBuyConfirm.defaultNumPolicy = ShopConsts.Policy_MaxPile; -- 默认为最大叠加

function UIShopBuyConfirm:Create()
	self:AddSWF("shopBuyConfirm.swf", true, "center" );
end

function UIShopBuyConfirm:OnLoaded( objSwf )
	objSwf.lblMaxPile.text    = UIStrConfig['shop103'];
	objSwf.lblBuyNum.text     = UIStrConfig['shop104'];
	objSwf.lblTotalPrice.text = UIStrConfig['shop105'];
	
	objSwf.txtName.autoSize      = "left"
	objSwf.txtCostRough.autoSize = "left"
	objSwf.txtPrice.autoSize     = "left"
	objSwf.txtMaxPile.autoSize   = "left"
	objSwf.txtCost.autoSize      = "left"

	objSwf.btnConfirm.click      = function() self:OnBtnConfirmClick(); end
	objSwf.btnCancel.click       = function() self:OnBtnCancelClick(); end
	objSwf.btnClose.click        = function() self:OnBtnCloseClick(); end
	objSwf.icon.rollOver         = function(e) self:OnIconRollOver(e); end
	objSwf.icon.rollOut          = function() self:OnIconRollOut(); end
	-- objSwf.moneyIcon1.rollOver   = function(e) self:OnMoneyRollOver(e); end
	-- objSwf.moneyIcon1.rollOut    = function() self:OnMoneyRollOut(); end
	-- objSwf.moneyIcon2.rollOver   = function(e) self:OnMoneyRollOver(e); end
	-- objSwf.moneyIcon2.rollOut    = function() self:OnMoneyRollOut(); end
	objSwf.numericStepper.change = function(e) self:OnNsChange(e); end
end

function UIShopBuyConfirm:OnShow()
	self:UpdateShow();
end

function UIShopBuyConfirm:OnHide()
	self.shopItemId = nil;
end
function UIShopBuyConfirm:GetPanelType()
	return 0;
end
function UIShopBuyConfirm:ESCHide()
	return true;
end
function UIShopBuyConfirm:IsShowLoading()
	return true;
end
function UIShopBuyConfirm:UpdateShow()
	local objSwf = self:GetSWF();
	if not objSwf then return; end
	local shopVO = self.shopVO
	local itemName, itemColor, maxPile = shopVO:GetItemInfo()
	local price                        = shopVO:GetPrice()
	local moneyType, moneyIconURL      = shopVO:GetConsumeInfo()
	objSwf.txtName.text      = itemName;
	objSwf.txtName.textColor = itemColor;
	objSwf.txtMaxPile.text   = maxPile;
	objSwf.txtPrice.text     = t_item[moneyType].name .. ":" .. shopVO:GetPriceLabel();
	-- if moneyIconURL then
	-- 	objSwf.moneyIcon1.loader.source = moneyIconURL;
	-- 	objSwf.moneyIcon2.loader.source = moneyIconURL;
	-- else
	-- 	objSwf.moneyIcon1.loader:unload()
	-- 	objSwf.moneyIcon2.loader:unload()
	-- end
	objSwf.icon:setData( shopVO:GetIconUIData() );
	local _, maxBuyNum = self:CheckCanBuy(false); -- false为金钱不足时不提示

	local defaultNum = 0
	if not self.numPolicy then
		self.numPolicy = ShopConsts.Policy_MaxPile
	end
	if self.numPolicy == ShopConsts.Policy_MaxPile then
		defaultNum = maxPile
	elseif self.numPolicy == ShopConsts.Policy_Single then
		defaultNum = 1
	end
	local ns = objSwf.numericStepper;
	-- 为了在刚刚打开面板的时候不调ns的change，调as2 private var functions
	ns._value = math.min( defaultNum, maxBuyNum );
	ns:updateLabel();

	local cost = ns.value * price;
	local costTxtFormat = shopVO:GetCostFormat()
	objSwf.txtCost.text = string.format( costTxtFormat, cost )
	objSwf.txtCostRough.text = ShopUtils:GetCostRough(cost);
end

--点击确认
function UIShopBuyConfirm:OnBtnConfirmClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local shopVO = self.shopVO
	if not shopVO then return end
	local num = objSwf.numericStepper.value;
	if num == nil or num == 0 then
		FloatManager:AddNormal( StrConfig['shop201'] );
		return;
	end
	if not self.shopItemId then return end;
	if not self:CheckCanBuy() then return; end
	shopVO:DoBuy(num)
	self:Hide();
end

--点击取消
function UIShopBuyConfirm:OnBtnCancelClick()
	self:Hide();
end

--点击关闭
function UIShopBuyConfirm:OnBtnCloseClick()
	self:Hide();
end

--鼠标悬浮图标
function UIShopBuyConfirm:OnIconRollOver(e)
	local shopVO = self.shopVO
	local cfg = shopVO:GetCfg()
    TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown,shopVO:GetBind());
end

--鼠标滑离图标
function UIShopBuyConfirm:OnIconRollOut()
	TipsManager:Hide();
end

--鼠标悬浮货币图标
function UIShopBuyConfirm:OnMoneyRollOver(e)
	local shopVO = self.shopVO
	shopVO:ShowConsumeTips()
end

--鼠标滑离货币图标
function UIShopBuyConfirm:OnMoneyRollOut()
	TipsManager:Hide();
end

--变更购买数目ns
function UIShopBuyConfirm:OnNsChange(e)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	local shopVO = self.shopVO
	if not shopVO then return end
	local ns = e.target;
	if ns.value ~= 0 then
		local canBuy, maxBuyNum = self:CheckCanBuy();
		if not canBuy then
			ns._value = maxBuyNum;
			ns:updateLabel();
		end
	end
	local num = ns.value;
	local price = shopVO:GetPrice()
	local cost = num * price;
	local costTxtFormat = shopVO:GetCostFormat()
	objSwf.txtCost.text = string.format( costTxtFormat, cost )
	objSwf.txtCostRough.text = ShopUtils:GetCostRough(cost);
end

--检查可否购买，不能购买弹出原因
--@param prompt:Boolen 为true时，提示不能购买原因,默认为true
function UIShopBuyConfirm:CheckCanBuy(prompt)
	if nil == prompt then
		prompt = true
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local shopVO = self.shopVO
	if not shopVO then return end
	local num = objSwf.numericStepper.value or 1
	local canBuy, maxBuyNum, bottleneck, moneyType = ShopUtils:CheckCanBuy( self.shopItemId, num );
	if prompt and not canBuy then
		moneyType = moneyType or ""
		if bottleneck == ShopConsts.ReasonAfford and StrConfig['shopnotice' .. moneyType] then
			FloatManager:AddNormal(StrConfig['shopnotice' ..moneyType])
		else
			FloatManager:AddNormal( string.format( shopVO:GetPrompt(bottleneck), maxBuyNum ), objSwf.numericStepper );
		end
	end
	return canBuy, maxBuyNum;
end

-----------------------------------------------------------------------------------

--@param id: 商品Id,对应t_shop id
function UIShopBuyConfirm:Open(id, numPolicy)
	if id == nil then
		print( "error, shop id is nil when open UIShopBuyConfirm" )
		print( debug.traceback() )
		return
	end
	if self:IsShow() and self.shopItemId == id then
		self:Top();
		return
	end
	self.shopItemId = id;
	self.shopVO = ShopUtils:CreateShopVO(id)
	self.numPolicy = numPolicy;
	if not self:IsShow() then
		self:Show();
	else
		self:UpdateShow();
		self:Top();
	end
end