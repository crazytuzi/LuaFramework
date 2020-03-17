--[[
随身商店 回购面板
lizhuangzhuang
2014年12月6日16:30:49
]]

_G.UIShopCarryOnBuyBack = BaseUI:new("UIShopCarryOnBuyBack");

function UIShopCarryOnBuyBack:Create()
	self:AddSWF("shopCarryOnBuyBack.swf",true,nil);
end

function UIShopCarryOnBuyBack:OnLoaded(objSwf)
	objSwf.list.itemClick     = function(e) self:OnBuyBackItemClick(e); end
	objSwf.list.itemRClick    = function(e) self:OnBuyBackItemRClick(e); end
	objSwf.list.iconRollOver  = function(e) self:OnBuyBackIconRollOver(e); end
	objSwf.list.iconRollOut   = function()  self:OnBuyBackIconRollOut(); end
	objSwf.list.moneyRollOver = function(e) self:OnBuyBackMoneyRollOver(e); end
	objSwf.list.moneyRollOut  = function()  self:OnBuyBackMoneyRollOut(); end
	--
	objSwf.txtInfo.text = StrConfig['shop402'];
end

function UIShopCarryOnBuyBack:OnShow()
	self:ShowList();
end

function UIShopCarryOnBuyBack:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	for i=1,ShopConsts.NumIn1Page do
		local vo = ShopModel.buyBackList[i];
		if vo then
			objSwf.list.dataProvider:push(vo:GetUIData());
		else
			objSwf.list.dataProvider:push("");
		end
	end
	objSwf.list:invalidateData();
end

function UIShopCarryOnBuyBack:OnBuyBackItemClick(e)
	local cid = e.item.cid;
	local vo = ShopModel:GetBuyBackItem(cid);
	if not vo then return; end
	if ShopUtils:GetMoneyByType(enAttrType.eaBindGold) < vo:GetPrice() then
		FloatManager:AddNormal( StrConfig['shop302'] );
		return;
	end
	local itemCfg = vo:GetCfg();
	if not itemCfg then return; end
	local itemId = vo:GetTid()
	local maxPile = itemCfg.repeats or 1; --最大堆叠
	local bagVO = BagModel:GetBag( BagConsts.BagType_Bag );
	local bagSizeRest = bagVO:GetSize() - bagVO:GetUseSize(); --背包剩余格子数量
	local itemBagSize = bagVO:GetItemUsedSize( itemId );
	local numItem = BagModel:GetItemNumInBag( itemId );
	local numCanPile = itemBagSize * maxPile - numItem;
	local maxNum = maxPile * bagSizeRest + numCanPile;
	if vo.count > maxNum then
		FloatManager:AddNormal( StrConfig['shop301'] );
		return;
	end
	ShopController:ReqBuyBack(cid);
end

function UIShopCarryOnBuyBack:OnBuyBackItemRClick(e)
	local cid = e.item and e.item.cid;
	if not cid then return; end
	ShopController:ReqBuyBack(cid);
end

function UIShopCarryOnBuyBack:OnBuyBackIconRollOver(e)
	local target = e.renderer;
	local cid = e.item.cid;
	local vo = ShopModel:GetBuyBackItem(cid);
	if not vo then return; end
	local itemTipsVO = vo:GetTipsVO();
	if not itemTipsVO then return; end
	TipsManager:ShowTips( itemTipsVO.tipsType, itemTipsVO, itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown );
end

function UIShopCarryOnBuyBack:OnBuyBackIconRollOut()
	TipsManager:Hide();
end

function UIShopCarryOnBuyBack:OnBuyBackMoneyRollOver(e)
	local target = e.renderer;
 	TipsManager:ShowBtnTips( ShopUtils:GetMoneyNameByType(enAttrType.eaBindGold) );
end

function UIShopCarryOnBuyBack:OnBuyBackMoneyRollOut()
	TipsManager:Hide();
end

function UIShopCarryOnBuyBack:ListNotificationInterests()
	return { NotifyConsts.BuyBackListRefresh };
end

function UIShopCarryOnBuyBack:HandleNotification(name, body)
	if not self.bShowState then return; end
	if name == NotifyConsts.BuyBackListRefresh then
		self:ShowList();
	end
end

