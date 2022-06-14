function SyncTopRankHandler( topType, rank )
    if topType == enum.TOP_TYPE.TOP_TYPE_DAMAGE then
        dataManager.hurtRankData:setRank(rank)
	    eventManager.dispatchEvent( {name = global_event.ACTIVITYDAMAGE_UPDATE})
    elseif topType == enum.TOP_TYPE.TOP_TYPE_SPEED then
        --print("syncTopSpeedRank");
        
        dataManager.speedChallegeRankData:setMyRank(rank);
    end
end
