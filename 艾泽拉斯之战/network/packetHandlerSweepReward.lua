function SweepRewardHandler( randomRewards )
	
	local count = #randomRewards
	
	
	local rewards = {}    
	for i= 1, count do
		 local reward = randomRewards[i]
		 local index =  math.floor((i + 1)/2)
		 rewards[index]  =  rewards[index]  or {}		
		 table.insert(rewards[index],reward['rewardList'])			
	end
	
	count = math.floor(count/2)
	dataManager.playerData.stageInfo:ClearSweepRandomReward(count)  ---count/2 ¾ÍÊÇÂÖ
	for i= 1, count do		
		 dataManager.playerData.stageInfo:AddSweepRandomReward(i,rewards[i]) 			
	end
	
	eventManager.dispatchEvent( {name = global_event.SWEEP_SHOW,stage = dataManager.playerData.stageInfo })
	--print("SweepRewardHandler ----------------------------------------"..count)
end
