function SyncRevengeTargetHandler( revengeTarget )
	
	local dbid = dataManager.idolBuildData:getCurrentSelectTargetInfo().dbid;
	
	local targetInfo = clone(revengeTarget);
	targetInfo.dbid = dbid;
	
	dataManager.idolBuildData:setCurrentSelectTargetInfo(targetInfo);
	
	eventManager.dispatchEvent({name = global_event.ROBREVENGECHOICE_SHOW, });
		
end
