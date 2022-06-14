function TopResultHandler( topType, maxScore, currentScore, rank )
    if topType == enum.TOP_TYPE.TOP_TYPE_DAMAGE then
        dataManager.hurtRankData:setServerResult(true)
	
	    dataManager.hurtRankData:setScore(currentScore)
	    dataManager.hurtRankData:setHistroyScore(maxScore)
	    dataManager.hurtRankData:setRank(rank)
    elseif topType == enum.TOP_TYPE.TOP_TYPE_SPEED then
       
      --print("TopResultHandler  rank "..rank);
       
      dataManager.speedChallegeRankData:setMyRank(rank);
      dataManager.speedChallegeRankData:setMyScore(currentScore);

    end
end
