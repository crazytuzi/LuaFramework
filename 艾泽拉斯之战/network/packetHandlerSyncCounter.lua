function SyncCounterHandler( syncCounterType, arrayType, index, value )
	
	-- 服务器的array从0开始，客户端从1开始
	local player = dataManager.playerData;

	if enum.SYNC_COUNTER_TYPE.SYNC_COUNTER_TYPE_ARRAY == syncCounterType then
		player:setCounterArrayData(arrayType, index, value);
		
		print("arrayType "..arrayType.." index "..index.." value "..value);
	elseif enum.SYNC_COUNTER_TYPE.SYNC_COUNTER_TYPE_COMMON == syncCounterType then
		player:setCounterData(arrayType, value);
		print("arrayType "..arrayType.." value "..value);
	elseif enum.SYNC_COUNTER_TYPE.SYNC_COUNTER_TYPE_ACTIVITY == syncCounterType then
		player:setCounterActivity(arrayType, value);
		print("arrayType "..arrayType.." value "..value);
	end
	 
	dataManager.instanceZonesData:setStatgeTimes(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_STAGE_TIMES ),false)
	dataManager.instanceZonesData:setStatgeTimes(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_ELITE_TIMES ),true)	
	dataManager.instanceZonesData:setStatgeResetTimes(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_STAGE_RESET ),false)
	dataManager.instanceZonesData:setStatgeResetTimes(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_ELITE_RESET ),true)	
	dataManager.instanceZonesData:setStatgeStar(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_STAGE_GRADE ),false)
	dataManager.instanceZonesData:setStatgeStar(player:getCounterArrayDataAll(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_ELITE_GRADE ),true)
 
	eventManager.dispatchEvent({name = global_event.INSTANCEINFOR_UPDATE});
	
	if enum.SYNC_COUNTER_TYPE.SYNC_COUNTER_TYPE_ARRAY == syncCounterType then
		if arrayType == enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_EVENT_STATUS then
			--eventManager.dispatchEvent({name = global_event.TASK_UPDATE_LIST});
		
		elseif arrayType == enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_LIMIT_ACTIVITY then
		 
			eventManager.dispatchEvent({name = global_event.ACTIVITYS_UPDATE});
		
		elseif arrayType == enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_LIMIT_RECHARGE then
			
			eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "恭喜您充值成功"})
		
		end
		
	elseif enum.SYNC_COUNTER_TYPE.SYNC_COUNTER_TYPE_COMMON == syncCounterType then
		-- 非数组的
		if arrayType == enum.COUNTER_TYPE.COUNTER_TYPE_FREE_VIGOR_NOON or
		 	arrayType == enum.COUNTER_TYPE.COUNTER_TYPE_FREE_VIGOR_EVENING then
			eventManager.dispatchEvent({name = global_event.TASK_UPDATE_FREE_VIGOR});	
		elseif enum.COUNTER_TYPE.COUNTER_TYPE_GUILD_SIGNIN_COUNT == arrayType then
			
			eventManager.dispatchEvent({name = global_event.GUILDCREATE_UPDATE});
			
		elseif enum.COUNTER_TYPE.COUNTER_TYPE_GUILD_WAR_INSPIRE_COUNT == arrayType then
			
			eventManager.dispatchEvent({name = global_event.GUILDWARINFO_UPDATE});
		
		elseif enum.COUNTER_TYPE.COUNTER_TYPE_GUILD_WAR_FIGHT_BUY_COUNT == arrayType then
			
			eventManager.dispatchEvent({name = global_event.GUILDWARLIST_UPDATE});
			
		end
	end
	
	print("SyncCounterHandler");
	eventManager.dispatchEvent({name = global_event.MAIN_UI_FULI_STATE});
	eventManager.dispatchEvent({name = global_event.MAIN_UI_DAILY_REWARD_STATE});
	eventManager.dispatchEvent({name = global_event.MAIN_UI_ACTIVITY_STATE});
	eventManager.dispatchEvent({name = global_event.BUYRESOURCE_UPDATE, });
	eventManager.dispatchEvent({name = global_event.MAIN_UI_TUJIAN_STATE, });
	eventManager.dispatchEvent({name = global_event.TASK_UPDATE_LIST});
	eventManager.dispatchEvent({name = global_event.IDOLSTATUS_UPDATE});
	eventManager.dispatchEvent({name = global_event.PURCHASE_UPDATE});
	
end
