function PvpCandidateHandler( candidates )

	local num = #candidates
	dataManager.pvpData:OncreateOfflinePlayer()
	for i =1,num do		
		dataManager.pvpData:createOfflinePlayer(candidates[i],i)
	end	
	eventManager.dispatchEvent( {name  = global_event.PVP_UPDATE})
	--dump(candidates)
	
	print("PvpCandidateHandler                                    "..num)
end
