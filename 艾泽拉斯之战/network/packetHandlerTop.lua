function TopHandler( topType, palyers )
    local num = #palyers
		if topType == enum.TOP_TYPE.TOP_TYPE_DAMAGE then
	    for i = 1,num do		
		    dataManager.hurtRankData:createHurtPlayer(palyers[i],i)
	    end	
	    eventManager.dispatchEvent( {name  = global_event.RANKINGLIST_UPDATE})
    elseif topType == enum.TOP_TYPE.TOP_TYPE_SPEED then
        
      for i = 1,num do		
		    dataManager.speedChallegeRankData:setRankData(palyers[i].rank, palyers[i]);
	    end
	    
	    eventManager.dispatchEvent( {name  = global_event.RANKINGLIST_UPDATE})
	    
    end
end
