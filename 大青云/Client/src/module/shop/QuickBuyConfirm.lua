--[[
	快速购买
	Author: houxudong
	Date: 2016/6/22
--]]

_G.UIQuickBuyConfirm = BaseUI:new("UIQuickBuyConfirm");

--物品对应的两个商品的id，分别对应元宝和绑元
UIQuickBuyConfirm.shopIdMoney = 0;
UIQuickBuyConfirm.shopIdBindMoney = 0;

--当前选择的商品id
UIQuickBuyConfirm.currentShopId = 0;
--当前选择的物品id
UIQuickBuyConfirm.currentItemId = 0;
--单价
UIQuickBuyConfirm.price = 0;
--默认购买数量
UIQuickBuyConfirm.defBuyNum = 1;
--选择元宝
UIQuickBuyConfirm.chooseMoney = false;
--选择绑元
UIQuickBuyConfirm.chooseBildMoney = false;
--货币类型
UIQuickBuyConfirm.moneyIconUrl = false;
UIQuickBuyConfirm.BindMoneyIconUrl = false;
-- 获取途径
UIQuickBuyConfirm.getWayNum = 0; 
-- 功能开启id
UIQuickBuyConfirm.funOpenIdList ={};
-- 独立获取途径功能开启id
UIQuickBuyConfirm.funOpenIdListTwo ={};
-- 打开源引用
UIQuickBuyConfirm.originalUIClass = nil;
-- 打开源的原有OnHide方法引用
UIQuickBuyConfirm.originalFunc = nil;
-- 元宝货币的位置
UIQuickBuyConfirm.yuanbaoCheckBoxposX      = 0
UIQuickBuyConfirm.yuanbaoCheckBoxIconposX  = 0
-- 绑元货币的位置
UIQuickBuyConfirm.bangyuanCheckBoxposX     = 0
UIQuickBuyConfirm.bangyuanCheckBoxIconposX = 0


function UIQuickBuyConfirm:Create()
	self:AddSWF("QuickBuyConfirm.swf", true, "center" );
end

function UIQuickBuyConfirm:OnLoaded( objSwf )
	objSwf.layerOne.lblPrice.text         = UIStrConfig['shop102'];
	objSwf.layerOne.lblBuyNum.text        = UIStrConfig['shop104'];
	objSwf.layerOne.lblTotalPrice.text    = UIStrConfig['shop105'];
	
	--文本框统一左对齐
	objSwf.layerOne.txtName.autoSize      = "left"
	objSwf.layerOne.txtPrice.autoSize     = "left"
	objSwf.layerOne.btnConfirm.click      = function() self:OnBtnConfirmClick(); end
	objSwf.layerOne.btnMax.click      	  = function() self:OnBtnMaxClick(); end
	objSwf.layerOne.btnClose.click        = function() self:OnBtnCloseClick(); end
	objSwf.layerOne.yuanbaoIcon.rollOver  = function() self:OnYuanbaoRollOver(); end
	objSwf.layerOne.yuanbaoIcon.rollOut   = function() self:OnYuanbaoRollOut(); end
	objSwf.layerOne.lijinIcon.rollOver    = function(e) self:OnlijinRollOver(e); end
	objSwf.layerOne.lijinIcon.rollOut     = function() self:OnlijinRollOut(); end
	objSwf.layerOne.costIcon.rollOver     = function() self:OnCostIconRollOver(); end
	objSwf.layerOne.costIcon.rollOut      = function() self:OnCostIconRollOut(); end
	objSwf.layerOne.icon.rollOver         = function() self:OnIconRollOver(); end
	objSwf.layerOne.icon.rollOut          = function() self:OnIconRollOut(); end
	objSwf.layerOne.ns.change             = function(e) self:OnNsChange(e); end

	objSwf.layerOne.chkBoxMoney.select          = function(e) self:OnBoxMoneySelect(e) end
	objSwf.layerOne.chkBoxBilndMoney.select     = function(e) self:OnBoxBilndMoneySelect(e) end

	for i=1,5 do
		objSwf.layerOne["clickBtn"..i].click     = function() self:OnClickBtnClick(i); end
		objSwf.layerOne["clickBtn"..i].disabled  = true;
	end
	objSwf.layerTwo.btnCloseTwo.click            = function() self:OnLayerTwoBtnCloseClick(); end
	for i=1,5 do
		objSwf.layerTwo["clickBtnTwo"..i].click     = function() self:OnLayerTwoClickBtnClick(i); end
		objSwf.layerTwo["clickBtnTwo"..i].disabled  = true;
	end
    self.yuanbaoCheckBoxposX       = objSwf.layerOne.chkBoxMoney._x
    self.yuanbaoCheckBoxIconposX   = objSwf.layerOne.yuanbaoIcon._x
    self.bangyuanCheckBoxposX      = objSwf.layerOne.chkBoxBilndMoney._x
    self.bangyuanCheckBoxIconposX  = objSwf.layerOne.lijinIcon._x
