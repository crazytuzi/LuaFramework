function CounterHandler( counter, counterArray, counterActivity)
	
	local player = dataManager.playerData
	-- 服务器下标和客户端不一致
	player.counter = counter
	player.counterArray = counterArray
    player.counterActivity = counterActivity
	
	--print("goldPurchaseTimes: "..counter[enum.COUNTER_TYPE.COUNTER_TYPE_GOLD_PURCHASE+1]);
	--print("lumberPurchaseTimes: "..counter[enum.COUNTER_TYPE.COUNTER_TYPE_LUMBER_PURCHASE+1]);
	--print("vigorPurchaseTimes: "..counter[enum.COUNTER_TYPE.COUNTER_TYPE_VIGOR_PURCHASE+1]);
	
	dataManager.instanceZonesData:setStatgeTimes(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_STAGE_TIMES ),false)
	dataManager.instanceZonesData:setStatgeTimes(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_ELITE_TIMES ),true)	
	dataManager.instanceZonesData:setStatgeResetTimes(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_STAGE_RESET ),false)
	dataManager.instanceZonesData:setStatgeResetTimes(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_ELITE_RESET ),true)	
	dataManager.instanceZonesData:setStatgeStar(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_STAGE_GRADE ),false)
	dataManager.instanceZonesData:setStatgeStar(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_ELITE_GRADE ),true)
	
	Guide.onServerData(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_GUIDE))
  
 	--dump(player.counterArray);
 	dump(player.counterActivity);
 	
end	