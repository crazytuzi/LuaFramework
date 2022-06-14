function SyncRevengeSummaryHandler( revengers )

	dataManager.idolBuildData:updateRevengeSummary(revengers);
	eventManager.dispatchEvent({name = global_event.IDOLSTATUS_UPDATE});
	
end
