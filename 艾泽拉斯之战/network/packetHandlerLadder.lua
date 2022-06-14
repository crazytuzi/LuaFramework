function LadderHandler( players )

	local num = #players
	--dump(players)
	for i = 1,num do		
		dataManager.pvpData:createOfflineRankingPlayer(players[i],i)
	end	
	eventManager.dispatchEvent( {name  = global_event.RANKINGLIST_UPDATE})

end
