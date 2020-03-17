--[[
圣诞对换商店商品
2015年12月23日14:46:33
haohu
]]

_G.ShopXmasExchangeVO = ShopExchangeVO:new()

function ShopXmasExchangeVO:GetItemUIData()
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
	local restStr = ""
	local dayLimit = cfg.dayLimit
	if dayLimit == 0 then
		restStr = StrConfig['shop703']
	elseif dayLimit > 0 then
		local hasBuy = ShopModel:GetDayLimitItemHasBuyNum( self.id )
		local rest = dayLimit - hasBuy
		local color = rest > 0 and "#00FF00" or "#FF0000"
		restStr = string.format( StrConfig['shop702'], color, rest, dayLimit )
	end
	data.restStr = restStr
	return UIData.encode(data);
end
