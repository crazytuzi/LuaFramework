limitedActivityLimitRecharge = class("limitedActivityLimitRecharge", limitedActivityBase);

function limitedActivityLimitRecharge:isTaskComplete()

	return false;
	
end

-- 是发放类
function limitedActivityLimitRecharge:isGainedByMail()
	
	return true;

end

function limitedActivityLimitRecharge:getGotoButtonText()
	return "充  值";
end

function limitedActivityLimitRecharge:getProgressText()
	local progress = dataManager.playerData:getCounterActivity(self:getID());
	
	progress = math.floor(progress / 100);
	
	local total = self.config.params[1];
	total = math.floor(total / 100);
	
	return "已充值："..progress.."/"..total.."(元)";
end

function limitedActivityLimitRecharge:onClickGoto()
	eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});
end
