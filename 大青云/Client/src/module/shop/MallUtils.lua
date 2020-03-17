--[[
商城Util
lizhuangzhuang
2014年12月4日10:40:54
]]

_G.MallUtils = {};

--获取在商城中使用元宝可购买的物品数量(自动购买,不计算进背包)
function MallUtils:GetMoneyShopMaxNum(itemId)
	local shopId = MallUtils:GetMoneyShop(itemId);
	if shopId == 0 then
		return 0;
	end
	return ShopUtils:GetMaxBuyNum(shopId, {1}); --{1}表示不计算背包是否足够
end

--根据物品id从元宝商店获取物品
function MallUtils:GetMoneyShop(itemId)
	for i,shopVO in ipairs(ShopModel.autoBuyMoneyList) do
		local cfg = shopVO:GetCfg();
		if cfg and cfg.itemId==itemId then
			return shopVO.id;
		end
	end
	return 0;
end

--根据商品id从绑元商店获取物品
function MallUtils:GetBindMoneyShop(itemId)
	for i,shopVO in ipairs(ShopModel.autoBuyBindMoneyList) do
		local cfg = shopVO:GetCfg();
		if cfg and cfg.itemId==itemId then
			return shopVO.id;
		end
	end
	return 0;
end