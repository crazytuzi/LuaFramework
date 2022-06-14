-- 商店

function packetHandlerSyncShop()
	local tempArrayCount = 0;
	local diamondRefreshCount = nil;
	local refreshTime = nil;
	local shopType = nil;
	local shopItems = {};

-- 钻石刷新次数
	diamondRefreshCount = networkengine:parseInt();
-- 上次刷新时间
	refreshTime = networkengine:parseUInt64();
-- 商店类型
	shopType = networkengine:parseInt();
-- player的Shop信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		shopItems[i] = ParseShopItemInfo();
	end

	SyncShopHandler( diamondRefreshCount, refreshTime, shopType, shopItems );
end

