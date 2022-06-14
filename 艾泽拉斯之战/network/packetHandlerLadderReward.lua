function LadderRewardHandler( oldBestRank, newBestRank, reward )
 

	 
  --eventManager.dispatchEvent({name = global_event.RANKINGAWARD_SHOW , reward = reward, oldBestRank = oldBestRank, newBestRank = newBestRank})

	layoutManager.delay({name = global_event.RANKINGAWARD_SHOW , reward = reward, oldBestRank = oldBestRank, newBestRank = newBestRank}, {"herolevelup","instancejiesuanView","BattleView"})
end
