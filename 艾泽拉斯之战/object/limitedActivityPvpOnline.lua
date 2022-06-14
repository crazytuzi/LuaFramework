limitedActivityPvpOnline = class("limitedActivityPvpOnline", limitedActivityBase);

function limitedActivityPvpOnline:isTaskComplete()

	-- 
	return dataManager.pvpData:getTotalTimes() >= self.config.params[1];
	
end

-- 点击前往的处理，默认是空
function limitedActivityPvpOnline:onClickGoto()

	eventManager.dispatchEvent({name = global_event.ACTIVITYS_HIDE});
	homeland.arenaHandle();
	
end
