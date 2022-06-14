-- 战斗配置

function sendPlan(planType, shipPlans, magicPlans)
	networkengine:beginsend(39);
-- 配置类型,见typedef的attleType
	networkengine:pushInt(planType);
-- 船的配置，见typedef的ShipPlanInfo
	local arrayLength = #shipPlans;
	if arrayLength > 6 then arrayLength = 6 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(shipPlans) do
		sendPushShipPlanInfo(v);
	end

-- 魔法的配置
	sendPushActionBar(magicPlans);
	networkengine:send();
end

