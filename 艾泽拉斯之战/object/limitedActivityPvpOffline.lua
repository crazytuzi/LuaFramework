limitedActivityPvpOffline = class("limitedActivityPvpOffline", limitedActivityBase);

function limitedActivityPvpOffline:isTaskComplete()

	return false;
	
end

function limitedActivityPvpOffline:isGainedByMail()
	
	return true;

end

function limitedActivityPvpOffline:onClickGoto()

	eventManager.dispatchEvent({name = global_event.ACTIVITYS_HIDE});
	homeland.arenaHandle();
	
end
