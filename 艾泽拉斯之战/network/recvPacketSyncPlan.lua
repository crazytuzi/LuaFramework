-- 战斗配置

function packetHandlerSyncPlan()
	local tempArrayCount = 0;
	local planType = nil;
	local shipPlans = {};
	local magicPlans = {};

-- 配置类型,见typedef的attleType
	planType = networkengine:parseInt();
-- 船的配置，见typedef的ShipPlanInfo
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		shipPlans[i] = ParseShipPlanInfo();
	end
-- 魔法的配置
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		magicPlans[i] = networkengine:parseInt();
	end

	SyncPlanHandler( planType, shipPlans, magicPlans );
end

