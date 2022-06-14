-- 商店购买物品

function sendShopBuyItem(position, shopType)
	networkengine:beginsend(58);
-- 商店里的位置
	networkengine:pushInt(position);
-- 商店类型
	networkengine:pushInt(shopType);
	networkengine:send();
end

