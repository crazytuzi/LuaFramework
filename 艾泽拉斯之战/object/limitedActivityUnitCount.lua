limitedActivityUnitCount = class("limitedActivityUnitCount", limitedActivityBase);

function limitedActivityUnitCount:isTaskComplete()
	-- 拥有的总军团数  悟    空 源 码 网 ww w . w k ym w .com
	
	return cardData.getOwnedCardCount() >= self.config.params[1];
	
end

-- 点击前往的处理，默认是空
function limitedActivityUnitCount:onClickGoto()
	eventManager.dispatchEvent({name = global_event.ACTIVITYS_HIDE});
	
	homeland.corpsHandle();
end
