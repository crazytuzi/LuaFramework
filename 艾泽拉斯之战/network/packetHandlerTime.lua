function TimeHandler( time, timezone, serverDays, serverBeginTime )
	dataManager.setServerTime(time, timezone-12);--{-12 --- +12} beijing is -8
	dataManager.setServerOpenDay(serverDays)
	
	dataManager.setServerBeginTime(serverBeginTime:GetUInt());
	
	dataManager.hurtRankData:SetCurrentStageIndex(serverDays)
end
