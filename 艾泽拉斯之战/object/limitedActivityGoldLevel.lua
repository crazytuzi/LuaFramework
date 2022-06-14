limitedActivityGoldLevel = class("limitedActivityGoldLevel", limitedActivityBase);

function limitedActivityGoldLevel:isTaskComplete()
	-- 金矿等级
	
	return dataManager.goldMineData:getLevel() >= self.config.params[1];
	
end

-- 点击前往的处理，默认是空
function limitedActivityGoldLevel:onClickGoto()
	eventManager.dispatchEvent({name = global_event.ACTIVITYS_HIDE});
	
	homeland.goldHandle();
end
