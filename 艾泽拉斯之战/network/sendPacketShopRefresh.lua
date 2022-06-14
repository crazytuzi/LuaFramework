-- 商店请求,商店刷新

function sendShopRefresh(refreshType, shopType)
	networkengine:beginsend(57);
-- 刷新类型
	networkengine:pushInt(refreshType);
-- 商店类型
	networkengine:pushInt(shopType);
	networkengine:send();
end

