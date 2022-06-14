limitedActivityAllRecharge = class("limitedActivityAllRecharge", limitedActivityBase);

function limitedActivityAllRecharge:isTaskComplete()

	return false;
	
end


-- 是发放类
function limitedActivityAllRecharge:isGainedByMail()
	
	return true;

end

function limitedActivityAllRecharge:getGotoButtonText()
	return "充  值";
end

function limitedActivityAllRecharge:getProgressText()
	
	local progress = dataManager.playerData:getCounterActivity(self:getID());
	
	progress = math.floor(progress / 100);
	
	local total = self.config.params[1];
	total = math.floor(total / 100);
	
	return "总充值："..progress.."/"..total.."(元)";
end

function limitedActivityAllRecharge:onClickGoto()
	eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});
end

