-- 船改造返回

function packetHandlerShipRemouldResult()
	local tempArrayCount = 0;
	local index = nil;
	local level = nil;

-- 船index
	index = networkengine:parseInt();
-- 船当前等级
	level = networkengine:parseInt();

	ShipRemouldResultHandler( index, level );
end

