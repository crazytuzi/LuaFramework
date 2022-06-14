
--function RewardHandler( battleType, win, firstWin, adventureID, incidentIndex, firstWinReward, reward, randomRewards )
function RewardHandler( battleType, firstWin, firstWinReward, reward, randomRewards )	 
	
	 for k,v in ipairs(firstWinReward.rewardList) do
	 	print("firstWinReward type:"..v.type.." id: "..v.id.." count: "..v.count);
	 end

	 for k,v in ipairs(reward.rewardList) do
	 	print("reward type:"..v.type.." id: "..v.id.." count: "..v.count);
	 end

	 for k,v in ipairs(randomRewards) do
	 	print("randomRewards k:"..k);
	 	for kk, vv in ipairs(v.rewardList) do
	 		print("randomRewards type:"..vv.type.." id: "..vv.id.." count: "..vv.count);
	 	end
	 end
	 
	 print("--------------RewardHandler--------end");
	 	 	 
	 if battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
	 		battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE then
		 dataManager.playerData.stageInfo:setWin(win)
		 dataManager.playerData.stageInfo:setFirstPass(firstWin)		
		 --dataManager.playerData.stageInfo:setRandomReward({randomRewards1,randomRewards2})
	 elseif battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT then
	 	 dataManager.mainBase:setStageWin(win);
	 end
	
	-- 合并所有的奖励， mergedRewardList
	local mergedRewardList = {};
		
	for k,v in ipairs(firstWinReward.rewardList) do		
		global.mergeReward(mergedRewardList, v.type, v.id, v.count);
	end
	
	for k,v in ipairs(reward.rewardList) do
		global.mergeReward(mergedRewardList, v.type, v.id, v.count);
	end

	for k,v in ipairs(randomRewards) do
		for kk, vv in ipairs(v.rewardList) do
	 		global.mergeReward(mergedRewardList, vv.type, vv.id, vv.count);
	 	end
	end
	 	
	-- 所有数据缓存起来，结算界面弹出的时候再处理
	battlePlayer.battleType = battleType;
	sceneManager.battlePlayer().mergedRewardList = mergedRewardList;
	
	if battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PLUNDER or
	 		battleType == enum.BATTLE_TYPE.BATTLE_TYPE_REVENGE then
		
		dataManager.idolBuildData:setRewardInfo(mergedRewardList);
		
	end
	
end