end

function UIQuickBuyConfirm:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return; end
	self:CheckShow(self.currentItemId)
	self:CheckExtraBuy(self.currentItemId)
	self:UpdateShow();
end

-- 检测当前物品有没有在shop表中
function UIQuickBuyConfirm:CheckShow(itemId)
	local isInShop = false;           --是否在商店里面 
	local inShopIsCanshow = false;    --在商店里面但是是否在快速购买界面显示
	for k,v in pairs(t_shop) do
		if v.itemId == itemId then
			if v.type == 2 or v.type == 3 then
				isInShop = true;
			end
		end
	end
	local specialCfg = t_itemacquirelist[itemId];
	if not specialCfg then
		-- local str = "current itemid is in shop table， but not in itemacquirelist table"
		-- FloatManager:AddNormal(str)
		self:Hide()
		return false;
	end
	if specialCfg.judge == 1 then
		inShopIsCanshow = true;
	end
	local objSwf = self.objSwf
	if not objSwf then return false; end
	objSwf.layerOne._visible = false;
	objSwf.layerTwo._visible = false;
	--@param one 在商店里面有售卖，但是不在快速界面中显示该物品，只显示获取途径(模式2) 
	--@param two 在商店里面有售卖，快速购买界面显示模式1
	if isInShop and inShopIsCanshow then      --在shop表里面有售卖并且specialCfg.judge==1
		objSwf.layerOne._visible = true;
	else
		objSwf.layerTwo._visible = true;
		self:ShowGetPath(itemId)
	end
end

function UIQuickBuyConfirm:CheckItemId(itemId)
	-- 如果t_itemacquirelist表里面不存在不显示任何模式的快速购买
	local specialCfg = t_itemacquirelist[itemId];
	if not specialCfg then
		return false;
	end
	return true
end

