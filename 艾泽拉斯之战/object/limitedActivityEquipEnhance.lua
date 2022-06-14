limitedActivityEquipEnhance = class("limitedActivityEquipEnhance", limitedActivityBase);

function limitedActivityEquipEnhance:isTaskComplete()

	-- 紫装满强化
	return dataManager.bagData:hasMaxEnhancedEquipByStar(3, self.config.params[1]);
	
end

-- 点击前往的处理，默认是空
function limitedActivityEquipEnhance:onClickGoto()
	eventManager.dispatchEvent({name = global_event.ACTIVITYS_HIDE});
	eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_SHOW, ship = 1});
end
