limitedActivityDiamondCost = class("limitedActivityDiamondCost", limitedActivityBase);

function limitedActivityDiamondCost:isTaskComplete()

	return false;
	
end

-- 是发放类
function limitedActivityDiamondCost:isGainedByMail()
	
	return true;

end

function limitedActivityDiamondCost:getGotoButtonText()
	return "充  值";
end

function limitedActivityDiamondCost:getProgressText()
	
	local progress = dataManager.playerData:getCounterActivity(self:getID());
	local total = self.config.params[1];
	
	return "已消耗："..progress.."/"..total.."(钻)";
end

function limitedActivityDiamondCost:onClickGoto()
	eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});
end