function UIQuickBuyConfirm:UpdateShow()
	local objSwf = self:GetSWF()
	if not objSwf then return; end
	self.currentShopId = self.shopIdMoney;  
	self.currentShopId = self.shopIdMoney ~= 0 and self.shopIdMoney or self.shopIdBindMoney
	local shopCfg = ShopUtils:GetShopCfg(self.currentShopId);
	if not shopCfg then return; end
	-- 物品信息
	local itemCfg = ShopUtils:GetItemCfg(self.currentShopId);
	if not itemCfg then self:Hide() return; end
	objSwf.layerOne.txtName.textColor = ShopUtils:GetItemQualityColor( shopCfg.itemId ); -- 物品品质颜色
	local id = self.currentItemId;
	objSwf.layerOne.txtName.text = itemCfg.name;
	-- objSwf.layerOne.tfget.htmlText = itemCfg.from;  --该道具获取途径
	-- 图标
	local shopVO = ShopVO:new();
	shopVO.id = self.currentShopId;
	objSwf.layerOne.icon:setData(shopVO:GetIconUIData());
	-- 货币类型初始为元宝,如果有绑元初始类型为绑元
	self.moneyIconUrl = ResUtil:GetMoneyIconURL( enAttrType.eaUnBindMoney );
	self.BindMoneyIconUrl = ResUtil:GetMoneyIconURL( enAttrType.eaBindMoney );
  	objSwf.layerOne.chkBoxMoney._x       = self.yuanbaoCheckBoxposX
  	objSwf.layerOne.chkBoxMoney._visible = true
  	objSwf.layerOne.yuanbaoIcon._x       = self.yuanbaoCheckBoxIconposX
  	objSwf.layerOne.yuanbaoIcon._visible = true
  	objSwf.layerOne.chkBoxBilndMoney._x  = self.bangyuanCheckBoxposX
  	objSwf.layerOne.chkBoxBilndMoney._visible = true
  	objSwf.layerOne.lijinIcon._x         = self.bangyuanCheckBoxIconposX
  	objSwf.layerOne.lijinIcon._visible   = true
	if self.shopIdBindMoney == 0 then  -- 如果没有绑元的话，绑元不显示(显示元宝)
		objSwf.layerOne.lijinIcon.loader:unload()
		objSwf.layerOne.chkBoxBilndMoney._visible = false;
		objSwf.layerOne.lijinIcon._visible = false;
		if objSwf.layerOne.yuanbaoIcon.loader.source ~= self.moneyIconUrl then
			objSwf.layerOne.yuanbaoIcon.loader.source = self.moneyIconUrl;
		end
		if objSwf.layerOne.costIcon.loader.source ~= self.moneyIconUrl then
			objSwf.layerOne.costIcon.loader.source = self.moneyIconUrl;
		end
	else
		objSwf.layerOne.chkBoxBilndMoney._visible = true;
		if objSwf.layerOne.yuanbaoIcon.loader.source ~= self.moneyIconUrl then
			objSwf.layerOne.yuanbaoIcon.loader.source = self.moneyIconUrl;
		end
		if objSwf.layerOne.lijinIcon.loader.source ~= self.BindMoneyIconUrl then
			objSwf.layerOne.lijinIcon.loader.source = self.BindMoneyIconUrl;
		end
		if objSwf.layerOne.costIcon.loader.source ~= self.BindMoneyIconUrl then
			objSwf.layerOne.costIcon.loader.source = self.BindMoneyIconUrl;
		end
	end
	if self.shopIdMoney == 0 then       --如果没有元宝的话，元宝不显示 (显示绑元)
		objSwf.layerOne.yuanbaoIcon.loader:unload()
		objSwf.layerOne.chkBoxMoney._visible = false;
		objSwf.layerOne.yuanbaoIcon._visible = false;
		if objSwf.layerOne.lijinIcon.loader.source ~= self.BindMoneyIconUrl then
			objSwf.layerOne.lijinIcon.loader.source = self.BindMoneyIconUrl;
		end
		if objSwf.layerOne.costIcon.loader.source ~= self.BindMoneyIconUrl then
			objSwf.layerOne.costIcon.loader.source = self.BindMoneyIconUrl;
		end
		objSwf.layerOne.chkBoxBilndMoney._x = self.yuanbaoCheckBoxposX
  		objSwf.layerOne.lijinIcon._x        = self.yuanbaoCheckBoxIconposX
	else
		objSwf.layerOne.chkBoxMoney._visible = true;
		if objSwf.layerOne.yuanbaoIcon.loader.source ~= self.moneyIconUrl then
			objSwf.layerOne.yuanbaoIcon.loader.source = self.moneyIconUrl;
		end
		if objSwf.layerOne.lijinIcon.loader.source ~= self.BindMoneyIconUrl then
			objSwf.layerOne.lijinIcon.loader.source = self.BindMoneyIconUrl;
		end
		if objSwf.layerOne.costIcon.loader.source ~= self.BindMoneyIconUrl then
			objSwf.layerOne.costIcon.loader.source = self.BindMoneyIconUrl;
		end
	end

	-- 最大购买数量
	local ns = objSwf.layerOne.ns;
	self.ns = ns;
	ns._value = self.defBuyNum;
	ns:updateLabel(); -- as内更新label显示
	
	if self.shopIdBindMoney > 0 then  -- 如果有绑元，初始货币类型为绑元
		objSwf.layerOne.chkBoxMoney.selected = false;
		objSwf.layerOne.chkBoxBilndMoney.selected = true; 
		self.chooseBildMoney = true
	else
		objSwf.layerOne.chkBoxMoney.selected = true; 
		objSwf.layerOne.chkBoxBilndMoney.selected = false; 
		self.chooseMoney = true;
	end
	--价格
	self:UpdatePrice();
	self:updateCostIcon();
	
