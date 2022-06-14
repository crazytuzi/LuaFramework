function CrusadeRewardHandler( count )
	
	print("CrusadeRewardHandler rate "..count);
	
	local stageIndex = dataManager.crusadeActivityData:getCurrentStageIndex();
	local defaultConfig = dataManager.crusadeActivityData:getStageDefaultConfig(stageIndex);
	
	-- todo struct rewardInfo;
	local rewardsInfo = {};
	
	for k,v in ipairs(defaultConfig.rewardType) do
		
		local radio = 1;
		
		if enum.REWARD_TYPE.REWARD_TYPE_MONEY == v and
			(defaultConfig.rewardID[k] == enum.MONEY_TYPE.MONEY_TYPE_GOLD or
			defaultConfig.rewardID[k] == enum.MONEY_TYPE.MONEY_TYPE_LUMBER) then
			
			radio = count;
			
		end
		
		local reward = {
			rewardType = v;
			rewardID = defaultConfig.rewardID[k];
			rewardCount = math.floor(defaultConfig.rewardCount[k] * radio);
		};
		
		table.insert(rewardsInfo, reward);
		
	end
	
	dataManager.crusadeActivityData:setRewardInfo(stageIndex, rewardsInfo);
	
	eventManager.dispatchEvent({name = global_event.CRUSADEINFO_UPDATE_REWARD_INFO});
	
end
