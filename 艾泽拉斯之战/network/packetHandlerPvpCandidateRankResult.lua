function PvpCandidateRankResultHandler( data )
	
	local player = dataManager.pvpData:getPlayerWithPlayerID(data['playerID'])
	if(player == nil)then
		player  = dataManager.pvpData:getSelectPlayer(data['playerID'])
	end
	if(player)then
		local old = player.ranking 
		player:setData(data)
		local rank = player.ranking
		if(rank <= 0)then
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo =  "玩家已经跌出竞技场排名，无法挑战" });
			return 
		end	
			
		if(old == rank)	then
			global.gotoPvpOfflineBattle()
		else
				local nowRanking,_nowRanking = player:getOfflineRanking()
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo =  "玩家排名已经从"..old.."变为"..nowRanking.." 继续挑战？",callBack = global.gotoPvpOfflineBattle });
		end
		
	end

end