end

function UIQuickBuyConfirm:GetPanelType()
	return 0;
end

function UIQuickBuyConfirm:ESCHide()
	return true;
end
----------------------------消耗设置----------------------------
--选择元宝
function UIQuickBuyConfirm:OnBoxMoneySelect(e)
	self.chooseMoney = true;
	self.chooseBildMoney = false;
	self.ns._value = 1;
	self.ns:updateLabel();
	self:UpdatePrice();
	self:updateCostIcon();
end

--选择绑元
function UIQuickBuyConfirm:OnBoxBilndMoneySelect(e)
	self.chooseMoney = false;
	self.chooseBildMoney = true;
	self.ns._value = 1;
	self.ns:updateLabel();
	self:UpdatePrice();
	self:updateCostIcon();
end

--更新消耗icon
function UIQuickBuyConfirm:updateCostIcon( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.chooseMoney then
		if objSwf.layerOne.costIcon.loader.source ~= self.moneyIconUrl then
			objSwf.layerOne.costIcon.loader.source = self.moneyIconUrl;
		end
	elseif self.chooseBildMoney then
		if objSwf.layerOne.costIcon.loader.source ~= self.BindMoneyIconUrl then
			objSwf.layerOne.costIcon.loader.source = self.BindMoneyIconUrl;
		end
	end
end

--更新价格显示
function UIQuickBuyConfirm:UpdatePrice()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local num = objSwf.layerOne.ns.value;	
	local totalMoney = MainPlayerModel.humanDetailInfo.eaUnBindMoney   --元宝
	local totalBindMoney= MainPlayerModel.humanDetailInfo.eaBindMoney  --绑银
	local costType;
	local shopCfg;
	if self.chooseMoney then
		shopCfg = ShopUtils:GetShopCfg( self.shopIdMoney );
		costType = totalMoney
	end
	if self.chooseBildMoney then
		shopCfg = ShopUtils:GetShopCfg( self.shopIdBindMoney );
		costType = totalBindMoney
	end
	
	if not shopCfg then return; end
	self.price = shopCfg.price;   --单价
	objSwf.layerOne.txtPrice.text = self.price;
	local color = self.price * num > costType and "#FF0000" or "#C8C8C8"
	if costType == 0 then
		color = "#FF0000";
	end
	objSwf.layerOne.txtCost.htmlText = string.format(StrConfig['shop888'], color, self.price * num)
end

--最大购买
function UIQuickBuyConfirm:OnBtnMaxClick( )
	local totalMoney = MainPlayerModel.humanDetailInfo.eaUnBindMoney
	local totalBindMoney= MainPlayerModel.humanDetailInfo.eaBindMoney
	local maxNum;
	if self.chooseMoney then
		maxNum = math.floor(totalMoney / self.price)
	elseif self.chooseBildMoney then
		maxNum = math.floor(totalBindMoney / self.price)
	end
	if maxNum > 999 then
		maxNum = 999;
	elseif maxNum <= 0 then
		maxNum = 1;
	end
	self.ns._value = maxNum
	self.ns:updateLabel();
	self:UpdatePrice();
end

function UIQuickBuyConfirm:onHide( )
	self:RevertOpenSourceFunc();
	self.chooseMoney = nil;
	self.chooseBildMoney = nil;
	self.price = 0;
	self.currentShopId= 0;
	self.currentItemId = 0;
	self.shopIdMoney = 0;
	self.funOpenIdList ={};
	objSwf.layerOne.costIcon.loader.source:unload()
	objSwf.layerOne.chkBoxBilndMoney.selected = false;
	objSwf.layerOne.chkBoxMoney.selected = false;
	if self.shopIdBindMoney then
		self.shopIdBindMoney = 0;
	end
	self:disabledBtn()
end

function UIQuickBuyConfirm:disabledBtn()
	local objSwf = self.objSwf;
	if not objSwf then return ; end
	for i=1,5 do
		objSwf.layerOne["clickBtn"..i].disabled = true;
		objSwf.layerTwo["clickBtnTwo"..i].disabled = true;
		objSwf.layerOne["txtName"..i].htmlText = "";
		objSwf.layerTwo.extarBgTwo["txtName"..i].htmlText = "";
		objSwf.layerOne["icon"..i].source = {}
		objSwf.layerTwo.extarBgTwo["icon"..i].source = {}
	end
end

function UIQuickBuyConfirm:OnBtnCloseClick(  )
	self:Hide()
end

function UIQuickBuyConfirm:OnLayerTwoBtnCloseClick(  )
	self:Hide()
end

function UIQuickBuyConfirm:OnYuanbaoRollOver(e)
	TipsManager:ShowBtnTips( StrConfig['shop003']);
end

function UIQuickBuyConfirm:OnYuanbaoRollOut(  )
	TipsManager:Hide();
end

function UIQuickBuyConfirm:OnlijinRollOver(e)
	TipsManager:ShowBtnTips( StrConfig['shop004']);
end

function UIQuickBuyConfirm:OnlijinRollOut(  )
	TipsManager:Hide();
end

function UIQuickBuyConfirm:OnCostIconRollOver(  )
	if self.chooseMoney then
		TipsManager:ShowBtnTips( StrConfig['shop003']);
	else
		TipsManager:ShowBtnTips( StrConfig['shop004']);
	end
end

function UIQuickBuyConfirm:OnCostIconRollOut(  )
	TipsManager:Hide();
end

function UIQuickBuyConfirm:OnIconRollOver(  )
	local tipsDir = TipsConsts.Dir_RightUp;
	TipsManager:ShowItemTips(self.currentItemId, _ ,tipsDir)
end

function UIQuickBuyConfirm:OnIconRollOut(  )
	TipsManager:Hide();
end

--变更购买数目ns
function UIQuickBuyConfirm:OnNsChange(e)
	local objSwf = self.objSwf
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

--确认购买
function UIQuickBuyConfirm:OnBtnConfirmClick(  )
	if self.ns._value == nil or self.ns._value == 0 then
		FloatManager:AddNormal( StrConfig['shop201'] );
		return;
	end
	local num = self.ns._value 
	if self.chooseMoney then
		self.currentShopId = self.shopIdMoney
	elseif self.chooseBildMoney then
		self.currentShopId = self.shopIdBindMoney
	end
	ShopController:ReqBuyItem( self.currentShopId, num );
	self:Hide();
end

--检查可否购买，不能购买弹出原因
function UIQuickBuyConfirm:CheckCanBuy( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.layerOne.ns;
	local shopId;
	if self.chooseMoney then
		self.currentShopId = self.shopIdMoney
	elseif self.chooseBildMoney then
		self.currentShopId = self.shopIdBindMoney
	end
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
	return canBuy, maxBuyNum > 0 and maxBuyNum or 1;
end

--复选框
function UIQuickBuyConfirm:ChangeCfg( name, value )
	if self.saved == false then
		AutoBattleModel:ChangeCfg(name, value)
	else
		self.saved = not AutoBattleModel:ChangeCfg(name, value);
	end
end

function UIQuickBuyConfirm:SetOpenSourceOnHide(ui)
	if ui then
		--重置面板OnHide(采用lua元编程处理),没什么问题的话别改这里
		self.originalUIClass = ui;
		self.originalFunc = ui.OnHide;
		local metatable = {
		__call = function(s,func,index,class)
				if index and index > 0 then
					s[index or #s+1] = {assert(func),class};
				end
				if not index or index <= 0 then
					for i, f in ipairs(s) do
						if f[1](f[2])==false then break end
					end
					local i = 0
					while s[i] do
						if s[i][1](s[i][2])==false then break end
						i = i-1
					end
				end
			end
		};
		local s = setmetatable({},metatable);
		ui.OnHide = s;
		if self.originalFunc then
			ui.OnHide(self.originalFunc, 1, ui);
		end
		ui.OnHide(function()
			self:OnBtnCloseClick();
		end, 2, self);
	end
end

function UIQuickBuyConfirm:RevertOpenSourceFunc()
	local ui = self.originalUIClass;
	if ui then
		ui.OnHide = nil;
		ui.OnHide = self.originalFunc;
		self.originalFunc = nil;
		self.originalUIClass = nil;
	end
end

---------------------对外开发接口,需要快速购买功能调用改接口即可---------------------

--@param ui: 打开快速购买界面的父界面
--@param itemId: 要购买的物品id
--@param defBuyNum: 默认购买数量，不传默认为1
--@说明：其他地方调用该接口，如果返回时nil，则表示该物品不支持快速购买，故可处理自身逻辑
function UIQuickBuyConfirm:Open(ui, itemId,defBuyNum)
	self.currentItemId = itemId;
	if itemId == nil then
		print( "error, itemId is nil when open UIShopBuyConfirm" )
		return nil
	end
	if self:IsShow() and self.shopItemId == itemId then  
		self:Top()     
		return;
	end
	local shopIdMoney = MallUtils:GetMoneyShop(itemId);          -- 元宝商店
	local shopIdBindMoney = MallUtils:GetBindMoneyShop(itemId);  -- 绑元商店
	self.defBuyNum = defBuyNum or 1;
	self.shopIdMoney = shopIdMoney;
	self.shopIdBindMoney = shopIdBindMoney;
	if not self:CheckItemId(self.currentItemId) then
		self:Hide()
		return
	end
	if not self:IsShow()  then
		self:Show()
	else
		self:OnShow()
		self:UpdateShow()
		self:CheckShow(self.currentItemId)
		self:CheckExtraBuy(self.currentItemId)
		self:Top()          --确保每次点击都会打开购买界面
	end
	self:SetOpenSourceOnHide(ui);
end

--------------------------------同时支持快速购买和获取途径---------------------------

function UIQuickBuyConfirm:CheckExtraBuy( itemId)
	local cfg = t_itemacquirelist[itemId];
	if not cfg then
		-- self:IsShowExtraBg(false,{})
		self:Hide()
		-- FloatManager:AddNormal(StrConfig['shopExtra005'])
	else
		local itemWay = cfg.itemway;
		local itemwayList = split(itemWay,"#")
		if itemwayList then
			self:InitExtraBg()
			self:IsShowExtraBg(true,itemwayList)
		end
	end
end

function UIQuickBuyConfirm:InitExtraBg( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1,5 do
		objSwf.layerOne["icon"..i].source = {}
		objSwf.layerOne["icon"..i]._visible = false;
		objSwf.layerOne["txtName"..i]._visible = false
		objSwf.layerOne["clickBtn"..i]._visible = false
		objSwf.layerOne["clickBtn"..i].disabled = true
	end
end

function UIQuickBuyConfirm:InitlayerTwo( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1,5 do
		objSwf.layerTwo["clickBtnTwo"..i]._visible = false;
		objSwf.layerTwo["clickBtnTwo"..i].disabled = true;
		objSwf.layerTwo.extarBgTwo["txtName"..i]._visible = false;
		objSwf.layerTwo.extarBgTwo["icon"..i].source = {}
		objSwf.layerTwo.extarBgTwo["icon"..i]._visible = false;
	end
end

function UIQuickBuyConfirm:IsShowExtraBg( isShow,getNum)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.funOpenIdList ={};
	for i=1,#getNum do
		objSwf.layerOne["clickBtn"..i]._visible = isShow;
		objSwf.layerOne["clickBtn"..i].disabled = not isShow;
		objSwf.layerOne["txtName"..i]._visible = isShow;
		local cfg = t_itemacquireway[toint(getNum[i])];
		if not cfg then
			Debug(StrConfig['shopExtra002'])
			return;
		end
		local getName = cfg.acquirename
		local btnName = cfg.acquirebuttname
		if not btnName then
			objSwf.layerOne["clickBtn"..i]._visible = not isShow;
			objSwf.layerOne["clickBtn"..i].disabled = isShow;
		end
		local isShowImg = cfg.ifrecommend
		local imgUrl = cfg.imgUrl
		local scriptNum = cfg.scriptname    --功能id
		if scriptNum == '' then
			scriptNum = 0;
		end
		table.push( self.funOpenIdList, toint(scriptNum) )
		objSwf.layerOne["txtName"..i].htmlText = getName;
		objSwf.layerOne["clickBtn"..i].htmlLabel = btnName;
		objSwf.layerOne["icon"..i]._visible = isShow;
		if isShowImg == 1 then
			if objSwf.layerOne["icon"..i].source ~= ResUtil:GetQuicklyBuyImg(i) then
				objSwf.layerOne["icon"..i].source = ResUtil:GetQuicklyBuyImg(i)
			end
		else
			objSwf.layerOne["icon"..i].source = {}
		end
	end
end

--点击前往
function UIQuickBuyConfirm:OnClickBtnClick(index)
	if not self.funOpenIdList[index] then 
		FloatManager:AddNormal(StrConfig['shopExtra004'])
		return; 
	end
	if not FuncManager:GetFuncIsOpen(self.funOpenIdList[index]) then
		local cfg = t_funcOpen[self.funOpenIdList[index]]
		if not cfg then
			Debug("not find cfgData in t_funcOpen:",self.funOpenIdList[index])
			return
		end
		FloatManager:AddNormal(string.format(StrConfig['shopExtra007'],cfg.open_level,cfg.name))
		return
	end
	FuncManager:OpenFunc(self.funOpenIdList[index])
end

-----------------------------物品独立获取途径---------------------------------

-- 当前物品不在商店售卖，查询是否在获取途径表中
function UIQuickBuyConfirm:ShowGetPath( itemId )
	local cfg = t_itemacquirelist[itemId];
	if not cfg then
		self:Hide()
		FloatManager:AddNormal(StrConfig['shopExtra005'])
		return;
	else
		local itemWay = cfg.itemway;
		local itemwayList = split(itemWay,"#")
		if itemwayList then
			self:InitGetPathInfo(true,itemwayList)
		end
	end
end

-- 初始化获取途径信息面板
function UIQuickBuyConfirm:InitGetPathInfo( isShow,getNum)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:InitlayerTwo();
	self.funOpenIdListTwo = {};
	for i=1,#getNum do
		objSwf.layerTwo["clickBtnTwo"..i]._visible = isShow;
		objSwf.layerTwo["clickBtnTwo"..i].disabled = not isShow;
		objSwf.layerTwo.extarBgTwo["txtName"..i]._visible = isShow;
		local cfg = t_itemacquireway[toint(getNum[i])];
		if not cfg then
			Debug(StrConfig['shopExtra002'])
			return;
		end
		local getName = cfg.acquirename
		local btnName = cfg.acquirebuttname
		local isShowImg = cfg.ifrecommend
		local imgUrl = cfg.imgUrl
		local scriptNum = cfg.scriptname
		if scriptNum == '' then
			scriptNum = 0;
		end
		table.push( self.funOpenIdListTwo, toint(scriptNum) )
		if not getName or not btnName or not isShowImg then 
			Debug(StrConfig['shopExtra003'])
			return;
		end
		objSwf.layerTwo.extarBgTwo["txtName"..i].htmlText = getName;
		objSwf.layerTwo["clickBtnTwo"..i].htmlLabel = btnName;
		objSwf.layerTwo.extarBgTwo["icon"..i]._visible = isShow;
		if isShowImg == 1 then
			if objSwf.layerTwo.extarBgTwo["icon"..i].source ~= ResUtil:GetQuicklyBuyImg(i) then
				objSwf.layerTwo.extarBgTwo["icon"..i].source = ResUtil:GetQuicklyBuyImg(i);
			end
		else
			objSwf.layerTwo.extarBgTwo["icon"..i].source = {}
		end
	end
end

function UIQuickBuyConfirm:NeverDeleteWhenHide()
	return true
end

function UIQuickBuyConfirm:OnLayerTwoClickBtnClick( index )
	if not self.funOpenIdListTwo[index] then 
		FloatManager:AddNormal(StrConfig['shopExtra004'])
		return; 
	end
	if not FuncManager:GetFuncIsOpen(self.funOpenIdListTwo[index]) then
		local cfg = t_funcOpen[self.funOpenIdListTwo[index]]
		if not cfg then
			Debug("not find cfgData in t_funcOpen:",self.funOpenIdListTwo[index])
			return
		end
		FloatManager:AddNormal(string.format(StrConfig['shopExtra007'],cfg.open_level,cfg.name))
		return
	end
	FuncManager:OpenFunc(self.funOpenIdListTwo[index]);
end