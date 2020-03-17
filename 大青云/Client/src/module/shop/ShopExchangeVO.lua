--[[
对换商店商品
2015年11月11日17:20:40
haohu
]]

_G.ShopExchangeVO = ShopVO:new()

function ShopExchangeVO:GetPlayerMoney()
	local cfg = self:GetCfg();
	if not cfg then return 0 end
	local itemId = cfg.moneyType

	--这是单独判断万炎灵石
	if itemId == 140632001 then 
		return EquipBuildUtil:GetBindStateItemNumInBag(itemId,0)
	end;

	--这是单独判断灵力
	if itemId == enAttrType.eaZhenQi then
		return ShopUtils:GetMoneyByType(itemId)
	end;

	return BagModel:GetItemNumInBag(itemId)
end

function ShopExchangeVO:GetPriceLabel()
	local needItemId = self:GetConsumeInfo()
	local needItemName = ShopUtils:GetItemNameById( needItemId )
	local needNum = self:GetPrice()
	return string.format("%s×%s", needItemName, needNum)
end

function ShopExchangeVO:GetCostFormat()
	local needItemId = self:GetConsumeInfo()
	local needItemName = ShopUtils:GetItemNameById( needItemId )
	return needItemName  .. "×%s"
end

function ShopExchangeVO:GetPrompt(bottleneck)
	if bottleneck == ShopConsts.ReasonAfford then
		return StrConfig['shop208']
	end
	return ShopConsts.MaxBuyMap[bottleneck]
end

function ShopExchangeVO:GetConsumeInfo()
	local cfg = self:GetCfg()
	if not cfg then return end
	local needItemId = cfg.moneyType; --物品id
	local moneyIconURL = nil
	return needItemId, moneyIconURL
end

function ShopExchangeVO:ShowConsumeTips()
	local itemId, _ = self:GetConsumeInfo()
	if not itemId then return; end
    TipsManager:ShowItemTips(itemId)
end

function ShopExchangeVO:GetItemUIData()
	local data = {};
	data.id = self.id;
	local cfg = self:GetCfg();
	data.nameColor = ShopUtils:GetItemQualityColor(cfg.itemId);
	data.name = string.format("%s×%s", ShopUtils:GetItemNameById(cfg.itemId), cfg.itemNum )
	local id2 = cfg.moneyType
	local num2 = cfg.price
	data.id2 = id2
	local color2 = self:GetPlayerMoney(id2) >= num2 and "#00FF00" or "#FF0000"
	data.name2 = string.format( StrConfig['shop701'], color2, ShopUtils:GetItemNameById(id2), num2 );
	return UIData.encode(data);
end

function ShopExchangeVO:DoBuy(num)
	ShopController:ReqExchangeItem( self.id, num );
end