-- 船升级返回

function packetHandlerShipUpgradeResult()
	local tempArrayCount = 0;
	local index = nil;
	local level = nil;

-- 船index
	index = networkengine:parseInt();
-- 船当前等级
	level = networkengine:parseInt();

	ShipUpgradeResultHandler( index, level );
end

